local M = {}

function hello(params)

    local user = "friend"
    if params.name then
        user = params.name
    end

    print("Hello " .. user  .. "! Scared?! Don't be! Let's do a neovim plugin together!")
end

function M.setup(params)

    params = params or {}

    vim.keymap.set("n", "<Leader>h", function()
        hello(params)
    end)

end

return M
