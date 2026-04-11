return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			{ "leoluz/nvim-dap-go" },
			{
				"rcarriga/nvim-dap-ui",
				dependencies = { "nvim-neotest/nvim-nio" },
			},
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			dapui.setup()

			-- Auto-open/close UI with debug sessions
			dap.listeners.after.event_initialized["dapui"] = dapui.open
			dap.listeners.before.event_terminated["dapui"] = dapui.close
			dap.listeners.before.event_exited["dapui"] = dapui.close

			-- Go: nvim-dap-go configures the delve adapter and standard launch configs
			require("dap-go").setup()

			-- Java: ask JDTLS to start a debug server and hand the port to nvim-dap
			dap.adapters.java = function(callback)
				local client = vim.lsp.get_clients({ name = "jdtls" })[1]
				if not client then
					vim.notify("jdtls: no active client for debugging", vim.log.levels.ERROR)
					return
				end
				client:request("workspace/executeCommand", {
					command = "vscode.java.startDebugSession",
				}, function(err, port)
					if err then
						vim.notify("jdtls: failed to start debug session: " .. err.message, vim.log.levels.ERROR)
						return
					end
					callback({ type = "server", host = "127.0.0.1", port = port })
				end)
			end

			dap.configurations.java = {
				{
					type = "java",
					name = "Launch",
					request = "launch",
					mainClass = function()
						return vim.fn.input("Main class (e.g. com.example.Main): ")
					end,
				},
				{
					type = "java",
					name = "Attach remote JVM",
					request = "attach",
					hostName = function()
						return vim.fn.input("Host (default 127.0.0.1): ", "127.0.0.1")
					end,
					port = function()
						return tonumber(vim.fn.input("Port (default 5005): ", "5005"))
					end,
				},
			}

			local map = function(lhs, rhs, desc)
				vim.keymap.set("n", lhs, rhs, { silent = true, desc = desc })
			end
			map("<leader>db", dap.toggle_breakpoint, "Toggle [B]reakpoint")
			map("<leader>dc", dap.continue, "[C]ontinue")
			map("<leader>di", dap.step_into, "Step [I]nto")
			map("<leader>do", dap.step_over, "Step [O]ver")
			map("<leader>dO", dap.step_out, "Step [O]ut")
			map("<leader>dr", dap.repl.open, "[R]EPL")
			map("<leader>du", dapui.toggle, "Toggle [U]I")
		end,
	},
}
