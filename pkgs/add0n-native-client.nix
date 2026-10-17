{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  makeWrapper,
  nodejs,
  # Put on PATH because the extension launches the browser by name (`firefox <url>`)
  # and native hosts inherit the browser's environment, which may not include it.
  firefox,
  # Only the "Open in Firefox" Chrome extension may talk to this host.
  # The host runs arbitrary commands for any extension it trusts.
  allowedExtensionIds ? [ "lmeddoobegbaiopohmpmmobpnpjifpii" ],
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "add0n-native-client";
  version = "1.1.5";

  src = fetchFromGitHub {
    owner = "andy-portmen";
    repo = "native-client";
    tag = "v${finalAttrs.version}";
    hash = "sha256-9aX2dTbAr7/KGR0ynHCCW/6457KZPwXinhVmB7yGTeI=";
  };

  nativeBuildInputs = [ makeWrapper ];

  passAsFile = [ "manifest" ];
  manifest = builtins.toJSON {
    name = "com.add0n.node";
    description = "NodeJS Host by WebExtension.ORG for Browser Native Messaging";
    path = "@out@/bin/com.add0n.node";
    type = "stdio";
    allowed_origins = map (id: "chrome-extension://${id}/") allowedExtensionIds;
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # Same files upstream's linux/app/install.js copies into ~/.config/com.add0n.node.
    install -Dm444 host.js messaging.js -t $out/lib/com.add0n.node

    # Replaces the run.sh that upstream's installer writes.
    makeWrapper ${lib.getExe nodejs} $out/bin/com.add0n.node \
      --add-flags $out/lib/com.add0n.node/host.js \
      --prefix PATH : ${lib.makeBinPath [ firefox ]}

    # Layout expected by home-manager's programs.<chromium>.nativeMessagingHosts.
    mkdir -p $out/etc/chromium/native-messaging-hosts
    substitute $manifestPath $out/etc/chromium/native-messaging-hosts/com.add0n.node.json \
      --subst-var out

    runHook postInstall
  '';

  meta = {
    description = "Native messaging host used by andy-portmen's Open in Firefox extension";
    homepage = "https://github.com/andy-portmen/native-client";
    license = lib.licenses.mpl20;
    mainProgram = "com.add0n.node";
    platforms = lib.platforms.linux;
  };
})
