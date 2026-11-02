-- rex-runner.nvim: a Rex port of vim-tmux-runner. Opens a scratch pane next to
-- neovim and sends lines, commands or file paths to it through the rex CLI.
local M = {}

M.config = {
  split = "below", -- right, left, above, below
  ratio = 25, -- percent of the split given to the runner
  label = "runner",
  default_maps = false, -- install the vim-tmux-runner <leader> maps
}

local runner -- block id

local function rex(...)
  local out = vim.system({ "rex", "-s", vim.env.REX_SESSION, ... }, { text = true }):wait()
  if out.code ~= 0 then vim.notify("rex-runner: " .. out.stderr, vim.log.levels.ERROR) end
  return out.code == 0 and out.stdout or nil
end

local function blocks()
  local out = rex("block", "ls", "--json")
  return out and vim.json.decode(out).blocks or {}
end

local function alive()
  if not runner then return false end
  for _, b in ipairs(blocks()) do
    if b.block_id == runner then return true end
  end
  runner = nil
  return false
end

function M.open()
  if alive() then return end
  local c = M.config
  local out = rex("split", "--json", "--focus=false", "--split=" .. c.split, "--ratio", tostring(c.ratio),
    "-b", vim.env.REX_BLOCK, "-c", vim.fn.getcwd(), "--label", c.label)
  runner = out and vim.json.decode(out).block_ids[1]
end

function M.send(text)
  M.open()
  if runner then rex("send", "-b", runner, text .. "\n") end
end

function M.send_command()
  local cmd = vim.fn.input "Command to run: "
  if cmd ~= "" then M.send(cmd) end
end

function M.send_lines()
  local s, e = vim.fn.line ".", vim.fn.line "."
  if vim.fn.mode():match "[vV]" then
    vim.cmd "normal! \27" -- leave visual mode so '< and '> are current
    s, e = vim.fn.line "'<", vim.fn.line "'>"
  end
  M.send(table.concat(vim.api.nvim_buf_get_lines(0, s - 1, e, false), "\n"))
end

function M.send_file() M.send(vim.fn.expand "%:p") end

function M.clear() if alive() then rex("send", "-b", runner, "clear\n") end end

function M.focus() if alive() then rex("focus", runner) end end

function M.kill()
  if alive() then rex("block", "close", runner) end
  runner = nil
end

function M.detach() runner = nil end

function M.attach()
  local others = vim.tbl_filter(function(b) return b.block_id ~= vim.env.REX_BLOCK end, blocks())
  vim.ui.select(others, {
    prompt = "Attach runner to pane",
    format_item = function(b) return b.label .. "  " .. b.block_id:sub(-6) end,
  }, function(b) if b then runner = b.block_id end end)
end

function M.setup(opts)
  M.config = vim.tbl_extend("force", M.config, opts or {})
  if not M.config.default_maps then return end
  local map = function(lhs, fn, desc, mode) vim.keymap.set(mode or "n", lhs, fn, { desc = desc }) end
  map("<leader>or", M.open, "Open runner")
  map("<leader>sc", M.send_command, "Send command to runner")
  map("<leader>sl", M.send_lines, "Send lines to runner", { "n", "v" })
  map("<leader>sf", M.send_file, "Send file path to runner")
  map("<leader>cr", M.clear, "Clear runner")
  map("<leader>fr", M.focus, "Focus runner")
  map("<leader>kr", M.kill, "Kill runner")
  map("<leader>dr", M.detach, "Detach runner")
  map("<leader>va", M.attach, "Attach to runner")
end

return M
