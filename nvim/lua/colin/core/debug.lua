local M = {}

local function open_client_inspector_window(title, clients)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = math.floor(vim.o.columns * 0.75),
		height = math.floor(vim.o.lines * 0.90),
		col = math.floor(vim.o.columns * 0.125),
		row = math.floor(vim.o.lines * 0.05),
		style = "minimal",
		border = "rounded",
		title = " " .. title .. " ",
		title_pos = "center",
	})

	local lines = {}
	for i, this_client in ipairs(clients) do
		if i > 1 then
			table.insert(lines, string.rep("-", 80))
		end
		table.insert(lines, "Client: " .. this_client.name)
		table.insert(lines, "ID: " .. this_client.id)
		table.insert(lines, "Root: " .. tostring(this_client.config and this_client.config.root_dir))
		table.insert(lines, "")
		table.insert(lines, "Configuration:")

		local config_lines = vim.split(vim.inspect(this_client.config), "\n")
		vim.list_extend(lines, config_lines)
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].modifiable = false
	vim.bo[buf].filetype = "lua"
	vim.bo[buf].bh = "delete"
	vim.keymap.set("n", "q", "<cmd>q<CR>", { buffer = buf, noremap = true, silent = true })
end

function M.InspectLsp()
	vim.ui.input({ prompt = "LSP client name (blank = all): " }, function(client_name)
		if client_name == nil then
			return
		end

		local bufnr = vim.api.nvim_get_current_buf()
		local current_ft = vim.bo[bufnr].filetype
		local query = vim.trim(client_name)
		local all_clients = vim.lsp.get_clients({ bufnr = bufnr })
		if #all_clients == 0 then
			local msg = "No active LSP clients for current buffer."
			if current_ft == "cs" or current_ft == "razor" or current_ft == "cshtml" then
				msg = msg .. " Run :Roslyn start and then :Roslyn target, then retry gd."
			else
				msg = msg .. " Open a project file and run :LspInfo."
			end
			vim.notify(msg, vim.log.levels.WARN)
			return
		end

		if query == "" then
			open_client_inspector_window("LSP Clients", all_clients)
			return
		end

		local exact = vim.lsp.get_clients({ name = query })
		if #exact > 0 then
			open_client_inspector_window(query:gsub("^%l", string.upper) .. ": LSP Configuration", exact)
			return
		end

		local query_lower = query:lower()
		local fuzzy = vim.tbl_filter(function(c)
			return c.name:lower():find(query_lower, 1, true) ~= nil
		end, all_clients)

		if #fuzzy > 0 then
			open_client_inspector_window("Matching LSP Clients", fuzzy)
			vim.notify(
				("No exact LSP match for '%s'. Showing %d matching client(s)."):format(query, #fuzzy),
				vim.log.levels.INFO
			)
			return
		end

		local names = vim.tbl_map(function(c)
			return c.name
		end, all_clients)
		vim.notify(
			(
				"No active LSP clients found with this name: %s. Active clients for this buffer: %s"
			):format(query, table.concat(names, ", ")),
			vim.log.levels.WARN
		)
	end)
end

vim.api.nvim_create_user_command("InspectLsp", function()
	require("colin.core.debug").InspectLsp()
end, {})

return M
