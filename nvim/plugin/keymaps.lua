local M = {}

local api = vim.api
local fn = vim.fn
local keymap = vim.keymap
local diagnostic = vim.diagnostic

-- Automatic management of search highlight
local auto_hlsearch_namespace = vim.api.nvim_create_namespace('auto_hlsearch')
vim.on_key(function(char)
  if vim.fn.mode() == 'n' then
    vim.opt.hlsearch = vim.tbl_contains({ '<CR>', 'n', 'N', '*', '#', '?', '/' }, vim.fn.keytrans(char))
  end
end, auto_hlsearch_namespace)

-- Yank from current position till end of current line
keymap.set('n', 'Y', 'y$', { silent = true, desc = 'yank to end of line' })

-- Buffer list navigation
-- keymap.set('n', '[b', vim.cmd.bprevious, { silent = true, desc = 'previous buffer' })
-- keymap.set('n', ']b', vim.cmd.bnext, { silent = true, desc = 'next buffer' })
-- keymap.set('n', '[B', vim.cmd.bfirst, { silent = true, desc = 'first buffer' })
-- keymap.set('n', ']B', vim.cmd.blast, { silent = true, desc = 'last buffer' })

-- Toggle the quickfix list (only opens if it is populated)
local function toggle_qf_list()
  local qf_exists = false
  for _, win in pairs(fn.getwininfo() or {}) do
    if win['quickfix'] == 1 then
      qf_exists = true
    end
  end
  if qf_exists == true then
    vim.cmd.cclose()
    return
  end
  if not vim.tbl_isempty(vim.fn.getqflist()) then
    vim.cmd.copen()
  end
end

keymap.set('n', '<C-c>', toggle_qf_list, { desc = 'toggle quickfix list' })

local function try_fallback_notify(opts)
  local success, _ = pcall(opts.try)
  if success then
    return
  end
  success, _ = pcall(opts.fallback)
  if success then
    return
  end
  vim.notify(opts.notify, vim.log.levels.INFO)
end

-- Cycle the quickfix and location lists
local function cleft()
  try_fallback_notify {
    try = vim.cmd.cprev,
    fallback = vim.cmd.clast,
    notify = 'Quickfix list is empty!',
  }
end

local function cright()
  try_fallback_notify {
    try = vim.cmd.cnext,
    fallback = vim.cmd.cfirst,
    notify = 'Quickfix list is empty!',
  }
end

local opts = { silent = true }

keymap.set('n', '[c', cleft, { silent = true, desc = 'cycle quickfix left' })
keymap.set('n', ']c', cright, { silent = true, desc = 'cycle quickfix right' })
keymap.set('n', '[C', vim.cmd.cfirst, { silent = true, desc = 'first quickfix entry' })
keymap.set('n', ']C', vim.cmd.clast, { silent = true, desc = 'last quickfix entry' })

local function lleft()
  try_fallback_notify {
    try = vim.cmd.lprev,
    fallback = vim.cmd.llast,
    notify = 'Location list is empty!',
  }
end

local function lright()
  try_fallback_notify {
    try = vim.cmd.lnext,
    fallback = vim.cmd.lfirst,
    notify = 'Location list is empty!',
  }
end

keymap.set('n', '[l', lleft, { silent = true, desc = 'cycle loclist left' })
keymap.set('n', ']l', lright, { silent = true, desc = 'cycle loclist right' })
keymap.set('n', '[L', vim.cmd.lfirst, { silent = true, desc = 'first loclist entry' })
keymap.set('n', ']L', vim.cmd.llast, { silent = true, desc = 'last loclist entry' })

-- Resize vertical splits
local toIntegral = math.ceil
keymap.set('n', '<leader>w+', function()
  local curWinWidth = api.nvim_win_get_width(0)
  api.nvim_win_set_width(0, toIntegral(curWinWidth * 3 / 2))
end, { silent = true, desc = 'inc window width' })
keymap.set('n', '<leader>w-', function()
  local curWinWidth = api.nvim_win_get_width(0)
  api.nvim_win_set_width(0, toIntegral(curWinWidth * 2 / 3))
end, { silent = true, desc = 'dec window width' })
keymap.set('n', '<leader>h+', function()
  local curWinHeight = api.nvim_win_get_height(0)
  api.nvim_win_set_height(0, toIntegral(curWinHeight * 3 / 2))
end, { silent = true, desc = 'inc window height' })
keymap.set('n', '<leader>h-', function()
  local curWinHeight = api.nvim_win_get_height(0)
  api.nvim_win_set_height(0, toIntegral(curWinHeight * 2 / 3))
end, { silent = true, desc = 'dec window height' })

-- Remap Esc to switch to normal mode and Ctrl-Esc to pass Esc to terminal
keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = 'switch to normal mode' })
keymap.set('t', '<C-Esc>', '<Esc>', { desc = 'send Esc to terminal' })

-- Shortcut for expanding to current buffer's directory in command mode
keymap.set('c', '%%', function()
  if fn.getcmdtype() == ':' then
    return fn.expand('%:h') .. '/'
  else
    return '%%'
  end
end, { expr = true, desc = "expand to current buffer's directory" })

keymap.set('n', '<leader>to', vim.cmd.tabnew, { desc = 'new tab' })
keymap.set('n', '<leader>tn', vim.cmd.tabn, { desc = 'next tab' })
keymap.set('n', '<leader>tp', vim.cmd.tabp, { desc = 'previous tab' })
keymap.set('n', '<leader>tx', vim.cmd.tabclose, { desc = 'close tab' })

