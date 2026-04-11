-- jdtls needs vim.schedule to defer startup out of any C call stack
-- (e.g. harpoon's bufload), otherwise client.request is nil during initialize
vim.api.nvim_create_autocmd("FileType", {
	pattern = "java",
	group = vim.api.nvim_create_augroup("jdtls-start", { clear = true }),
	callback = function(ev)
		vim.schedule(function()
			if not vim.api.nvim_buf_is_valid(ev.buf) then
				return
			end
			local fname = vim.api.nvim_buf_get_name(ev.buf)
			local source = (fname ~= "") and fname or vim.fn.getcwd()
			local root = vim.fs.root(source, { "pom.xml", "mvnw", "gradlew", "build.gradle", ".git" })
				or vim.fn.getcwd()

			local mason_share = vim.fn.stdpath("data") .. "/mason"
			local workspace = vim.fn.expand("$HOME/.local/share/eclipse/") .. vim.fn.fnamemodify(root, ":p:h:t")
			local lombok = mason_share .. "/packages/jdtls/lombok.jar"

			local bundles = {}
			local debug_jar = vim.fn.glob(
				mason_share .. "/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar",
				true
			)
			if debug_jar ~= "" then
				table.insert(bundles, debug_jar)
			end
			for _, jar in ipairs(vim.split(
				vim.fn.glob(mason_share .. "/packages/java-test/extension/server/*.jar", true),
				"\n"
			)) do
				if jar ~= "" then
					table.insert(bundles, jar)
				end
			end

			vim.lsp.start({
				name = "jdtls",
				capabilities = {
					workspace = {
						didChangeWatchedFiles = { dynamicRegistration = false },
					},
				},
				cmd = {
					mason_share .. "/bin/jdtls",
					"--jvm-arg=-javaagent:" .. lombok,
					"-data",
					workspace,
				},
				root_dir = root,
				init_options = {
					extendedClientCapabilities = {
						classFileContentsSupport = true,
						generateToStringPromptSupport = true,
						hashCodeEqualsPromptSupport = true,
						advancedExtractRefactoringSupport = true,
						advancedOrganizeImportsSupport = true,
						generateConstructorsPromptSupport = true,
						generateDelegateMethodsPromptSupport = true,
						moveRefactoringSupport = true,
						overrideMethodsPromptSupport = true,
						inferSelectionSupport = { "extractMethod", "extractVariable", "extractField" },
						resolveAdditionalTextEditsSupport = true,
					},
					bundles = bundles,
				},
				settings = {
					java = {
						configuration = { updateBuildConfiguration = "interactive" },
						signatureHelp = { enabled = true },
						contentProvider = { preferred = "fernflower" },
						completion = {
							favoriteStaticMembers = {
								"org.mockito.Mockito.*",
								"org.springframework.*",
								"org.junit.Assert.*",
							},
						},
						format = {
							enabled = true,
							settings = {
								url = vim.fn.stdpath("config") .. "/config/java-style.xml",
								profile = "GoogleStyle",
							},
						},
					},
				},
			}, { bufnr = ev.buf })
		end)
	end,
})

vim.api.nvim_create_user_command("JdtWipeAndRestart", function()
	local clients = vim.lsp.get_clients({ name = "jdtls" })
	if #clients == 0 then
		vim.notify("jdtls: no active client", vim.log.levels.WARN)
		return
	end
	local root_dir = clients[1].config.root_dir
	local workspace = vim.fn.expand("$HOME/.local/share/eclipse/") .. vim.fn.fnamemodify(root_dir, ":t")
	vim.lsp.stop_client(clients)
	vim.fn.delete(workspace, "rf")
	vim.notify("jdtls: workspace wiped, restarting…", vim.log.levels.INFO)
	vim.cmd("edit")
end, { desc = "Wipe jdtls workspace and restart" })
