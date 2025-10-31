{ pkgs, ... }:

{
  programs.nixvim = {
    clipboard = {
      register = "unnamedplus";
      providers.wl-copy.enable = true;
    };

    defaultEditor = true;

    extraPackages = with pkgs; [
      black
      nil
      nixfmt-rfc-style
      ripgrep
    ];

    opts = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
    };

    plugins = {
      bufferline.enable = true;

      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          mapping = {
            "<C-Space>" = "cmp.mapping.complete()";
            "<C-d>" = "cmp.mapping.scroll_docs(-4)";
            "<C-e>" = "cmp.mapping.close()";
            "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
          };
          sources = [
            { name = "nvim_lsp"; }
            { name = "path"; }
            { name = "buffer"; }
          ];
        };
      };

      colorizer.enable = true;

      conform-nvim = {
        enable = true;
        settings = {
          format_on_save = {
            timeout_ms = 500;
            lsp_fallback = true;
          };
          formatters_by_ft = {
            quarto = [ "injected" ];
            nix = [ "nixfmt" ];
            python = [ "black" ];
          };
        };
      };

      iron.enable = true;

      lsp = {
        enable = true;

        servers.nil_ls = {
          enable = true;
          settings = {
            formatting = {
              command = [ "nixfmt" ];
            };
          };
        };
      };

      molten.enable = true;
      quarto.enable = true;

      telescope = {
        enable = true;
        keymaps = {
          "fb" = "buffers";
          "ff" = "find_files";
          "fg" = "live_grep";
          "fh" = "help_tags";
        };
      };

      vim-slime = {
        enable = true;
        settings.target = "neovim";
      };

      web-devicons.enable = true;
    };

    viAlias = true;
    vimAlias = true;
    withRuby = false;
  };
}
