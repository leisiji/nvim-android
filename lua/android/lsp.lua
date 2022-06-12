local M = {}
local fn = vim.fn

function M.notify(jars)
  local client

  for _, c in pairs(vim.lsp.get_active_clients()) do
    if c.config.settings.java then
      client = c
      break
    end
  end

  if client.config.settings.java.project == nil then
    client.config.settings.java.project = {}
  end

  local config = {
    settings = {
      java = {
        project = {
          referencedLibraries = jars
        }
      }
    }
  }

  client.notify("workspace/didChangeConfiguration", config)

  local buf = vim.api.nvim_get_current_buf()
  local lines = fn.getbufline(buf, 1, '$')

  local req = {
    textDocument = {
      uri = vim.uri_from_bufnr(buf),
      version = 1
    },
    contentChanges = {{text = vim.fn.join(lines, "\n") .. "\n"}}
  }

  client.notify("textDocument/didChange", req)
end

return M
