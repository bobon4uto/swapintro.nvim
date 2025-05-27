local PLUGIN_NAME = "swapintro"
local AUTOCMD_GROUP = vim.api.nvim_create_augroup(PLUGIN_NAME, {})

--default parameters
local intro = {
[[ ____  _____ _____ _   _   _ _   _____ ]],
[[|  _ \| ____|  ___/ \ | | | | | |_   _|]],
[[| | | |  _| | |_ / _ \| | | | |   | |  ]],
[[| |_| | |___|  _/ ___ \ |_| | |___| |  ]],
[[|____/|_____|_|/_/   \_\___/|_____|_|  ]]
}
local buf_name = "intro"
local buf_type = "none"
local center = true
local center_individually = false

--helpers
local function unlock_buf(buf)
	vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
end

local function lock_buf(buf)
	vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
end

local function get_screen_dimensions(buf)
	local window = vim.fn.bufwinid(buf)
	local screen_width = vim.api.nvim_win_get_width(window)
	local screen_height = vim.api.nvim_win_get_height(window) - vim.opt.cmdheight:get()
	return {x=screen_width-6,y=screen_height}
	-- minus 3 from left side and right to make it symmetrical 
	-- (not sure if its correct way to account for them, maybe there is some 
	-- vim function that gives their size?)
end

local function get_intro_dimensions(lines)
	local lines_y=#lines
	local lines_x = 0
	for _, line in ipairs(lines) do
		if string.len(line) > lines_x then
			lines_x = string.len(line)
		end
	end
	return {x=lines_x,y=lines_y}
end

local function draw(buf,lines)
	local centered_lines = {}
	local offset_x =0
	local offset_y =0
	local spaces = {}
	local spacesx = ""
	local screen_dim 
	if center then
		screen_dim = get_screen_dimensions(buf)
		local intro_dim= get_intro_dimensions(lines)
		local diffx=screen_dim.x-intro_dim.x
		local diffy=screen_dim.y-intro_dim.y
		if diffx<0 then
			vim.notify("switchintro: intro wider than the screen, ignoring centering.",
			vim.log.levels.WARN
		)
		elseif diffy<0 then 
			vim.notify("switchintro: intro taller than the screen, ignoring centering.",
			vim.log.levels.WARN
		)
	else
		offset_x =math.floor((screen_dim.x-intro_dim.x)/2)
		offset_y =math.floor((screen_dim.y-intro_dim.y)/2)
		for _ = 0,offset_y do
			table.insert(spaces, "")
		end
		for _ = 0,offset_x do
			spacesx=spacesx.." "
		end

	end
	end
	if center_individually then
		for _, line in ipairs(lines) do
			local tmpdim = get_intro_dimensions({line,})
			offset_x =math.floor((screen_dim.x-tmpdim.x)/2)
			spacesx=""
			for _ = 0,offset_x do
				spacesx=spacesx.." "
			end
			table.insert(centered_lines, spacesx .. line)
		end
	else
		for _, line in ipairs(lines) do
			table.insert(centered_lines, spacesx .. line)
		end
end
	unlock_buf(buf)

	vim.api.nvim_buf_set_lines(buf, 0, 0, true, spaces)
	vim.api.nvim_buf_set_lines(buf, offset_y, offset_y, true, centered_lines)
	lock_buf(buf)
end

local function set_buf(buff)
	vim.api.nvim_set_current_buf(buff)
end

local function delete_buf(buff)
	vim.api.nvim_buf_delete(buff, { force = true })
end

--ugly workaround tbh, but im not that smart.
local id=-1
local autocmd_id=-1
local function trymatchdelete()
	if id~=-1 then
		vim.fn.matchdelete(id)
	end
	id=-1
	vim.api.nvim_del_autocmd(autocmd_id)
end

local function line80fix()
	vim.opt_local.colorcolumn = "0"      -- disable colorcolumn
	id = vim.fn.matchadd("Normal","\\%>80c",12) --disable error for 80+
	autocmd_id = vim.api.nvim_create_autocmd({'BufEnter', 'BufWinEnter'}, {
          pattern = {'*'},
          callback = trymatchdelete
        }) -- logic to reanable it after entering any other buffer
end
local function set_options()
	vim.opt_local.number = false         -- disable line numbers
	vim.opt_local.relativenumber = false -- disable relative line numbers
	vim.opt_local.list = false           -- disable displaying whitespace
	vim.opt_local.fillchars = { eob = ' ' } -- do not display "~"
	line80fix() -- disable 80 character line and error 
end



local function create_intro_buf()
	local intro_buff = vim.api.nvim_create_buf(false, true)
	-- I have no clue what scratch does
	vim.api.nvim_buf_set_name(intro_buff, buf_name)
	vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = intro_buff })
	vim.api.nvim_set_option_value("buftype", "nofile", { buf = intro_buff })
	vim.api.nvim_set_option_value("filetype", buf_type, { buf = intro_buff })
	vim.api.nvim_set_option_value("swapfile", false, { buf = intro_buff })
	return intro_buff
end







local function set_intro(payload)
	local is_dir = vim.fn.isdirectory(payload.file) == 1
	local default_buff = vim.api.nvim_get_current_buf()
	local default_buff_name = vim.api.nvim_buf_get_name(default_buff)
	local default_buff_filetype = vim.api.nvim_get_option_value("filetype", { buf = default_buff })
	if not is_dir and default_buff_name ~= "" and default_buff_filetype ~= PLUGIN_NAME then
		return
	end
	local intro_buff=create_intro_buf()
	set_buf(intro_buff)
	delete_buf(default_buff)
	draw(intro_buff,intro)
	set_options()
end

local function setup(options)
	options = options or {}
	intro = options.intro or intro
	buf_name = options.buf_name or buf_name
	buf_type = options.buf_type or buf_type
	if options.center ~= nil then
	center = options.center
	if center==true and options.center_individually~=nil then
	center_individually  = options.center_individually
end
end
	vim.api.nvim_create_autocmd("VimEnter", {
		group = AUTOCMD_GROUP,
		callback = set_intro,
		once = true
	})

end


return {
	setup = setup
}
