# git, with .gitconfig and the global ignore list kept as plain files.
# Identity lives in ~/.gitconfig_ident (included by gitconfig), which stays
# unmanaged so it never lands in this repo.
{
  flake.modules.homeManager.git =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        gitFull
        git-lfs
      ];
      home.file.".gitconfig".source = ./gitconfig;
      home.file.".gitignore_global".source = ./gitignore_global;
    };
}
