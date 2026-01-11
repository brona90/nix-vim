# Nix LazyVim Flake

Declarative and reproducible LazyVim setup using Nix flakes.

## Features

- **Full LazyVim distribution** with sensible defaults
- **Comprehensive tooling** - LSP servers, formatters, linters, and debuggers pre-installed
- **VictorMono Nerd Font** with beautiful cursive italics
- **Cross-platform support** - Works on Linux and macOS (Intel & Apple Silicon)
- **Zero manual setup** - All dependencies managed by Nix
- **Isolated environment** - Won't interfere with other Neovim installations

## Quick Start

```bash
# Run LazyVim directly from the flake
nix run github:yourusername/nix-lazyvim

# Or clone and run locally
git clone https://github.com/yourusername/nix-lazyvim
cd nix-lazyvim
nix run .

# Build and install
nix build .
./result/bin/lvim
```

## What's Included

### Language Servers (LSP)
- **Lua** - lua-language-server
- **Nix** - nil, nixd
- **Python** - pyright, ruff
- **JavaScript/TypeScript** - typescript-language-server, vscode-langservers-extracted
- **Go** - gopls
- **Rust** - rust-analyzer
- **Bash** - bash-language-server
- **YAML** - yaml-language-server
- **TOML** - taplo
- **Markdown** - marksman
- **Docker** - dockerfile-language-server
- **Terraform** - terraform-ls

### Formatters
- **Lua** - stylua
- **Nix** - nixfmt, alejandra
- **Python** - black, isort
- **JavaScript/TypeScript** - prettier
- **Go** - gofumpt
- **Rust** - rustfmt
- **Shell** - shfmt
- **Markdown/YAML/JSON** - prettier

### Linters
- **Python** - ruff, pylint
- **JavaScript/TypeScript** - eslint
- **Shell** - shellcheck
- **Markdown** - markdownlint
- **YAML** - yamllint

### Debuggers
- **Python** - debugpy
- **Go** - delve
- **Node.js** - node-debug2

### Additional Tools
- **Git** - lazygit, delta
- **Search** - ripgrep, fd, fzf
- **Build tools** - gcc, make, cmake
- **Tree-sitter** - Parser generation and highlighting
- **VictorMono Nerd Font** - Beautiful programming font with ligatures

## Configuration

Your LazyVim configuration lives in `~/.config/nvim/`:

```
~/.config/nvim/
├── init.lua              # Entry point (auto-generated)
├── lua/
│   ├── config/
│   │   ├── options.lua   # Vim options and font settings
│   │   ├── keymaps.lua   # Custom keymaps
│   │   └── autocmds.lua  # Autocommands
│   └── plugins/
│       ├── fonts.lua     # Theme and font config (auto-generated)
│       └── *.lua         # Your custom plugin configurations
```

The flake automatically creates starter configuration files if they don't exist.

## Customization

### Add Language Support

Enable LazyVim language extras by creating a plugin file:

```lua
-- ~/.config/nvim/lua/plugins/lang.lua
return {
  { import = "lazyvim.plugins.extras.lang.typescript" },
  { import = "lazyvim.plugins.extras.lang.python" },
  { import = "lazyvim.plugins.extras.lang.rust" },
  { import = "lazyvim.plugins.extras.lang.go" },
}
```

### Change Font Settings

Edit `~/.config/nvim/lua/config/options.lua`:

```lua
-- Change font size
vim.opt.guifont = "VictorMono Nerd Font:h16"

-- Disable italics
vim.cmd([[
  highlight Comment cterm=NONE gui=NONE
  highlight Keyword cterm=NONE gui=NONE
]])
```

### Add More Plugins

Create any `.lua` file in `~/.config/nvim/lua/plugins/`:

```lua
-- ~/.config/nvim/lua/plugins/extras.lua
return {
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {},
  },
}
```

## Development Environment

```bash
# Enter development shell with all tools
nix develop

# This provides:
# - lvim command to launch LazyVim
# - All LSP servers, formatters, linters
# - Development tools (git, ripgrep, fd, etc.)
# - VictorMono Nerd Font
```

## Updating

```bash
# Update flake inputs (Neovim, nixpkgs, etc.)
nix flake update

# Rebuild
nix build .
```

## Platform Support

This flake supports:
- `x86_64-linux` - Linux (Intel/AMD)
- `aarch64-linux` - Linux (ARM64)
- `x86_64-darwin` - macOS (Intel)
- `aarch64-darwin` - macOS (Apple Silicon)

## Troubleshooting

### Mason wants to install packages

LazyVim uses Mason by default, but this flake provides all tools via Nix. If Mason tries to install packages:

1. Use `:Mason` to see the Mason UI
2. Press `X` to uninstall any Mason-managed packages
3. The Nix-provided versions will be used automatically

### Font not appearing correctly

Make sure you're using a terminal that supports Nerd Fonts:
- **Recommended**: Kitty, Alacritty, WezTerm, iTerm2
- Configure your terminal to use "VictorMono Nerd Font"

### LSP server not working

Check if the server is available:
```bash
# In the dev shell
which lua-language-server
which pyright
```

All servers should be in your PATH when using the flake.

## LazyVim Resources

- [LazyVim Documentation](https://www.lazyvim.org)
- [LazyVim GitHub](https://github.com/LazyVim/LazyVim)
- [Keymaps Reference](https://www.lazyvim.org/keymaps)
- [Plugin Configuration](https://www.lazyvim.org/plugins)

## License

This flake configuration is provided as-is. LazyVim and included plugins have their own licenses.

---

Built with ❄️ using [Nix](https://nixos.org), [Neovim](https://neovim.io), and [LazyVim](https://www.lazyvim.org).

Happy coding! 🚀