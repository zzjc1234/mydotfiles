-- require('lualine').setup {
-- 	options = {
-- 		icons_enabled = true,
-- 		theme = 'tokyonight',
-- 		component_separators = { left = '', right = ''},
-- 		section_separators = { left = '', right = ''},
-- 		disabled_filetypes = {
-- 			statusline = {},
-- 			winbar = {},
-- 		},
-- 		ignore_focus = {},
-- 		always_divide_middle = true,
-- 		globalstatus = false,
-- 		refresh = {
-- 			statusline = 1000,
-- 			tabline = 1000,
-- 			winbar = 1000,
-- 		}
-- 	},
-- 	sections = {
-- 		lualine_a	= {'mode'},
-- 		lualine_b = {'branch', 'diff', 'diagnostics'},
-- 		lualine_c = {'filename',
-- 		{
-- 			'tabs',
-- 			max_length = vim.o.columns / 3, -- Maximum width of tabs component.
-- 			-- Note:
-- 			-- It can also be a function that returns
-- 			-- the value of `max_length` dynamically.
-- 			mode = 2, -- 0: Shows tab_nr
-- 			-- 1: Shows tab_name
-- 			-- 2: Shows tab_nr + tab_name
-- 
-- 			-- Automatically updates active tab color to match color of other components (will be overidden if buffers_color is set)
-- 			use_mode_colors = true,
-- 
-- 			fmt = function(name, context)
-- 				-- Show + if buffer is modified in tab
-- 				local buflist = vim.fn.tabpagebuflist(context.tabnr)
-- 				local winnr = vim.fn.tabpagewinnr(context.tabnr)
-- 				local bufnr = buflist[winnr]
-- 				local mod = vim.fn.getbufvar(bufnr, '&mod')
-- 
-- 				return name .. (mod == 1 and ' +' or '')
-- 			end
-- 		},
-- 	},
-- 	lualine_x = {'encoding', 'fileformat', 'filetype'},
-- 	lualine_y = {'progress',{'datetime', style='default'}},
-- 	lualine_z = {'location'}
-- },
-- inactive_sections = {
-- 	lualine_a = {},
-- 	lualine_b = {},
-- 	lualine_c = {'filename'},
-- 	lualine_x = {'location'},
-- 	lualine_y = {},
-- 	lualine_z = {}
-- },
-- tabline = {},
-- winbar = {},
-- inactive_winbar = {},
-- extensions = {}
-- }
local colors = {
  red = '#ca1243',
  grey = '#a0a1a7',
  black = '#383a42',
  white = '#f3f3f3',
  light_green = '#83a598',
  orange = '#fe8019',
  green = '#8ec07c',
}

local empty = require('lualine.component'):extend()
function empty:draw(default_highlight)
  self.status = ''
  self.applied_separator = ''
  self:apply_highlights(default_highlight)
  self:apply_section_separators()
  return self.status
end

-- Put proper separators and gaps between components in sections
local function process_sections(sections)
  for name, section in pairs(sections) do
    local left = name:sub(9, 10) < 'x'
    for pos = 1, name ~= 'lualine_z' and #section or #section - 1 do
      table.insert(section, pos * 2, { empty, color = { fg = colors.white, bg = colors.white } })
    end
    for id, comp in ipairs(section) do
      if type(comp) ~= 'table' then
        comp = { comp }
        section[id] = comp
      end
      comp.separator = left and { right = '' } or { left = '' }
    end
  end
  return sections
end

local function search_result()
  if vim.v.hlsearch == 0 then
    return ''
  end
  local last_search = vim.fn.getreg('/')
  if not last_search or last_search == '' then
    return ''
  end
  local searchcount = vim.fn.searchcount { maxcount = 9999 }
  return last_search .. '(' .. searchcount.current .. '/' .. searchcount.total .. ')'
end

local function modified()
  if vim.bo.modified then
    return '+'
  elseif vim.bo.modifiable == false or vim.bo.readonly == true then
    return '-'
  end
  return ''
end

require('lualine').setup {
  options = {
    theme = tokyonight,
    component_separators = '',
    section_separators = { left = '', right = '' },
  },
  sections = process_sections {
    lualine_a = { 'mode' },
    lualine_b = {
      'branch',
      'diff',
			{
				'diagnostics',
				color={bg='#232335'}
			},
      -- {
      --   'diagnostics',
      --   source = { 'nvim' },
      --   sections = { 'error' },
      --   diagnostics_color = { error = { bg = colors.red, fg = colors.white } },
      -- },
      -- {
      --   'diagnostics',
      --   source = { 'nvim' },
      --   sections = { 'warn' },
      --   diagnostics_color = { warn = { bg = colors.orange, fg = colors.white } },
      -- },
      -- { 'filename', file_status = false, path = 1 },
      { modified, color = { bg = colors.red } },
      {
        '%w',
        cond = function()
          return vim.wo.previewwindow
        end,
      },
      {
        '%r',
        cond = function()
          return vim.bo.readonly
        end,
      },
      {
        '%q',
        cond = function()
          return vim.bo.buftype == 'quickfix'
        end,
      },
    },
		lualine_c = {
		},
    lualine_x = {{'datetime', style='%b %d, %a, %I:%M %p'}},
		lualine_y = {
			search_result,
			{
				function()
            if vim.fn.mode() == 'n' and vim.fn.getreg(vim.fn.nr2char(0)) ~= '' then
                return require("noice").api.statusline.mode.get()
            end
        end,
        color = { fg = "#ff9e64" },
    },
		},
			-- lualine_z = { '%l:%c', '%p%%/%L' },
			lualine_z = { '%p%%/%L' },
		},
  inactive_sections = {
    lualine_c = { '%f %y %m' },
    lualine_x = {},
  },
}

vim.o.laststatus=3
