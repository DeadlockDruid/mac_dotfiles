-- Needed globally
require "user.options"

if vim.g.vscode then
  --VSCODE NEOVIM
  require "user.vscode_keymaps"
else
  --Ordinary NEOVIM
end
