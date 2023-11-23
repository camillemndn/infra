{ vimUtils
, fetchFromGitHub
}:

{
  catppuccin-nvim = vimUtils.buildVimPlugin rec {
    pname = "catppuccin-nvim";
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

  quarto-nvim = vimUtils.buildVimPlugin rec {
    name = "quarto-nvim";
    version = "0.13.2";
    src = fetchFromGitHub {
      owner = "quarto-dev";
      repo = "quarto-nvim";
      rev = "v${version}";
      hash = "sha256-Y3gjJMHwfqu/FYS7PLi+4faybFaaG9fBnQWVYaNTuSM=";
    };
  };
}
