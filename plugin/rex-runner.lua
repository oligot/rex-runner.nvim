if vim.g.loaded_rex_runner then return end
vim.g.loaded_rex_runner = true

local cmds = {
  RexOpenRunner = "open", RexSendCommandToRunner = "send_command", RexSendLinesToRunner = "send_lines",
  RexSendFile = "send_file", RexClearRunner = "clear", RexFocusRunner = "focus",
  RexKillRunner = "kill", RexDetachRunner = "detach", RexAttachToPane = "attach",
}
for name, fn in pairs(cmds) do
  vim.api.nvim_create_user_command(name, function() require("rex-runner")[fn]() end, { range = true })
end
