-- package.loaded['tmrepl'] = nil
local tmrepl = require('tmrepl')

tmrepl._run_file['python'] = function()
  local fname = vim.fn.expand("%:p")
  tmrepl.send_text(string.format("%%run %s", fname))
end

tmrepl._run_line['python'] = function()
  local line = vim.api.nvim_get_current_line()
  line = line:gsub("^%s+", "", 1)
  tmrepl.send_text(line)
end

tmrepl._run_lines['python'] = function()
  local selected_lines = tmrepl.left_strip_space(tmrepl.get_selected_lines())
  vim.fn.setreg("+", selected_lines)
  tmrepl.send_text("%paste")
end


-- mappings
vim.api.nvim_set_keymap('n', '<leader>R', "<cmd>lua require('tmrepl').run_file()<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>r', "<cmd>lua require('tmrepl').run_line()<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '<leader>r', ":lua require('tmrepl').run_lines()<cr>", { noremap = true, silent = true })
-- vim.api.nvim_set_keymap('n', '<space>r', "<cmd>lua require('tmrepl').run_line()<cr>", {expr = true, noremap = true})
-- vim.api.nvim_set_keymap('v', '<space>r', "<cmd>lua require('tmrepl').run_line()<cr>", {expr = true, noremap = true})

