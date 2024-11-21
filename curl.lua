local component = require("component")
local internet = require("internet")
local shell = require("shell")
local text = require("text")

local args, options = shell.parse(...)

if #args < 1 then
  print("Usage: curl <url> [options]")
  print("Options:")
  print("  -X <method>  Specify request method (GET, POST, etc.)")
  print("  -d <data>    Data to send in a POST request")
  print("  -H <header>  Pass custom header(s) to server")
  os.exit(1)
end

local url = args[1]
local method = options.X or "GET"
local postData = options.d or nil
local headers = {}

if options.H then
  for _, header in ipairs(options.H) do
    local name, value = header:match("([^:]+):%s*(.+)")
    if name and value then
      headers[name] = value
    else
      print("Invalid header format: " .. header)
      os.exit(1)
    end
  end
end

if method == "POST" and not postData then
  print("POST method requires data (-d option).")
  os.exit(1)
end

local result = ""
local request

if method == "GET" then
  request = internet.request(url, nil, headers)
elseif method == "POST" then
  headers["Content-Length"] = tostring(#postData)
  request = internet.request(url, postData, headers)
else
  print("Unsupported method: " .. method)
  os.exit(1)
end

for chunk in request do
  result = result .. chunk
end

print(result)
