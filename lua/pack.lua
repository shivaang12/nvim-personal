vim.pack.add({
    "https://github.com/nyoom-engineering/oxocarbon.nvim",
    "https://github.com/nvim-mini/mini.nvim",
    { src = "https://github.com/nvim-treesitter/nvim-treesitter", branch = "main" },
    { src = 'https://github.com/neovim/nvim-lspconfig' },
    "https://github.com/akinsho/bufferline.nvim",
    "https://github.com/m4xshen/autoclose.nvim",
    "https://github.com/ibhagwan/fzf-lua",
    "https://github.com/rmagatti/auto-session",
    'https://github.com/nvim-tree/nvim-web-devicons',
    'https://github.com/nvim-lualine/lualine.nvim',
})

-- mini files ----
local MiniFiles = require("mini.files")
MiniFiles.setup({
    mappings = {
        go_in = "<CR>",
        go_in_plus = "L",
        go_out = "_",
        go_out_plus = "H",
    },
})

vim.keymap.set("n", "-", "<cmd>lua MiniFiles.open()<CR>", { desc = "Toggle mini file explorer" })
vim.keymap.set("n", "<leader>-", function()
    MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
    MiniFiles.reveal_cwd()
end, { desc = "Toggle into currently opened file" })

-- Mini Files Autocmd for copying filepath
vim.api.nvim_create_autocmd('User', {
    pattern = 'MiniFilesBufferCreate',
    callback = function(args)
        local buf_id = args.data.buf_id

        -- Tweak the key binding ('yp') to whatever you prefer
        vim.keymap.set('n', 'yp', function()
            local entry = MiniFiles.get_fs_entry()
            if entry and entry.path then
                -- '+' uses the system clipboard. Use '"' for the unnamed register.
                vim.fn.setreg('+', entry.path)
                print('Yanked path: ' .. entry.path)
            end
        end, { buffer = buf_id, desc = 'Yank file path to clipboard' })

        -- 2. Yank relative path (mapped to 'yr')
        vim.keymap.set('n', 'yr', function()
            local entry = MiniFiles.get_fs_entry()
            if entry and entry.path then
                -- The ':.' modifier makes the path relative to the current working directory
                local rel_path = vim.fn.fnamemodify(entry.path, ':.')
                vim.fn.setreg('+', rel_path)
                print('Yanked relative: ' .. rel_path)
            end
        end, { buffer = buf_id, desc = 'Yank relative path to clipboard' })
    end,
})

---- mini notify ----
require("mini.notify").setup({
    -- only show messages
    content = {
        format = function(notif)
            return notif.msg
        end,
    },
})

--- mini cmdline completion ---
require("mini.cmdline").setup({
    autocorrect = { enable = false }
})

--- mini surround ---
require("mini.surround").setup()
-- Default Keymaps
-- | `sa` | Add surrounding or Direct with 'saiw' |
-- | `sd` | Delete surrounding |
-- | `sr` | Replace surrounding |
-- | `sf` | Find surrounding (right) |
-- | `sF` | Find surrounding (left) |
-- | `sh` | Highlight surrounding |
-- | `sn` | Update n_lines |
-- | `l` / `n` | as suffix for prev/next |

--- mini picker ---
-- local MiniPick = require("mini.pick")
local MiniExtra = require("mini.extra")
-- MiniPick.setup()
MiniExtra.setup()
--
-- -- keymaps for Minipick and MiniExtra
-- vim.keymap.set("n", "<leader>ff", function() MiniPick.builtin.files() end, { desc = "Mini File Picker" })
-- vim.keymap.set("n", "<leader>fs", function() MiniPick.builtin.grep({ pattern = vim.fn.expand("<cword>") }) end,
--     { desc = "Grep word/Search word" })
vim.keymap.set("n", "<leader>vh", "<cmd>FzfLua helptags<CR>", { desc = "FzF lua Help" })
--
vim.keymap.set("n", "<leader>xx", function() MiniExtra.pickers.diagnostic() end, { desc = "Mini Picker Diagnostics" })
vim.keymap.set("n", "<leader>fk", function() MiniExtra.pickers.keymaps() end, { desc = 'Search keymaps' })
--
-- fzf lua config --
require("fzf-lua").setup({"default"})

-- FzF Lua Keybindings --
vim.keymap.set("n", "<leader>ff", "<cmd>FzfLua files<CR>", { desc = "Search files" })
vim.keymap.set("n", "<leader>fw", "<cmd>FzfLua live_grep<CR>", { desc = "Search words grep" })
vim.keymap.set("n", "<leader>fb", "<cmd>FzfLua blines<CR>", { desc = "Search words grep in the current buffer" })

--- mini completions ---
require("mini.completion").setup({
    lsp_completion = {
        auto_setup = true,
    }
})

--nvim treesitter --
require("treesitter")

-- nvim lsp --
require("lsp")

--
require("bufferline").setup({
    options = {
        mode = "buffers", -- Set to "tabs" to only show tabpages instead
        style_preset = require("bufferline").style_preset.default,
        themable = true,
        numbers = "none", -- Options: "none" | "ordinal" | "buffer_id"

        -- Diagnostics integration: this connects to lua_ls and ty
        diagnostics = "nvim_lsp",
        diagnostics_update_in_insert = false,
        diagnostics_indicator = function(count, level, diagnostics_dict, context)
            local icon = level:match("error") and " " or " "
            return " " .. icon .. count
        end,

        -- Aesthetics
        separator_style = "slant", -- Options: "slant" | "slope" | "thick" | "thin"
        enforce_regular_tabs = false,
        always_show_bufferline = true,
        show_buffer_close_icons = true,
        show_close_icon = false, -- The overall close-all-buffers icon on the right
        color_icons = true,

        -- Behavior
        max_name_length = 18,
        max_prefix_length = 15,
        tab_size = 18,

        -- Groups allow you to separate files by directory or type
        groups = {
            options = {
                toggle_hidden_on_enter = true,
            },
            items = {
                require('bufferline.groups').builtin.pinned:with({ icon = "" }),
            }
        },

        -- Exclude specific sidebar windows from messing up the alignment
        offsets = {
            {
                filetype = "NvimTree",
                text = "File Explorer",
                highlight = "Directory",
                text_align = "left",
                separator = true
            }
        },
    }
})

-- Keymaps buffer --
-- Navigate between buffers
vim.keymap.set("n", "<S-h>", "<Cmd>BufferLineCyclePrev<CR>", { desc = "Previous buffer" })
vim.keymap.set("n", "<S-l>", "<Cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })

-- Re-order buffers
-- vim.keymap.set("n", "<A-<>", "<Cmd>BufferLineMovePrev<CR>", { desc = "Move buffer left" })
-- vim.keymap.set("n", "<A->>", "<Cmd>BufferLineMoveNext<CR>", { desc = "Move buffer right" })

-- Pick a specific buffer (shows a letter over each tab to jump instantly)
vim.keymap.set("n", "<leader>bp", "<Cmd>BufferLinePick<CR>", { desc = "Pick buffer" })

-- Pin/Unpin the current buffer
vim.keymap.set("n", "<leader>bP", "<Cmd>BufferLineTogglePin<CR>", { desc = "Toggle buffer pin" })

-- Close current buffer safely
vim.keymap.set("n", "<leader>bc", "<Cmd>bdelete<CR>", { desc = "Close buffer" })

-- autoclose --
require("autoclose").setup()

-- autosession --
require("auto-session").setup({})

-- lualine --
require('lualine').setup()
