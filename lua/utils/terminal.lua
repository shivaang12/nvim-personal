-- Persist the buffer and window IDs across function calls
local term_buf = nil
local term_win = nil

local function toggle_terminal()
  -- 1. If the window is currently open and valid, hide it
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_win_hide(term_win)
    return
  end

  -- 2. Calculate center screen dimensions (80% of screen size)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  -- 3. Create or reuse the buffer
  -- false = not listed in `:ls`, true = scratch buffer
  if not term_buf or not vim.api.nvim_buf_is_valid(term_buf) then
    term_buf = vim.api.nvim_create_buf(false, true) 
  end

  -- 4. Define the floating window layout
  local win_opts = {
    relative = 'editor',
    width = width,
    height = height,
    col = col,
    row = row,
    style = 'minimal',
    border = 'rounded'
  }

  -- 5. Open the window
  term_win = vim.api.nvim_open_win(term_buf, true, win_opts)

  -- 6. If it's a brand new buffer, launch the terminal
  if vim.bo[term_buf].buftype ~= 'terminal' then
    vim.cmd('terminal')
  end
  
  -- Automatically enter insert mode when opening
  vim.cmd('startinsert')
end

-- Keymaps to toggle the terminal in Normal and Terminal mode
-- Change '<C-t>' to whatever shortcut you prefer
vim.keymap.set({'n', 't'}, '<C-t>', toggle_terminal, { desc = 'Toggle stateful floating terminal' })
