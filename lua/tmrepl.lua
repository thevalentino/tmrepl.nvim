local M = {}

M.setup = function(opts)
  if not os.getenv('TMUX') then
    error ("Not in a TMUX session")
  end

  opts = opts or {}

  -- default config
  local settings = {
    ['command'] = opts['command'] or 'tmux',
    ['pane'] = opts['pane'] or 1,
  }

  M.settings = settings
  print(string.format("tmrepl: REPL set to pane %s", M.settings.pane))
end

M.set_pane = function(pane)
  M.settings.pane = pane
end

M.send_text = function(text)
  os.execute(
    string.format(
      "%s send-keys -t %s '%s' C-m",
      M.settings.command,
      M.settings.pane,
      text
    )
  )
end

M.send_clear = function()
  os.execute(
    string.format(
      "%s send-keys -t %s C-l",
      M.settings.command,
      M.settings.pane
    )
  )
end

M.get_selected_lines = function()
  local first_line = vim.api.nvim_buf_get_mark(0, "<")[1] - 1
  local last_line = vim.api.nvim_buf_get_mark(0, ">")[1]
  return vim.api.nvim_buf_get_lines(0, first_line, last_line, false)
end

M.left_strip_space = function(lines)
  -- find first non-empty char in first line
  local _, first_non_empty = lines[1]:find('^%s+')
  first_non_empty = first_non_empty or 0
  -- now strip each line and then concatenate them
  local lines_stripped = {}
  for _, l in ipairs(lines) do
    table.insert(lines_stripped, l:sub(first_non_empty+1))
  end
  return table.concat(lines_stripped, '\n')
end

-- run file
M.run_file = function()
  local present, _ = pcall(M._run_file[vim.bo.filetype])
  if not present then
    M._run_file['default']()
  end
end

M._run_file = {
  ['default'] = function()
    local fname = vim.fn.expand("%:p")
    M.send_text(fname)
  end
}
--

-- run line
M.run_line = function()
  local present, _ = pcall(M._run_line[vim.bo.filetype])
  if not present then
    M._run_line['default']()
  end
end

M._run_line = {
  ['default'] = function()
    M.send_text(vim.api.nvim_get_current_line())
  end
}
--

-- run lines
M.run_lines = function()
  local present, _ = pcall(M._run_lines[vim.bo.filetype])
  if not present then
    M._run_lines['default']()
  end
end

M._run_lines = {
  ['default'] = function()
    local stripped_lines = M.left_strip_space(M.get_selected_lines())
    M.send_text(stripped_lines)
  end,
}
--

M.setup()

return M
