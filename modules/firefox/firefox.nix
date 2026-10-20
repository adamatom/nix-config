# Firefox with locked-in add-ons, the existing profile, and a memory cap.
{
  flake.modules.homeManager.firefox =
    { pkgs, wrapGL, ... }:
    let
      # Wrap a package so its main binary launches inside a transient systemd
      # --user scope with cgroup-v2 memory limits, keeping the whole process tree
      # (and any children, e.g. firefox content processes) under one cap.
      #   high = MemoryHigh: soft limit. Kernel throttles + aggressively reclaims
      #          the cgroup above this; it gets slow but is NOT killed.
      #   max  = MemoryMax:  hard limit. Crossing it OOM-kills a process *inside
      #          this cgroup only* (usually a tab), never the rest of the session.
      # Apply outside wrapGL so the scope contains the nixGL -> firefox tree.
      wrapMem =
        args@{ high, max }:
        pkg:
        let
          exe = pkg.meta.mainProgram;
          wrapped = pkgs.symlinkJoin {
            name = "${pkg.name}-memcap";
            paths = [ pkg ];
            postBuild = ''
              rm -f "$out/bin/${exe}"
              cat > "$out/bin/${exe}" <<EOF
              #!${pkgs.runtimeShell}
              exec ${pkgs.systemd}/bin/systemd-run --user --scope --quiet --collect \
                -p MemoryHigh=${high} -p MemoryMax=${max} \
                ${pkg}/bin/${exe} "\$@"
              EOF
              chmod +x "$out/bin/${exe}"
            '';
          };
        in
        # Forward override/overrideAttrs so consumers (e.g. the home-manager
        # firefox module, which does package.override to inject policies) re-apply
        # the memcap wrapper instead of unwrapping it.
        wrapped
        // {
          inherit (pkg) meta;
          override = f: wrapMem args (pkg.override f);
          overrideAttrs = f: wrapMem args (pkg.overrideAttrs f);
        };

      # Add-ons every Firefox install must have. Force-installed by enterprise
      # policy from addons.mozilla.org, so they cannot be removed in the UI and
      # keep auto-updating. Keyed by add-on ID, mapped to the AMO slug.
      firefoxPolicies.ExtensionSettings =
        builtins.mapAttrs
          (_: slug: {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
          })
          {
            "{3c078156-979c-498b-8990-85f7987dd929}" = "sidebery";
            "uBlock0@raymondhill.net" = "ublock-origin";
            "{446900e4-71c2-419f-a6a7-df9c091e268b}" = "bitwarden-password-manager";
            "78272b6fa58f4a1abaac99321d503a20@proton.me" = "proton-pass";
            "firefox-extension@deepl.com" = "deepl-translate";
            "{9063c2e9-e07c-4c2c-9646-cfe7ca8d0498}" = "old-reddit-redirect";
            "chrome-gnome-shell@gnome.org" = "gnome-shell-integration";
          };
    in
    {
      programs.firefox = {
        enable = true;
        # Policies are baked into the Firefox package itself, before the nixGL
        # and memcap wrappers. Neither wrapper exposes the override signature
        # home-manager needs, so its `policies` option would be dropped silently.
        package = wrapMem {
          high = "10G";
          max = "14G";
        } (wrapGL (pkgs.firefox.override { extraPolicies = firefoxPolicies; }));
        configPath = ".mozilla/firefox";

        # Adopt the existing profile rather than creating a fresh one.
        profiles.default = {
          id = 0;
          path = "q553gd94.default";
          isDefault = true;
          # Matches the "Profile Groups" database Firefox already created.
          storeId = "26ba037c";

          settings = {
            # Required for userChrome.css to load.
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
            # Sidebery replaces Firefox's built-in vertical tabs.
            "sidebar.verticalTabs" = false;
          };

          userChrome = builtins.readFile ./userChrome.css;
        };
      };
    };
}
