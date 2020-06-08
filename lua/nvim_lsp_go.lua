local buf = require 'vim.lsp.buf'
local util = require 'vim.lsp.util'

local M = {}

local function build_params()
  return {
    textDocument = {
      uri = 'file://' .. vim.api.nvim_buf_get_name(0);
    };
  }
end

local function request(method, params, timeout_ms)
  local result = nil
  local synclock = 0

  local function _callback(err, _, _result)
    if not err then
      result = _result
    end
    synclock = 1
  end

  local _, cancel = vim.lsp.buf_request(0, method, params, _callback)

  local wait_result, reason = vim.wait(timeout_ms, function()
    return synclock > 0
  end, 10)

  if not wait_result then
    cancel()
    return nil
  end

  return result
end

local function apply_action(action)
  if action.edit or type(action.command) == "table" then
    if action.edit then
      util.apply_workspace_edit(action.edit)
    end
    if type(action.command) == "table" then
      buf.execute_command(action.command)
    end
  else
    buf.execute_command(action)
  end
end

local function formatting()
  local params = build_params()

  local result = request(
    'textDocument/formatting',
    params,
    1000
  )

  -- print(vim.inspect(result))

  if not result then
    return
  end

  util.apply_text_edits(result)
end

local function organize_imports()
  local actions = request(
    "textDocument/codeAction",
    build_params(),
    1000
  )

  if not actions then
    return nil
  end

  for i, action in ipairs(actions) do
    if action.title == 'Organize Imports' then
      return apply_action(action)
    end
  end
end

function M.formatting_and_organize_imports()
  organize_imports()
  formatting()
end

return M

-- vim:et ts=2 sw=2
