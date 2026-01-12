{
  description = "LazyVim configuration with Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        # VictorMono Nerd Font
        victorMonoNerdFont = pkgs.nerd-fonts.victor-mono;

        # Core dependencies for LazyVim
        coreDeps = with pkgs; [
          # Essential tools
          git
          curl
          wget
          unzip
          gnutar
          gzip

          # Search tools (required by Telescope)
          ripgrep
          fd
          fzf

          # Clipboard support
          xclip
          wl-clipboard

          # Build tools
          gcc
          gnumake
          cmake
          pkg-config
        ];

        # Language servers
        lspServers = with pkgs; [
          # Lua
          lua-language-server

          # Nix
          nil
          nixd

          # Python
          pyright
          ruff

          # JavaScript/TypeScript
          nodePackages.typescript-language-server
          nodePackages.vscode-langservers-extracted # HTML, CSS, JSON, ESLint

          # Go
          gopls
          delve

          # Rust
          rust-analyzer

          # Bash
          nodePackages.bash-language-server

          # YAML
          yaml-language-server

          # TOML
          taplo

          # Markdown
          marksman

          # Docker
          dockerfile-language-server

          # Terraform
          terraform-ls
        ];

        # Formatters
        formatters = with pkgs; [
          # Lua
          stylua

          # Nix
          nixfmt
          alejandra

          # Python
          black
          isort

          # JavaScript/TypeScript
          nodePackages.prettier

          # Go
          gotools
          gofumpt

          # Rust
          rustfmt

          # Shell
          shfmt

          # TOML
          taplo

          # YAML
          nodePackages.prettier

          # Markdown
          nodePackages.prettier
        ];

        # Linters
        linters = with pkgs; [
          # Python
          ruff
          pylint

          # JavaScript/TypeScript
          nodePackages.eslint

          # Shell
          shellcheck

          # Markdown
          markdownlint-cli

          # YAML
          yamllint
        ];

        # Debuggers
        debuggers = with pkgs; [
          # Python
          python3Packages.debugpy

          # Go
          delve
        ];

        # Additional tools
        additionalTools = with pkgs; [
          # Git integration
          lazygit
          delta

          # Terminal
          tree

          # Node.js (for many LSP servers and tools)
          nodejs_22

          # Python (for debugpy and other tools)
          python3

          # Cargo (for Rust tools)
          cargo
        ];

        # Tree-sitter CLI for parser management
        treesitterCLI = pkgs.tree-sitter;

        # All dependencies combined
        allDeps = coreDeps ++ lspServers ++ formatters ++ linters ++ debuggers ++ additionalTools ++ [ treesitterCLI ];

        # Neovim package (just the base editor)
        neovimPackage = pkgs.neovim.override {
          withNodeJs = true;
          withPython3 = true;
          withRuby = false;
        };

        # Wrapper script that sets up fonts and environment
        lazyVimWrapper = pkgs.writeShellScriptBin "lvim" ''
          export FONTCONFIG_FILE=${pkgs.fontconfig.out}/etc/fonts/fonts.conf
          export FONTCONFIG_PATH=${victorMonoNerdFont}/share/fonts

          # Set XDG directories if not set
          export XDG_CONFIG_HOME=''${XDG_CONFIG_HOME:-$HOME/.config}
          export XDG_DATA_HOME=''${XDG_DATA_HOME:-$HOME/.local/share}
          export XDG_STATE_HOME=''${XDG_STATE_HOME:-$HOME/.local/state}
          export XDG_CACHE_HOME=''${XDG_CACHE_HOME:-$HOME/.cache}

          # Ensure nvim directories exist
          mkdir -p "$XDG_CONFIG_HOME/nvim/lua/plugins"
          mkdir -p "$XDG_CONFIG_HOME/nvim/lua/config"
          mkdir -p "$XDG_DATA_HOME/nvim"
          mkdir -p "$XDG_DATA_HOME/nvim/lazy"

          # Add path to dependencies FIRST
          export PATH="${pkgs.lib.makeBinPath allDeps}:$PATH"

          # Bootstrap lazy.nvim if it doesn't exist
          LAZY_PATH="$XDG_DATA_HOME/nvim/lazy/lazy.nvim"
          if [ ! -d "$LAZY_PATH" ]; then
            echo "Bootstrapping lazy.nvim..."
            ${pkgs.git}/bin/git clone --filter=blob:none \
              https://github.com/folke/lazy.nvim.git \
              --branch=stable \
              "$LAZY_PATH"
          fi

          # Create initial config if it doesn't exist
          if [ ! -f "$XDG_CONFIG_HOME/nvim/init.lua" ]; then
            cat > "$XDG_CONFIG_HOME/nvim/init.lua" << 'INIT_EOF'
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    { import = "plugins" },
  },
  defaults = {
    lazy = false,
    version = false,
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = { enabled = true },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
INIT_EOF
          fi

          # Create font configuration if it doesn't exist
          if [ ! -f "$XDG_CONFIG_HOME/nvim/lua/plugins/fonts.lua" ]; then
            cat > "$XDG_CONFIG_HOME/nvim/lua/plugins/fonts.lua" << 'FONT_EOF'
return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "night",
      transparent = false,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
      },
    },
  },
}
FONT_EOF
          fi

          # Create options file with VictorMono font if it doesn't exist
          if [ ! -f "$XDG_CONFIG_HOME/nvim/lua/config/options.lua" ]; then
            cat > "$XDG_CONFIG_HOME/nvim/lua/config/options.lua" << 'OPTIONS_EOF'
