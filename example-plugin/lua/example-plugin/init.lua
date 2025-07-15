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

function bl()
  local file_path = vim.fn.expand('%:p')

  local git_root = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
  if not git_root or git_root == '' then
    vim.notify("Not inside a Git repository", vim.log.levels.ERROR)
    return
  end

  vim.cmd('vsplit')

  vim.cmd('enew')
  local blame_buf = vim.api.nvim_get_current_buf()
  vim.bo[blame_buf].buftype = 'nofile'
  vim.bo[blame_buf].bufhidden = 'wipe'
  vim.bo[blame_buf].swapfile = false
  vim.bo[blame_buf].modifiable = true
  vim.bo[blame_buf].readonly = false

  local output = vim.fn.systemlist('git blame --date=short ' .. vim.fn.shellescape(file_path))
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_buf_set_lines(blame_buf, 0, -1, false, { 'Error running git blame.' })
  else
    vim.api.nvim_buf_set_lines(blame_buf, 0, -1, false, output)
  end

  vim.api.nvim_buf_set_name(blame_buf, 'Git Blame: ' .. file_path)
  vim.bo[blame_buf].modifiable = false
  vim.bo[blame_buf].readonly = true
end

function M.setup(params)

    params = params or {}

    vim.keymap.set("n", "<Leader>h", function()
        hello(params)
    end)

    vim.keymap.set("n", "<Leader>co", function()
        co()
    end)

    vim.keymap.set("n", "<Leader>bl", function()
        bl()
    end)

    -- TODO: insert package in a new file
    -- TODO: generate implementation for an interface
    -- TODO: remove unused impoorts
    -- TODO: optimize imports / resolve imports

end

return M
