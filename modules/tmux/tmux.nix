# tmux, with the config kept as a plain file so it reads like tmux.
{
  flake.modules.homeManager.tmux =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.tmux
        # Copy-mode clipboard helper used by tmux.conf.
        (pkgs.writeScriptBin "which_clip.sh" (builtins.readFile ./which_clip.sh))
      ];
      home.file.".tmux.conf".source = ./tmux.conf;
    };
}
