vim.o.number = true
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

vim.o.relativenumber = true
vim.o.mouse = "a"
vim.o.showmode = false

-- Sync clipboard between OS and Neovim.
vim.schedule(function()
	vim.o.clipboard = "unnamedplus"
end)

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = "yes"

-- Decrease update time
vim.o.updatetime = 250

-- Decrease mapped sequence wait time
vim.o.timeoutlen = 300

-- Configure how new splits should be opened
vim.o.splitright = true
vim.o.splitbelow = true

vim.o.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.o.inccommand = "split"
vim.o.cursorline = true

vim.o.scrolloff = 10
vim.o.confirm = true

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.hl.on_yank()
	end,
})

vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH
vim.lsp.enable({ "lua_ls", "gopls", "ts_ls", "html", "cssls" })


require("config.jdtls")


vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp-keymaps", { clear = true }),
	callback = function(ev)
		local bufnr = ev.buf
		local function map(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, noremap = true, desc = desc })
		end

		map("n", "K", vim.lsp.buf.hover, "LSP Hover")
		-- In Neovim 0.12, vim.lsp.buf.definition() uses buf_request_all internally
		-- and positions the cursor synchronously at line 255 of buf.lua — before any
		-- async java/classFileContents response can populate a jdt:// buffer.
		-- on_list intercepts at line 225, before the cursor move, giving us control.
		map("n", "<leader>cd", function()
			vim.lsp.buf.definition({
				on_list = function(list_opts)
					if #list_opts.items == 0 then
						vim.notify("No locations found", vim.log.levels.INFO)
						return
					end
					local item = list_opts.items[1]
					-- jdt:// URI: fetch decompiled content first, then jump
					if #list_opts.items == 1 and item.filename:match("^jdt://") then
						local client = vim.lsp.get_clients({ name = "jdtls" })[1]
						if not client then return end
						client:request("java/classFileContents", { uri = item.filename }, function(_, content)
							if not content then return end
							local b = vim.fn.bufadd(item.filename)
							vim.bo[b].modifiable = true
							vim.api.nvim_buf_set_lines(b, 0, -1, false, vim.split(content, "\n"))
							vim.bo[b].filetype = "java"
							vim.bo[b].buftype = "nofile"
							vim.bo[b].modifiable = false
							vim.bo[b].modified = false
							vim.cmd("normal! m'")
							vim.api.nvim_set_current_buf(b)
							vim.api.nvim_win_set_cursor(0, { item.lnum, item.col - 1 })
						end)
						return
					end
					-- Single regular file: jump directly
					if #list_opts.items == 1 then
						local b = item.bufnr or vim.fn.bufadd(item.filename)
						vim.cmd("normal! m'")
						vim.api.nvim_set_current_buf(b)
						vim.api.nvim_win_set_cursor(0, { item.lnum, item.col - 1 })
						return
					end
					-- Multiple results: show in quickfix
					vim.fn.setqflist({}, " ", { title = list_opts.title, items = list_opts.items })
					vim.cmd("botright copen")
				end,
			})
		end, "Go to definition")
		map("n", "<leader>cr", vim.lsp.buf.references, "References")
		map("n", "<leader>ci", vim.lsp.buf.implementation, "Go to implementation")
		map("n", "<leader>cn", vim.lsp.buf.rename, "Rename symbol")
		map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
		map("n", "<leader>cx", vim.diagnostic.open_float, "Show exception details")
		map("n", "<leader>f", function()
			vim.lsp.buf.format({ async = true })
		end, "Format buffer")

		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client and client.name == "jdtls" then
			local jdtls = require("jdtls")
			map("n", "<leader>ctc", jdtls.test_class, "Test Class")
			map("n", "<leader>ctm", jdtls.test_nearest_method, "Test Nearest Method")
		end

		if client and client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, ev.data.client_id, bufnr, { autotrigger = true })
			vim.keymap.set("i", "<C-n>", function()
				return vim.fn.pumvisible() == 1 and "<C-n>" or "<C-x><C-o>"
			end, { buffer = bufnr, expr = true, desc = "Next completion item" })
			vim.keymap.set("i", "<C-p>", function()
				return vim.fn.pumvisible() == 1 and "<C-p>" or "<C-p>"
			end, { buffer = bufnr, expr = true, desc = "Previous completion item" })
			vim.keymap.set("i", "<C-y>", function()
				return vim.fn.pumvisible() == 1 and "<C-y>" or "<C-y>"
			end, { buffer = bufnr, expr = true, desc = "Confirm completion" })
		end
	end,
})

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		error("Error cloning lazy.nvim:\n" .. out)
	end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

require("lazy").setup({
	{ import = "plugins" },
}, {
	ui = {
		-- If you are using a Nerd Font: set icons to an empty table which will use the
		-- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
		icons = vim.g.have_nerd_font and {} or {
			cmd = "⌘",
			config = "🛠",
			event = "📅",
			ft = "📂",
			init = "⚙",
			keys = "🗝",
			plugin = "🔌",
			runtime = "💻",
			require = "🌙",
			source = "📄",
			start = "🚀",
			task = "📌",
			lazy = "💤 ",
		},
	},
})
