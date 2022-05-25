local feline = require('feline')
local feline_themes = require('feline.themes')

local M = {}

local sep = { str = ' | ', hl = { fg = 'blue' } }
sep.permanent = vim.deepcopy(sep)
sep.permanent.always_visible = true

local active_left = {
    { provider = '▊', hl = 'vi_mode' },
    { icon = 'file_status_icon' },
    { component = 'working_directory', opts = { depth = 2 } },
    { component = 'relative_file_name' },
    { provider = ' ', hl = { fg = 'bg', bg = 'NONE' } },
}

local active_middle = {}

local active_right = {
    { provider = ' ', hl = { fg = 'bg', bg = 'NONE' } },
    { component = 'diagnostic_warnings' },
    { component = 'diagnostic_errors', right_sep = sep },
    { component = 'git_branch', right_sep = sep },
    { icon = 'lsp_client_icon' },
    { icon = 'treesitter_parser_icon', right_sep = sep.permanent },
    { component = 'spellcheck' },
    { provider = 'position', right_sep = sep, left_sep = sep },
    { provider = 'scroll_bar', hl = 'vi_mode' },
}

local inactive_left = {
    { component = 'relative_file_name' },
}

M.select_theme = function()
    if vim.o.background == 'light' then
        feline.use_theme('cosmos-light')
    else
        feline.use_theme('cosmos-dark')
    end
end

local function patch(t1, t2)
    for k, v in pairs(t2) do
        if type(t1[k]) == 'table' and type(v) == 'table' then
            patch(t1[k], v)
        else
            t1[k] = v
        end
    end
end

M.setup = function(customization, themes)
    local dark = themes and themes.dark or require('compline.cosmosline.themes.dark')
    local light = themes and themes.light or require('compline.cosmosline.themes.light')

    local statusline = {
        active = { left = active_left, middle = active_middle, right = active_right },
        inactive = { left = inactive_left },
    }

    patch(statusline, customization or {})

    local config = require('compline').setup({
        theme = dark,
        vi_mode_colors = require('compline.cosmosline.themes.vi_mode_colors'),
        components = {
            active = {
                statusline.active.left,
                statusline.active.middle,
                statusline.active.right,
            },
            inactive = {
                statusline.inactive.left,
                statusline.inactive.middle,
                statusline.inactive.right,
            },
        },
    })

    feline_themes['cosmos-dark'] = dark
    feline_themes['cosmos-light'] = light

    M.select_theme()

    local group = vim.api.nvim_create_augroup('cosmos_themes', { clear = true })
    vim.api.nvim_create_autocmd(
        'ColorScheme',
        { pattern = '*', callback = M.select_theme, group = group }
    )

    return config
end

return M
