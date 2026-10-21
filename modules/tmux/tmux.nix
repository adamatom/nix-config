# tmux, with the config kept as a plain file so it reads like tmux.
{
  flake.modules.homeManager.tmux =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.tmux ];
      home.file.".tmux.conf".source = ./tmux.conf;
    };
}
