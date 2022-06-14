local M = {}
local fn = vim.fn

local function send_req(client, config)
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

local function jls_notify(client, jars)
  local config = {
    settings = {
      java = {
        classPath = jars,
        externalDependencies = {}
      },
    }
  }

  send_req(client, config)
end

local function jdtls_notify(client, jars)
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

  send_req(client, config)
end

function M.notify(jars)
  local clients = vim.lsp.get_active_clients()
  for _, c in pairs(clients) do
    if c.config.settings.java then
      jdtls_notify(c, jars)
      break
    elseif c.config.cmd ~= nil then
      for _, v in pairs(c.config.cmd) do
        if v == "java-language-server" then
          jls_notify(c, jars)
          return
        end
      end
    end
  end
end

return M
