{ config, lib, pkgs, ... }:
let
  inherit (lib) types mkIf mkDefault mkOption;
  nvim-spell-ru-utf8-dictionary = builtins.fetchurl {
    url = "https://ftp.nluug.nl/pub/vim/runtime/spell/ru.utf-8.spl";
    sha256 = "eb2d3bd78a2020b30bcc0a7cfebdacebfb7a427581114f66b88a577ae6dac54d";
  };
  nvim-spell-ru-utf8-suggestions = builtins.fetchurl {
    url = "https://ftp.nluug.nl/pub/vim/runtime/spell/ru.utf-8.sug";
    sha256 = "eabd86168ad85d5bfb8068808cf7982bab0374afc299cb49ecc89d71616f393b";
  };
  nvim-spell-en-utf8-dictionary = builtins.fetchurl {
    url = "https://ftp.nluug.nl/pub/vim/runtime/spell/en.utf-8.spl";
    sha256 = "fecabdc949b6a39d32c0899fa2545eab25e63f2ed0a33c4ad1511426384d3070";
  };
  nvim-spell-en-utf8-suggestions = builtins.fetchurl {
    url = "https://ftp.nluug.nl/pub/vim/runtime/spell/en.utf-8.sug";
    sha256 = "5b6e5e6165582d2fd7a1bfa41fbce8242c72476222c55d17c2aa2ba933c932ec";
  };
