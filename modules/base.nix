# What every machine gets: identity, shell, everyday CLI tools.
{
  flake.modules.homeManager.base =
    { pkgs, ... }:
    {
      home = {
        username = "adam";
        homeDirectory = "/home/adam";
      };

      home.packages = with pkgs; [
        # I dont want to give up my .zshrc yet, so I cant use programs.zsh.enable.
        zsh

        # CLI tools
        bat
        curlFull
        fd
        file
        fzf
        gawk
        gitFull
        git-lfs
        glab
        gnupg
        gnused
        gnutar
        jq
        killall
        mcfly
        neovim
        nmap
        ripgrep
        tmux
        tree
        wget
        which
        xclip
        xz
        zip
        unzip
        zoxide
        zstd

        # system libs
        libxcrypt
      ];

      programs = {
        direnv = {
          enable = true;
          nix-direnv.enable = true;
          enableZshIntegration = true;
        };

        htop.enable = true;

        # Let home Manager install and manage itself.
        home-manager.enable = true;
      };

      # This value determines the home Manager release that your
      # configuration is compatible with. This helps avoid breakage
      # when a new home Manager release introduces backwards
      # incompatible changes.
      #
      # You can update home Manager without changing this value. See
      # the home Manager release notes for a list of state version
      # changes in each release.
      home.stateVersion = "24.11";
    };
}
