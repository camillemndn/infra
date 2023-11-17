{ vimUtils
, fetchFromGitHub
}:

{
  catppuccin = vimUtils.buildVimPlugin rec {
    pname = "catppuccin";
    version = "1.5.0";
    src = fetchFromGitHub {
      owner = "catppuccin";
      repo = "nvim";
      rev = "v${version}";
      hash = "sha256-s8nMeBtDnf/L7/rYwmf6UexykfADXJx0fZoDg8JacGs=";
    };
  };

  Nvim-R = vimUtils.buildVimPlugin rec {
    pname = "Nvim-R";
    version = "0.9.18";
    src = fetchFromGitHub {
      owner = "jalvesaq";
      repo = "Nvim-R";
      rev = "v${version}";
      hash = "sha256-doB/ddsyXmBt0fHnC4XwhCrP5Ks2UYGxaUzKQ7HMZqI=";
    };
  };

  otter-nvim = vimUtils.buildVimPlugin rec {
    name = "otter-nvim";
    version = "1.4.1";
    src = fetchFromGitHub {
      owner = "jmbuhr";
      repo = "otter.nvim";
      rev = "v${version}";
      hash = "sha256-N309UXla1sgnPcb+p3sdDhugw75gT5kcx5hkDSHmjG0=";
    };
  };

  quarto-nvim = vimUtils.buildVimPlugin rec {
    name = "quarto-nvim";
    version = "0.17.0";
    src = fetchFromGitHub {
      owner = "quarto-dev";
      repo = "quarto-nvim";
      rev = "v${version}";
      hash = "sha256-8Z6n4ajfwQOn1X7E+I1s+fx+3Wgx9dPWUTb7e0HpAIc=";
    };
  };
}