in {
  options.my-config = {
    nvim.enable = mkOption {
      description = "Enable my customized git";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf config.my-config.nvim.enable {
    home-manager.users.wrbbz = {
      home.sessionVariables = {
        EDITOR = "nvim";
      };

      programs.neovim = {
        enable = true;
        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;
        defaultEditor = true;
        extraConfig = ''
          " Show current line and distance from it
          set rnu
          set nu

          " Tabbulation
          set autoindent   " Indent according to previous line.
          set expandtab
          set tabstop=2
          set softtabstop=2
          set shiftwidth=2

          set nowrap

          " Undo tree for the win
          set noswapfile
          set nobackup
          set undodir=~/.local/share/nvim/undodir
          set undofile

          set nohlsearch
          set incsearch

          set scrolloff=5
          set sidescrolloff=5

          set colorcolumn=80

          " Show tabs and trailing whitespace
          set list
          set listchars=tab:▸\ ,trail:·

          " migh not be needed with vimlastplace
          set viminfo='10,\"100,:20,%,n~/.viminfo

          " Fixes file creation in netrw
          set shell=/etc/profiles/per-user/wrbbz/bin/zsh

          " Navigation with russian layout
          set langmap=!\\"№\\;%?*ёйцукенгшщзхъфывапролджэячсмитьбюЁЙЦУКЕHГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ;!@#$%&*`qwertyuiop[]asdfghjkl\\;'zxcvbnm\\,.~QWERTYUIOP{}ASDFGHJKL:\\"ZXCVBNM<>

          " ssh config.d/* syntax highlighting
          autocmd BufRead,BufNewFile ~/.ssh/config.d/**/* set syntax=sshconfig
          autocmd BufRead,BufNewFile ~/.ssh/config.d/* set syntax=sshconfig

          set spell spelllang=en,ru

          " Disable mouse support
          set mouse=

          " Better window navigation
          nnoremap <C-h> <C-w>h
          nnoremap <C-j> <C-w>j
          nnoremap <C-k> <C-w>k
          nnoremap <C-l> <C-w>l
          " Split vetically with ctrl+| and horizontally with ctrl+/

          nnoremap <leader>pv :Explore<cr>
        '';
        initLua = ''
          vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
          vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

          vim.keymap.set("n", "<C-d>", "<C-d>zz")
          vim.keymap.set("n", "<C-u>", "<C-u>zz")
          vim.keymap.set("n", "n", "nzz")
          vim.keymap.set("n", "N", "Nzz")

          -- clipboard management
          vim.keymap.set("x", "<leader>p", '"_dP')
          vim.keymap.set("n", "<leader>y", "\"+y")
          vim.keymap.set("v", "<leader>y", "\"+y")
          vim.keymap.set("n", "<leader>Y", "\"+Y")
          vim.keymap.set("n", "<leader>d", "\"_d")
          vim.keymap.set("v", "<leader>d", "\"_d")

          -- float management
          vim.keymap.set("n", "<leader>fo", vim.diagnostic.open_float)
          vim.keymap.set("n", "<leader>fn", vim.diagnostic.goto_next)
          vim.keymap.set("n", "<leader>fp", vim.diagnostic.goto_prev)
        '';
        plugins = with pkgs.vimPlugins; [
          {
            plugin = vim-airline;
            config = ''
              let g:airline_powerline_fonts = 1
            '';
          }
          {
            plugin = copilot-lua;
            type = "lua";
            config = ''
              require("copilot").setup({
                suggestion = { enable = false },
                panel = { enable = false },
              })
              -- wait for the Copilot command (the end of a sync cycle)
              vim.defer_fn(function()
                vim.cmd('Copilot disable')
              end, 0)
            '';
          }
          {
            plugin = copilot-cmp;
            type = "lua";
            config = ''
              require("copilot_cmp").setup()
            '';
          }
          {
            plugin = gruvbox-community;
            type = "lua";
            config = ''
              vim.o.termguicolors = true
              vim.cmd [[colorscheme gruvbox]]
              vim.o.background = "dark"
            '';
          }
          vim-just
          vim-nix
          vim-table-mode
          YankRing-vim
          {
            plugin = telescope-nvim;
            config = ''
              let g:telescope_previewer = 'bat'
              " mapleader defined here because extraConfig is evaluated after plugins
              let mapleader = "\<Space>"
              nnoremap <leader>ff <cmd>Telescope find_files<cr>
              nnoremap <leader>fg <cmd>Telescope git_files<cr>
              nnoremap <leader>fl <cmd>Telescope live_grep<cr>
            '';
          }
          {
            plugin = nvim-treesitter;
            type = "lua";
            config = ''
              vim.api.nvim_create_autocmd("FileType", {
                callback = function()
                  pcall(vim.treesitter.start)
                end,
              })
            '';
          }
          (nvim-treesitter.withPlugins (p: [
            p.astro
            p.bash
            p.css
            p.dockerfile
            p.git_config
            p.git_rebase
            p.gitcommit
            p.gitignore
            p.go
            p.hjson
            p.html
            p.javascript
            p.json
            p.latex
            p.lua
            p.markdown
            p.nix
            p.python
            p.rust
            p.sql
            p.terraform
            p.toml
            p.typescript
            p.yaml
          ]))
          {
            plugin = nvim-colorizer-lua;
            type = "lua";
            config = ''
              require 'colorizer'.setup{
                user_default_options = {
                  mode = "virtualtext";
                },
              }
            '';
          }
          {
            plugin = harpoon2;
            type = "lua";
            config = ''
              local harpoon = require("harpoon")
              harpoon:setup()

              vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
              vim.keymap.set("n", "<A-g>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

              vim.keymap.set("n", "<A-a>", function() harpoon:list():select(1) end)
              vim.keymap.set("n", "<A-s>", function() harpoon:list():select(2) end)
              vim.keymap.set("n", "<A-d>", function() harpoon:list():select(3) end)
              vim.keymap.set("n", "<A-f>", function() harpoon:list():select(4) end)

              vim.keymap.set("n", "C-k", "<cmd>cnext<CR>zz")
              vim.keymap.set("n", "C-j", "<cmd>cprev<CR>zz")
              vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
              vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

              vim.keymap.set("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>")
            '';
          }
          vim-devicons
          {
            plugin = vim-fugitive;
            type = "lua";
            config = ''
              vim.keymap.set("n", "<leader>gs", ":Git<CR>")
              vim.keymap.set("n", "<leader>gb", ":Git blame<CR>")
            '';
          }
          # vim-rhubarb
          vim-signify
          vim-lastplace
          {
            plugin = undotree;
            type = "lua";
            config = ''
              vim.keymap.set("n", "<leader>u", ":UndotreeToggle<CR>")
            '';
          }
          nvim-lspconfig
          nvim-cmp
          luasnip
          cmp_luasnip
          cmp-nvim-lsp
          nvim-dap
          {
            plugin = nvim-dap-go;
            type = "lua";
            config = ''
              require("dap-go").setup {
                dap_configurations = {
                  program = "''${workspaceFolder}",
                  cwd = "''${workspaceRoot}",
                }
              }
              local dap = require("dap")

              vim.keymap.set('n', '<Leader>dc', ":DapContinue<CR>")
              vim.keymap.set('n', '<Leader>do', ":DapStepOver<CR>")
              vim.keymap.set('n', '<Leader>di', ":DapStepIn<CR>")
              vim.keymap.set('n', '<Leader>dO', ":DapStepOut<CR>")
              vim.keymap.set('n', '<Leader>db', ":DapToggleBreakpoint<CR>")
              vim.keymap.set('n', '<Leader>de', ":DapToggleBreakpoint<CR>")
            '';
          }
          {
            plugin = nvim-cmp;
            type = "lua";
            config = ''
              local cmp = require('cmp')
              local luasnip = require('luasnip')

              cmp.setup({
                snippet = {
                  expand = function(args)
                    luasnip.lsp_expand(args.body)
                  end,
                },
                window = {
                  completion = cmp.config.window.bordered(),
                  documentation = cmp.config.window.bordered(),
                },
                mapping = cmp.mapping.preset.insert({
                  -- Confirm completion with Enter
                  ['<CR>'] = cmp.mapping.confirm({select = false}),
                  -- Navigate completion with Tab and Shift-Tab
                  ['<Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                      cmp.select_next_item()
                    elseif luasnip.expand_or_jumpable() then
                      luasnip.expand_or_jump()
                    else
                      fallback()
                    end
                  end, { 'i', 's' }),
                  ['<S-Tab>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                      cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then
                      luasnip.jump(-1)
                    else
                      fallback()
                    end
                  end, { 'i', 's' }),
                  -- Initialize completion
                  ['<C-Space>'] = cmp.mapping.complete(),
                  -- Navigate documentation
                  ['<C-u>'] = cmp.mapping.scroll_docs(-4),
                  ['<C-d>'] = cmp.mapping.scroll_docs(4),
                }),
                sources = cmp.config.sources({
                  { name = 'nvim_lsp' },
                  { name = 'luasnip' },
                  { name = 'path' },
                }),
               })

              -- Setup language servers using native vim.lsp.enable()
              vim.lsp.enable('astro')
              vim.lsp.enable('bashls')
              vim.lsp.enable('eslint')
              vim.lsp.enable('gdscript')
              vim.lsp.enable('gitlab_ci_ls')
              vim.lsp.enable('gopls')
              vim.lsp.enable('html')
              vim.lsp.enable('htmx')
              vim.lsp.enable('ltex')
              vim.lsp.enable('nil_ls')
              vim.lsp.enable('pyright')
              vim.lsp.enable('tailwindcss')
              vim.lsp.enable('ts_ls')
              vim.lsp.enable('vale_ls')
              vim.lsp.enable('qmlls')

              vim.env.VALE_CONFIG_PATH = "~/.config/vale/vale.ini"
            '';
          }
          cmp-path
        ];
      };

      home.packages = with pkgs; [
        # dap dependencies
        delve
        # telescope dependencies
        bat
        fd
        fzf
        ripgrep
        # language servers
        nodePackages."@astrojs/language-server"
        nodePackages.typescript-language-server
        nodePackages.eslint
        rust-analyzer
        nil
        pyright
        gopls
        nodePackages.bash-language-server
        shellcheck
      ];

     #TODO: fix "${config.xdg.configHome} not working
     home.file."/home/wrbbz/.config/nvim/spell/ru.utf-8.spl".source = nvim-spell-ru-utf8-dictionary;
     home.file."/home/wrbbz/.config/nvim/spell/ru.utf-8.sug".source = nvim-spell-ru-utf8-suggestions;
     home.file."/home/wrbbz/.config/nvim/spell/en.utf-8.spl".source = nvim-spell-en-utf8-dictionary;
     home.file."/home/wrbbz/.config/nvim/spell/en.utf-8.sug".source = nvim-spell-en-utf8-suggestions;
    };
  };
}
