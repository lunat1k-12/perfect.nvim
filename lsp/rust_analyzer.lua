return {
	cmd = { "rust-analyzer" },
	filetypes = { "rust" },
	-- Pin the toolchain for rust-analyzer (and every cargo/rustc it spawns).
	-- Neovim can inherit a stale RUSTUP_TOOLCHAIN (e.g. an old Homebrew Rust
	-- from a long-lived tmux/GUI session), which makes cargo metadata fail on
	-- newer manifests (resolver = "3" / edition 2024). Forcing "stable" uses
	-- the current default rustup toolchain regardless of the inherited env.
	cmd_env = { RUSTUP_TOOLCHAIN = "stable" },
	-- Root at the Cargo *workspace* root, not the nearest member crate.
	-- Opening a member (e.g. multylib/add_one/src/lib.rs) with plain
	-- root_markers would root at add_one/ and break workspace analysis.
	-- Walk upward and pick the outermost Cargo.toml that declares
	-- [workspace]; fall back to the nearest crate root.
	root_dir = function(bufnr, on_dir)
		local fname = vim.api.nvim_buf_get_name(bufnr)
		local dir = vim.fs.dirname(fname)
		-- All ancestor Cargo.toml files, nearest first.
		local cargos = vim.fs.find("Cargo.toml", { path = dir, upward = true, limit = math.huge })
		local workspace_dir
		for _, cargo in ipairs(cargos) do
			local lines = vim.fn.readfile(cargo)
			for _, line in ipairs(lines) do
				-- match a "[workspace]" section header (ignoring whitespace)
				if line:match("^%s*%[workspace%]") then
					workspace_dir = vim.fs.dirname(cargo)
					break
				end
			end
		end
		-- outermost [workspace] wins; else nearest crate/marker.
		on_dir(workspace_dir or vim.fs.root(bufnr, { "Cargo.toml", "Cargo.lock", ".git" }))
	end,
	settings = {
		["rust-analyzer"] = {
			cargo = { allFeatures = true },
			check = { command = "clippy" },
			procMacro = { enable = true },
		},
	},
}
