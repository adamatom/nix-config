# Neovim, with the config kept as plain Lua in ./nvim. lazy.nvim installs the
# plugins at runtime; its lockfile lives in ~/.local/share/nvim.
{
  flake.modules.homeManager.neovim =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.neovim ];
      xdg.configFile."nvim".source = ./nvim;
    };
}
