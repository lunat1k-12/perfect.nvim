-- nvim-jdtls is loaded only for its test runner API (test_class, test_nearest_method).
-- LSP management is handled by the native vim.lsp setup in init.lua.
return {
	"mfussenegger/nvim-jdtls",
	ft = "java",
}