-- Options are automatically loaded before lazy.nvim startup
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Font configuration (for GUI clients)
vim.opt.guifont = "VictorMono Nerd Font:h14"

-- Enable italic comments and keywords
vim.cmd([[
  highlight Comment cterm=italic gui=italic
  highlight Keyword cterm=italic gui=italic
]])

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Enable mouse
vim.opt.mouse = "a"

-- Sync clipboard between OS and Neovim
vim.opt.clipboard = "unnamedplus"

-- Enable break indent
vim.opt.breakindent = true

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Decrease update time
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live
vim.opt.inccommand = 'split'

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor
vim.opt.scrolloff = 10
OPTIONS_EOF
          fi

          # Run neovim
          exec ${neovimPackage}/bin/nvim "$@"
        '';

        # Build a combined package with all tools
        lazyVimPackage = pkgs.buildEnv {
          name = "lazyvim-with-tools";
          paths = [ lazyVimWrapper ] ++ allDeps ++ [ victorMonoNerdFont ];
        };

      in
      {
        packages = {
          default = lazyVimPackage;
          lvim = lazyVimWrapper;
          neovim = neovimPackage;
        };

        apps.default = {
          type = "app";
          program = "${lazyVimWrapper}/bin/lvim";
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [ lazyVimPackage ];
          
          shellHook = ''
            echo "LazyVim development environment"
            echo "Run 'lvim' to start LazyVim"
            echo ""
            echo "Included tools:"
            echo "  - Neovim with LazyVim"
            echo "  - LSP servers for: Lua, Nix, Python, JS/TS, Go, Rust, Bash, YAML, Markdown, Docker, Terraform"
            echo "  - Formatters: stylua, nixfmt, black, prettier, gofumpt, rustfmt, shfmt"
            echo "  - Linters: ruff, pylint, eslint, shellcheck, markdownlint, yamllint"
            echo "  - Debuggers: debugpy, delve"
            echo "  - Additional: lazygit, ripgrep, fd, fzf, tree-sitter"
            echo "  - Font: VictorMono Nerd Font"
            echo ""
            echo "Configuration directory: ~/.config/nvim"
          '';
        };

        formatter = pkgs.nixfmt;
      }
    );
}