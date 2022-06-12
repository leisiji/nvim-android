local M = {}
local fn = vim.fn

local gradle_deps = {
  jars = {},
  src = {}
}

local entry = "\t<classpathentry kind=\"<kind>\" path=\"<path>\"/>"
--local entry_sourcepath = "\t<classpathentry kind=\"<kind>\" path=\"<path>\" sourcepath=\"<src>\"/>"

local function class_entry(kind, arg)
  local args = { kind = kind, path = arg }
  local template = entry
  for key, value in pairs(args) do
    template = fn.substitute(template, "<" .. key .. ">", value, "g")
  end
  return template
end

local function find_gradle_file()
  return fn.getcwd() .. "/build.gradle"
end

local function gradle_home()
  if vim.env["GRADLE_HOME"] then
    return vim.env["GRADLE_HOME"]
  end
  return "/usr"
end

local function gradle_bin()
  local gradlew = "./gradlew"

  if fn.executable(gradlew) then
    return fn.fnamemodify("./gradlew", ":p")
  end

  return gradle_home() .. "/bin/gradle"
end

local function gradle_sync_cmd()
  return {
    gradle_bin(),
    "--console=plain",
    "-b", find_gradle_file(),
    "-I", vim.g.gradle_init_file,
    "vim"
  }
end

local function parse_output(_, data, _)
  for _, v in pairs(data) do
    local s, e = string.find(v, "vim_gradle ")
    if s ~= nil then
      gradle_deps.jars[#gradle_deps.jars+1] = string.sub(v, e+1)
    end
  end
  require("android.lsp").notify(gradle_deps.jars)
end

function M.sync()
  local cmd = gradle_sync_cmd()

  fn.jobstart(fn.join(cmd), {
    on_stderr = parse_output,
    stderr_buffered = true,
  })
end

function M.generate_classpath()
  local classpath = { [[<?xml version="1.0" encoding="UTF-8"?>]], [[<classpath>]] }
  for _, v in ipairs(gradle_deps.jars) do
    classpath[#classpath+1] = class_entry("lib", v)
  end
  classpath[#classpath+1] = [[</classpath>]]
  fn.writefile(classpath, vim.fn.getcwd().."/.classpath")
end

return M
