local M = {}

-- default config
M.config = {
	session_dir = vim.fn.stdpath("config") .. "/session/",
	save_session_on_exit = true,
	keymaps = {
		load = "",
		create = "",
		delete = "",
	},
}

-- ensure session directory exists
local function ensure_dir()
	if vim.fn.isdirectory(M.config.session_dir) == 0 then
		vim.fn.mkdir(M.config.session_dir, "p")
	end
end

local function session_exists(session)
	local found = vim.fs.find(session, {
		path = M.config.session_dir,
		type = "file",
	})
	return #found > 0
end

local function save()
	local session = vim.fn.fnamemodify(vim.v.this_session, ":t")

	if session == "" or not session_exists(session) then
		vim.notify("No session is loaded", vim.log.levels.INFO)
		return
	end

	ensure_dir()
	vim.cmd("mksession! " .. M.config.session_dir .. session)
	vim.notify(session .. " session saved", vim.log.levels.INFO)
end

-- load session
function M.load()
	local session = vim.fn.input("Load session: ", "", "customlist,v:lua.complete_sessions")

	if not session or session == "" then
		vim.notify("Session name required", vim.log.levels.ERROR)
		return
	end

	if not session_exists(session) then
		vim.notify(session .. " session does not exist", vim.log.levels.ERROR)
		return
	end

	save()
	vim.cmd("bufdo bw")
	vim.cmd("source " .. M.config.session_dir .. session)
end

-- create session
function M.create()
	local session = vim.fn.input("Create session: ", "", "customlist,v:lua.complete_sessions")

	if not session or session == "" then
		vim.notify("Session name required", vim.log.levels.ERROR)
		return
	end

	if session_exists(session) then
		vim.notify("Session with name " .. session .. " already exists", vim.log.levels.ERROR)
		return
	end

	ensure_dir()
	vim.cmd("mksession! " .. M.config.session_dir .. session)
end

-- delete session
function M.delete()
	local session = vim.fn.input("Delete session: ", "", "customlist,v:lua.complete_sessions")

	if not session or session == "" then
		vim.notify("Session name required", vim.log.levels.ERROR)
		return
	end

	if not session_exists(session) then
		vim.notify(session .. " session does not exist", vim.log.levels.ERROR)
		return
	end

	vim.fn.delete(M.config.session_dir .. session)
	vim.notify("Session " .. session .. " deleted", vim.log.levels.INFO)
end

-- to use on input custom completion. Has to be a global function because it is Vimscript API
function _G.complete_sessions(pattern)
	ensure_dir()
	local sessions = vim.fn.readdir(M.config.session_dir)
	local sessions_names = {}

	for _, session in ipairs(sessions) do
		if pattern == nil then
			table.insert(sessions_names, vim.fn.fnamemodify(session, ":t"))
		elseif vim.startswith(vim.fn.fnamemodify(session:lower(), ":t"), pattern:lower()) then
			table.insert(sessions_names, vim.fn.fnamemodify(session, ":t"))
		end
	end
	return sessions_names
end

local function setup_commands()
	vim.api.nvim_create_user_command("SLoad", function()
		M.load()
	end, {})
	vim.api.nvim_create_user_command("SCreate", function()
		M.create()
	end, {})
	vim.api.nvim_create_user_command("SDelete", function()
		M.delete()
	end, {})
end

local function setup_keymaps()
	local keymap_opts = { noremap = true, silent = false }

	if M.config.keymaps.load ~= "" then
		vim.keymap.set("n", M.config.keymaps.load, ":SLoad<CR>", keymap_opts)
	end

	if M.config.keymaps.create ~= "" then
		vim.keymap.set("n", M.config.keymaps.create, ":SCreate<CR>", keymap_opts)
	end

	if M.config.keymaps.delete ~= "" then
		vim.keymap.set("n", M.config.keymaps.delete, ":SDelete<CR>", keymap_opts)
	end
end

function M.setup(opts)
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})
	setup_keymaps()
	setup_commands()
end

if M.config.save_session_on_exit then
	local group = vim.api.nvim_create_augroup("SimpleSession", { clear = true })
	vim.api.nvim_create_autocmd("VimLeave", {
		group = group,
		callback = function()
			save()
		end,
	})
end

return M
