# NixOS + HomeManager config

## NixOS
When running from NixOS, the home-manager config is loaded automatically. To
switch both NixOS and home-manager config, run:
```
sudo nixos-rebuild switch --flake '.#hydra'
```

## HomeManager

When running this config on HomeManager inside of another Linux distribution,
this command can be run initially to install home-manager and the apps defined
in this flake:
```
nix run "nixpkgs#home-manager" -- switch --flake "./nix-config#adam"
```

Then after, update with:
```
home-manager switch --flake ~/nix-config#adam
```

## Gnome Settings

Use dconf dump to know what to put into the `donf.settings`. For example,
figuring out what to add when you want to configure PaperWM to treat
`ulauncher` as a scratch layer:

1. Modify the settings using the gui.
2. Run `dconf dump` with as much of the dconf path as you know:
   ```
   $ dconf dump /org/gnome/shell/extensions/paperwm/ |grep ulauncher
   winprops=['{"wm_class":"ulauncher","scratch_layer":true}']
   ```
3. Remove the change from the gui.
4. Add the change to `dconf.settings` in `home/adam.nix`.
5. Switch config and double check in the gui that the change is effective.
