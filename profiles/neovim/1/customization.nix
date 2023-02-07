{ pkgs }:

let
  vimrc = pkgs.callPackage ./vimrc.nix { };
  # folding-nvim = pkgs.vimUtils.buildVimPluginFrom2Nix {
  #   pname = "folding-nvim";
  #   version = "2021-10-02";
  #   src = pkgs.fetchFromGitHub {
  #     owner = "pierreglaser";
  #     repo = "folding-nvim";
  #     rev = "75a89c7524b2ef63a37549af04af538daec68e46";
  #     sha256 = "sha256-wsMAtnCGmNow6NJr2Lxh5F3Tvq7u5gQAXZpgeQGfi0Q=";
  #   };
  # };
  base16-vim-airline-themes = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "base16-vim-airline-themes";
    version = "2021-11-05";
    src = pkgs.fetchFromGitHub {
      owner = "dawikur";
      repo = "base16-vim-airline-themes";
      rev = "925a56f54c2d980db4ec986aae6e4ae29d27ee45";
      sha256 = "sha256-j2xMeu1r0j6bGYDu25jnb39j30iYXf6YoHWuDQJ/zl8=";
    };
  };
  nvim-cmp = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "nvim-cmp";
    version = "2021-10-02";
    src = pkgs.fetchFromGitHub {
      owner = "hrsh7th";
      repo = "nvim-cmp";
      rev = "af70f40d2eb6db2121536c8df2e114af759df537";
      sha256 = "sha256-q7H6C4zNSVnCknXv70J5d4LySR0Iprvb6cqqoJyGZus=";
    };
  };
  cmp-nvim-lsp = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "cmp-nvim-lsp";
    version = "2021-10-02";
    src = pkgs.fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-nvim-lsp";
      rev = "f93a6cf9761b096ff2c28a4f0defe941a6ffffb5";
      sha256 = "sha256-vfL4OXpufc3lN3SGJsV1T4xOa5wyn05GdYRSms6VpAs=";
    };
  };
  cmp-buffer = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "cmp-buffer";
    version = "2021-10-02";
    src = pkgs.fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-buffer";
      rev = "5dde5430757696be4169ad409210cf5088554ed6";
      sha256 = "sha256-lLP6gnuSN/tJiJ1sb2u6Xm5G2P59pz6tnOGDRfbivjk=";
    };
  };
  cmp-path = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "cmp-path";
    version = "2021-10-02";
    src = pkgs.fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-path";
      rev = "0016221b6143fd6bf308667c249e9dbdee835ae2";
      sha256 = "sha256-axU7g7Dg+/uCVFxuz42FaUtUyU/Xzlm/XOsEvlUfZA4=";
    };
  };
  cmp-calc = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "cmp-calc";
    version = "2021-10-02";
    src = pkgs.fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-calc";
      rev = "cda036bfd147288c107b840e917fdd0a3e18f404";
      sha256 = "sha256-tFRORyNVGPmjbXpoKGZO3987U/XyQCxGADo79W/qWug=";
    };
  };
  cmp-spell = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "cmp-spell";
    version = "2021-10-02";
    src = pkgs.fetchFromGitHub {
      owner = "f3fora";
      repo = "cmp-spell";
      rev = "7157c9fa1029269d97d9ed5632ec575bb71981b4";
      sha256 = "sha256-wrB/hiIVfzns9ynjCLSV+/WlzpsxdQdd2+18mfQfLPc=";
    };
  };
  cmp-emoji = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "cmp-emoji";
    version = "2021-10-02";
    src = pkgs.fetchFromGitHub {
      owner = "hrsh7th";
      repo = "cmp-emoji";
      rev = "19075c36d5820253d32e2478b6aaf3734aeaafa0";
      sha256 = "sha256-zc5GNkwdVHaeEoCer9tz40F2Xc8qTzPw6NbgkMjjWQI=";
    };
  };
  cmp-treesitter = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "cmp-treesitter";
    version = "2021-10-02";
    src = pkgs.fetchFromGitHub {
      owner = "ray-x";
      repo = "cmp-treesitter";
      rev = "cdc1c4c6170278e119759da0b3c28d73f531a231";
      sha256 = "sha256-oW0LR/FDjFlCzxHXl0T0sy1bnZj2BFKmxF+3ahDIEEA=";
    };
  };
  cmp-latex-symbols = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "cmp-latex-symbols";
    version = "2021-10-02";
    src = pkgs.fetchFromGitHub {
      owner = "kdheepak";
      repo = "cmp-latex-symbols";
      rev = "29dc9e53d17cd1f26605888f85500c8ba79cebff";
      sha256 = "sha256-9KHNmb0yt/AmUOf1etbj7rkDXTYYj1S89K8ycD3gEp8=";
    };
  };
  base16-vim = pkgs.vimUtils.buildVimPluginFrom2Nix {
    pname = "base16-vim";
    version = "2022-01-23";
    src = pkgs.fetchFromGitHub {
      owner = "fnune";
      repo = "base16-vim";
      rev = "18656ced6196dca7b4df47fe5ddec48c7b5819bd";
      sha256 = "sha256-n69/NZGhj2cp3Vj4DpL2MywGuFKxV2VNqOLTbVGuehw=";
    };
  };
in
{
  customRC = vimrc;

  packages.neovim = with pkgs.vimPlugins; {
    start = [
      nvim-lspconfig
      YouCompleteMe
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      cmp-calc
      cmp-spell
      cmp-emoji
      cmp-treesitter
      cmp-latex-symbols
      cmp-omni

      telescope-nvim

      # vim-grammarous
      vim-matchup
      # vim-man
      NeoSolarized
      nerdtree
      nerdtree-git-plugin
      # fzf
      fzf-vim
      vim-commentary
      camelcasemotion
      vim-closetag
      vim-polyglot
      vim-surround
      vim-indent-guides # original is thaerkh/vim-indentguides
      gruvbox
      vim-repeat
      gitgutter
      vim-gitgutter
      vim-airline
      rainbow # original is frazrepo/vim-rainbow
      vim-devicons
      vim-shellcheck
      editorconfig-vim

      plantuml-syntax

      nvim-treesitter

      # edit gpg encrypted files
      vim-gnupg

      base16-vim
      base16-vim-airline-themes

      vim-ledger
    ];

    opt = [ ];
  };
}
