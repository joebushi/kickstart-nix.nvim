local cmd = vim.cmd
local fn = vim.fn
local opt = vim.o
local g = vim.g

cmd.syntax('on')
cmd.syntax('enable')
opt.compatible = false

-- Enable true colour support
if fn.has('termguicolors') then
  opt.termguicolors = true
end

-- See :h <option> to see what the options do

-- Search down into subfolders
opt.path = vim.o.path .. '**'

opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.lazyredraw = true
opt.showmatch = true -- Highlight matching parentheses, etc
opt.incsearch = true
opt.hlsearch = true
-- opt.iskeyword:append('-') -- consider string-string as whole word

opt.spell = true
opt.spelllang = 'en'

opt.expandtab = true
opt.tabstop = 2
opt.softtabstop = 2
opt.shiftwidth = 2
opt.foldenable = true
opt.history = 2000
opt.nrformats = 'bin,hex' -- 'octal'
opt.undofile = true
opt.splitright = true
opt.splitbelow = true
opt.cmdheight = 0

opt.ttyfast = true -- faster scrolling
opt.list = true
opt.listchars = 'tab:→ ,nbsp:␣,space:·,trail:·'
opt.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]

-- Preview substitutions live, as you type!
-- opt.inccommand = 'nosplit'

-- Configure Neovim diagnostic messages

local function prefix_diagnostic(prefix, diagnostic)
  return string.format(prefix .. ' %s', diagnostic.message)
end

local sign = function(opts)
  fn.sign_define(opts.name, {
    texthl = opts.name,
    text = opts.text,
    numhl = '',
  })
end
-- Requires Nerd fonts
sign { name = 'DiagnosticSignError', text = '󰅚' }
sign { name = 'DiagnosticSignWarn', text = '⚠' }
sign { name = 'DiagnosticSignInfo', text = 'ⓘ' }
sign { name = 'DiagnosticSignHint', text = '󰌶' }

vim.diagnostic.config {
  virtual_text = {
    prefix = '',
    format = function(diagnostic)
      local severity = diagnostic.severity
      if severity == vim.diagnostic.severity.ERROR then
        return prefix_diagnostic('󰅚', diagnostic)
      end
      if severity == vim.diagnostic.severity.WARN then
        return prefix_diagnostic('⚠', diagnostic)
      end
      if severity == vim.diagnostic.severity.INFO then
        return prefix_diagnostic('ⓘ', diagnostic)
      end
      if severity == vim.diagnostic.severity.HINT then
        return prefix_diagnostic('󰌶', diagnostic)
      end
      return prefix_diagnostic('■', diagnostic)
    end,
  },
  signs = true,
  update_in_insert = false,
  underline = true,
  severity_sort = true,
  float = {
    focusable = false,
    style = 'minimal',
    border = 'rounded',
    source = 'always',
    header = '',
    prefix = '',
  },
}

g.editorconfig = true
g.mapleader = ' '
g.maplocalleader = ' '

opt.textwidth = '80'
opt.colorcolumn = '+1'
opt.scrolloff = 6
opt.mouse = 'a'

-- TODO: get correct path to user home w/out username
-- ${config.users.users.myUser.home}
-- prevents truncated yanks, deletes, etc.
-- opt.viminfo = "'100,n$HOME/.vim/files/info/viminfo"

-- Native plugins
cmd.filetype('plugin', 'indent', 'on')
cmd.packadd('cfilter') -- Allows filtering the quickfix list with :cfdo

-- let sqlite.lua (which some plugins depend on) know where to find sqlite
vim.g.sqlite_clib_path = require('luv').os_getenv('LIBSQLITE')
