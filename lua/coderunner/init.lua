local M = {}

M.langs = {
    c = {
        cmd = {
            "gcc",
            "-W",
            "-Wall",
            "-pedantic",
            "--std=c11",
        },
        executable = "a.out",
    },
}

M.run = function ()
    local langs = M.langs
    local lang = vim.o.filetype
    if vim.tbl_get(langs, lang) == false then
        return
    end

    local cmd = ""
    local executable = ""
    local value = langs[lang]
    if type(value) ~= "table" then
        return
    end

    if vim.tbl_get(value, "cmd") ~= false and type(value["cmd"]) == "table" then
        cmd = table.concat(value.cmd, " ")
    end

    if vim.tbl_get(value, "executable") ~= false and type(value["executable"]) == "string" then
        executable = value["executable"]
    end

    -- create a temporary window and then open the terminal in that buffer
    local height = math.ceil(vim.fn.winheight(0))
    local width  = math.ceil(vim.fn.winwidth(0))
    local fname  = vim.fn.expand("%")
    local buf    = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_open_win(buf, true, {
        style = "minimal",
        relative = "editor",
        row = 0,
        col = math.ceil(width / 2),
        width = math.ceil(width / 2),
        height = height,
        border = "single",
    })

    cmd = cmd .. " " .. fname

    if executable ~= nil and executable ~= "" then
        cmd = cmd .. "; ./" .. executable .. "; rm " .. executable
    end
    vim.fn.termopen(cmd)
end

M.setup = function (opts)
    if vim.g.coderunner_did_setup then
        return
    end
    vim.g.coderunner_did_setup = true

    if type(opts) == "table" and vim.tbl_get(opts, "langs") ~= false then
        M.langs = opts["langs"]
    end

    vim.api.nvim_create_user_command("CodeRunnerRun", M.run, {})
end

return M

