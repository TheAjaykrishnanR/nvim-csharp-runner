local M = {}

local output_buf = nil
local current_job_id = nil

function M.run_csharp()
	local current_buf = vim.api.nvim_get_current_buf()

	-- Don't run from output buffer
	if current_buf == output_buf then
		vim.notify("Already in output buffer. Switch to source file first.", vim.log.levels.WARN)
		return
	end

	local lines = vim.api.nvim_buf_get_lines(current_buf, 0, -1, false)
	local code = table.concat(lines, "\n")
	local temp_file = vim.fn.tempname() .. ".cs"

	local file = io.open(temp_file, "w")
	if not file then
		vim.notify("Failed to create temporary file", vim.log.levels.ERROR)
		return
	end
	file:write(code)
	file:close()

	local cmd = { "css", "-engine:csc", temp_file }

	-- Close previous output buffer if it exists
	if output_buf and vim.api.nvim_buf_is_valid(output_buf) then
		pcall(vim.api.nvim_buf_delete, output_buf, { force = true })
	end

	-- Save current window
	local source_win = vim.api.nvim_get_current_win()

	vim.cmd("split")
	local win = vim.api.nvim_get_current_win()
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_win_set_buf(win, buf)

	-- Store the new output buffer
	output_buf = buf

	-- Return to source window
	vim.api.nvim_set_current_win(source_win)

	vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
	vim.api.nvim_buf_set_option(buf, "swapfile", false)

	-- Show compiling animation
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Running ... |" })

	local animation_chars = { "|", "/", "-", "\\" }
	local animation_index = 1
	local animation_timer = nil
	local first_output = false

	animation_timer = vim.loop.new_timer()
	animation_timer:start(
		0,
		100,
		vim.schedule_wrap(function()
			if first_output then
				animation_timer:stop()
				animation_timer:close()
				return
			end
			animation_index = (animation_index % 4) + 1
			pcall(vim.api.nvim_buf_set_lines, buf, 0, 1, false, { "Running ... " .. animation_chars[animation_index] })
		end)
	)

	current_job_id = vim.fn.jobstart(cmd, {
		on_stdout = function(_, data)
			if data then
				if not first_output then
					first_output = true
					vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
				end
				local current_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
				for _, line in ipairs(data) do
					if line ~= "" then
						table.insert(current_lines, line)
					end
				end
				vim.api.nvim_buf_set_lines(buf, 0, -1, false, current_lines)
			end
		end,
		on_stderr = function(_, data)
			if data then
				if not first_output then
					first_output = true
					vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
				end
				local current_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
				for _, line in ipairs(data) do
					if line ~= "" then
						table.insert(current_lines, line)
					end
				end
				vim.api.nvim_buf_set_lines(buf, 0, -1, false, current_lines)
			end
		end,
		on_exit = function(_, exit_code)
			vim.fn.delete(temp_file)
			current_job_id = nil
		end,
	})
end

function M.kill_csharp()
	-- Kill the current job if it exists
	if current_job_id then
		vim.fn.jobstop(current_job_id)
		current_job_id = nil
		vim.notify("Killed running process", vim.log.levels.INFO)
	else
		-- Fallback: kill all css.exe processes
		vim.fn.system("taskkill /F /IM css.exe 2>nul")
		vim.notify("Killed all css.exe processes", vim.log.levels.INFO)
	end
end

vim.api.nvim_create_user_command("Run", function()
	M.run_csharp()
end, {})

vim.api.nvim_create_user_command("Kill", function()
	M.kill_csharp()
end, {})

return M
