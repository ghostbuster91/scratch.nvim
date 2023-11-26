local slash = require("scratch.utils").Slash()
local M = {}

---@alias mode
---| '"n"'
---| '"i"'
---| '"v"'

---@class Scratch.LocalKey
---@field cmd string
---@field key string
---@field modes mode[]

---@class Scratch.LocalKeyConfig
---@field filenameContains string[] as long as the filename contains any one of the string in the list
---@field LocalKeys Scratch.LocalKey[]

local default_config = {
    scratch_file_dir = vim.fn.stdpath("cache") .. slash .. "scratch.nvim",
    window_cmd = "edit",                               -- 'vsplit' | 'split' | 'edit' | 'tabedit' | 'rightbelow vsplit'
    filetypes = { "xml", "go", "lua", "js", "py", "sh" }, -- you can simply put filetype here
    filetype_details = {                               -- or, you can have more control here
        json = {},                                     -- empty table is fine
        ["yaml"] = {},
        ["k8s.yaml"] = {                               -- you can have different postfix
            subdir = "learn-k8s",                      -- and put this in a specific subdir
        },
        go = {
            requireDir = true, -- true if each scratch file requires a new directory
            filename = "main", -- the filename of the scratch file in the new directory
            content = { "package main", "", "func main() {", "  ", "}" },
            cursor = {
                location = { 4, 2 },
                insert_mode = true,
            },
        },
        ["gp.md"] = {
            cursor = {
                location = { 12, 2 },
                insert_mode = true,
            },
            content = {
                "# topic: ?",
                "",
                '- model: {"top_p":1,"temperature":0.7,"model":"gpt-3.5-turbo-16k"}',
                "- file: placeholder",
                "- role: You are a general AI assistant.",
                "",
                "Write your queries after 🗨:. Run :GpChatRespond to generate response.",
                "",
                "---",
                "",
                "🗨:",
                "",
            },
        },
    },
    ---@type Scratch.LocalKeyConfig[]
    localKeys = {
        {
            filenameContains = { "gp" },
            LocalKeys = {
                {
                    cmd = "<CMD>GpResponse<CR>",
                    key = "<C-k>k",
                    modes = { "n", "i", "v" },
                },
            },
        },
    },
}

local config = vim.deepcopy(default_config)

---Init the plugin
---@param force boolean
local function initProcess(force)
    -- if CONFIG_FILE_PATH file exist, don't need init

    -- write the scratch_file_dir into CONFIG_FILE_PATH file
    local dir_path = vim.fn.fnamemodify(config.scratch_file_dir, ":h")
    if vim.fn.isdirectory(dir_path) == 0 then
        vim.fn.mkdir(dir_path, "p")
    end
end

---comment
function M.setup(user_config)
    config = user_config
end

---comment
---@return {}
function M.getConfig()
    return config
end

-- TODO: convert to a struct and add type
function M.getConfigRequiresDir(ft)
    local config_data = M.getConfig()
    return config_data.filetype_details[ft] and config_data.filetype_details[ft].requireDir or false
end

---@param ft string
---@return string
function M.getConfigFilename(ft)
    local config_data = M.getConfig()
    return config_data.filetype_details[ft] and config_data.filetype_details[ft].filename
        or tostring(os.date("%y-%m-%d_%H-%M-%S")) .. "." .. ft
end

---@param ft string
---@return string | nil
function M.getConfigSubDir(ft)
    local config_data = M.getConfig()
    return config_data.filetype_details[ft] and config_data.filetype_details[ft].subdir
end

---@return Scratch.LocalKeyConfig[] | nil
function M.getLocalKeys()
    local config_data = M.getConfig()
    return config_data.localKeys
end

return M