-- Switch between tabs
vim.keymap.set('n', '<Right>', function()
  vim.cmd([[checktime]])
  vim.api.nvim_feedkeys('gt', 'n', true)
end)

vim.keymap.set('n', '<Left>', function()
  vim.cmd([[checktime]])
  vim.api.nvim_feedkeys('gT', 'n', true)
end)

local severity = diagnostic.severity

keymap.set('n', '<space>e', function()
  local _, winid = diagnostic.open_float(nil, { scope = 'line' })
  vim.api.nvim_win_set_config(winid or 0, { focusable = true })
end, { noremap = true, silent = true, desc = 'diagnostics floating window' })
keymap.set('n', '[d', diagnostic.goto_prev, { noremap = true, silent = true, desc = 'previous diagnostic' })
keymap.set('n', ']d', diagnostic.goto_next, { noremap = true, silent = true, desc = 'next diagnostic' })
keymap.set('n', '[e', function()
  diagnostic.goto_prev {
    severity = severity.ERROR,
  }
end, { noremap = true, silent = true, desc = 'previous error diagnostic' })
keymap.set('n', ']e', function()
  diagnostic.goto_next {
    severity = severity.ERROR,
  }
end, { noremap = true, silent = true, desc = 'next error diagnostic' })
keymap.set('n', '[w', function()
  diagnostic.goto_prev {
    severity = severity.WARN,
  }
end, { noremap = true, silent = true, desc = 'previous warning diagnostic' })
keymap.set('n', ']w', function()
  diagnostic.goto_next {
    severity = severity.WARN,
  }
end, { noremap = true, silent = true, desc = 'next warning diagnostic' })
keymap.set('n', '[h', function()
  diagnostic.goto_prev {
    severity = severity.HINT,
  }
end, { noremap = true, silent = true, desc = 'previous hint diagnostic' })
keymap.set('n', ']h', function()
  diagnostic.goto_next {
    severity = severity.HINT,
  }
end, { noremap = true, silent = true, desc = 'next hint diagnostic' })

local function toggle_spell_check()
  ---@diagnostic disable-next-line: param-type-mismatch
  vim.opt.spell = not (vim.opt.spell:get())
end

keymap.set('n', '<leader>S', toggle_spell_check, { noremap = true, silent = true, desc = 'toggle spell' })

keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'move down half-page and center' })
keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'move up half-page and center' })
keymap.set('n', '<C-f>', '<C-f>zz', { desc = 'move down full-page and center' })
keymap.set('n', '<C-b>', '<C-b>zz', { desc = 'move up full-page and center' })

---------------------
-- General Keymaps
---------------------

-- friendly commandline access
vim.keymap.set('n', ';', ':')
vim.keymap.set('n', ':', ';')
vim.keymap.set('v', ';', ':')
vim.keymap.set('v', ':', ';')

-- friendly visual-mode settings
-- vim.keymap.set("n", "v", "<C-V>")
-- vim.keymap.set("n", "<C-V>:", "v")
-- vim.keymap.set("x", "v", "<C-V>")
-- vim.keymap.set("x", "<C-V>", "v")

-- TODO: get alt to work for navigating up/down by 7 lines
vim.keymap.set('n', '<M-j>', '7j')
vim.keymap.set('n', '<M-k>', '7k')

-- delete single caracter without copying into register
vim.keymap.set('n', 'X', '"_x')

-- blackhole delete
vim.keymap.set('n', '<leader>d', '"_d')

-- Stay in indent mode
vim.keymap.set('v', '<', '<gv', opts)
vim.keymap.set('v', '>', '>gv', opts)

-- Run shell command
vim.keymap.set('n', '!', '!!$SHELL<CR>')
vim.keymap.set('n', '<leader>X', '<cmd>!chmod +x %<CR>', opts)

-- Quickly play macro from register q
vim.keymap.set('n', 'Q', '@q')
vim.keymap.set('v', 'Q', ':norm @q<cr>')
-- Select all text in buffer
vim.keymap.set('n', '<leader>a', 'ggVG')
-- Select previous pasted/yanked text
vim.keymap.set('n', 'gV', '`[v`]')

-- Copy to system clipboard
vim.keymap.set('v', '<leader>y', '"+y')
-- Copy to system clipboard, hightlight after copy
vim.keymap.set('v', '<C-y>', '"+ygv')

-- Show registers
vim.keymap.set('n', '<leader>r', ':registers<CR>')

-- Copy line without linefeed keeping cursor location
vim.keymap.set('n', '<leader>y', 'mz0y$`z')

-- Keep cursor location consistent search and join
-- vim.keymap.set("n", "n", "nzzzv")
-- vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set('n', 'J', 'mzJ`z')

-- Change/delete/yank in line
vim.keymap.set('o', 'il', ':<c-u>normal! $v0<CR>')

-- Make b inclusive
vim.keymap.set('o', 'b', 'vb')

-- tcsh-like cli navigation
vim.keymap.set('c', '<C-a>', '<home>')
vim.keymap.set('c', '<C-e>', '<end>')
vim.keymap.set('c', '<C-p>', '<up>')
vim.keymap.set('c', '<C-n>', '<down>')
vim.keymap.set('c', '<C-b>', '<left>')
vim.keymap.set('c', '<C-f>', '<right>')
vim.keymap.set('c', '<C-d>', '<Del>')
vim.keymap.set('c', '<C-h>', '<BS>')
vim.keymap.set('c', '<C-k>', '<C-f>D<C-c><C-c>:<Up>')
vim.keymap.set('c', '<M-b>', '<S-left>')
vim.keymap.set('c', '<M-f>', '<S-right>')
vim.keymap.set('c', '<M-BS>', '<C-w>')

return M
