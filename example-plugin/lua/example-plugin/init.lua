local M = {}

function hello(params)

    local user = "friend"
    if params.name then
        user = params.name
    end

    print("Hello " .. user  .. "! Scared?! Don't be! Let's do a neovim plugin together!")
end

function shell_command(cmd)
    local handle = io.popen(cmd)
    local result = handle:read("*all")
    handle:close()
    return result
end

function findControllers()

    local rsl = {}

    local shrsl = shell_command("rg '@RestController' -l | while read f; do cat $f; done | rg -i -e \"@['Request', 'Get', 'Post', 'Put', 'Delete']{1,7}Mapping\"")
    print(shrsl)

    for line in shrsl:gmatch("[^\n\r]+") do
        table.insert(rsl, line)
    end

    return rsl

end

function co()

    local lines = findControllers()

    local qf_list = {}

    -- local lnum = 0
    -- local col = 0
    for _, line in ipairs(lines) do
        table.insert(qf_list, {
            -- bufnr = vim.api.nvim_get_current_buf(),
            text = line,
            -- lnum = lnum + 1,
            -- col = col + 1
        })
    end

    vim.fn.setqflist(qf_list)
    vim.cmd.copen()

    vim.api.nvim_win_set_option(0, "winbar", "Endpoints")
    vim.api.nvim_buf_set_name(0, "Endpoints")
end

function M.setup(params)

    params = params or {}

    vim.keymap.set("n", "<Leader>h", function()
        hello(params)
    end)

    vim.keymap.set("n", "<Leader>co", function()
        co()
    end)

end

return M
