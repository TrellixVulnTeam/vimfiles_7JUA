--  A simple lua plugin for loading & saving template codes
--  Author: jyd119@qq.com
--  Usage:
--    T [pattern]     " load snippets
--    TS xxx          " save selection as xxx

local vim = vim

local M = {}
local pathJoin = require('utils.pathjoin').pathJoin

local snippets_dir = vim.g.mysnippets_dir
if snippets_dir == "" then
  snippets_dir = vim.env.SNIPPETS_DIR or ""
end

if snippets_dir == "" then
  snippets_dir = vim.api.nvim_eval('expand("~/mysnippets")')
end

function M.insert_tpl(file)
  local ext = file:match("^.+/(.+)$")
  local fp = file
  local ft = vim.o.filetype
  if ext == "" then
    ext = vim.fn.expand('%:p:e')
  end
  if ext then
    fp = fp .. "." + ext
  end

  local dst = pathJoin(snippets_dir, fp)
  if vim.fn.filereadable(dst) == 0 then
    dst = pathJoin(snippets_dir, ft, fp)
  end

  if vim.fn.filereadable(dst) == 1 then
    vim.api.nvim_command("r " .. dst)
  end
end

local function get_sel_text()
  local line1 = vim.api.nvim_buf_get_mark(0, "<")[1]
  local line2 = vim.api.nvim_buf_get_mark(0, ">")[1]
  return vim.api.nvim_buf_get_lines(0, line1-1, line2, false)
end

function M.save_tpl(name)
  local ft = vim.o.ft
  local base_dir = snippets_dir
  if vim.fn.globpath(snippets_dir, ft) ~= "" then
    base_dir = pathJoin(snippets_dir, ft)
    if vim.fn.isdirectory(base_dir) == 0 then
      vim.fn.mkdir(base_dir, "p")
    end
  end

  if string.find(name, '.', 1, true) == nil then
    local ext = vim.fn.expand("%:p:e")
    name = name .. "." .. ext
  end

  local text = get_sel_text()
  local fp = pathJoin(base_dir, name)
  local f = io.open(fp, "w")
  f:write(table.concat(text, "\n"))
  f:close()
end

function M.populate_files(pattern, _, _)
  local ft = vim.o.ft
  local base_dir = snippets_dir

  if ft ~= "" and vim.fn.globpath(base_dir, ft) ~= "" then
    base_dir = pathJoin(base_dir, ft)
  end

  if not pattern then
    pattern = '**/*'
  end

  if string.find(pattern, "*", 1, true) == nil then
    pattern = pattern .. "*"
  end

  local text = vim.fn.globpath(base_dir, pattern)
  local files = vim.split(text, '\n', {plain=true})
  local n = #base_dir
  local res = {}
  for _,v in pairs(files) do
    table.insert(res, string.sub(v, n+2))
  end
  return res
end

-- command! -nargs=1 -range -complete=customlist,s:snippet_files TS call SaveTemplate(<q-args>)
-- command! -nargs=1 -bang -complete=customlist,s:snippet_files T call InsertTemplate(<q-args>)
vim.cmd([[
  command! -nargs=1 -bang -complete=customlist,v:lua.require't'.populate_files T lua require("t").insert_tpl(<f-args>)
  command! -nargs=1 -range -complete=customlist,v:lua.require't'.populate_files TS lua require("t").save_tpl(<f-args>)
]])

-- print(vim.inspect(M.populate_files('')))

return M

