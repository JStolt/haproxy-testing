core.register_fetches("handle-events", function(txn)

  -- local encode = require("./urlencode")
  function urlencode(url)
    local char_to_hex = function(c)
      return string.format("%%%02X", string.byte(c))
    end
    if url == nil then
      return
    end
    url = url:gsub("\n", "\r\n")
    url = url:gsub("([^%w ])", char_to_hex)
    url = url:gsub(" ", "+")
    return url
  end

  local headers = {}
  for header, values in pairs(txn.http:req_get_headers()) do
    for i, v in pairs(values) do
      if headers[header] == nil then
        headers[header] = v
      else
        headers[header] = headers[header] .. ", " .. v
      end
    end
  end

  local secret = os.getenv("LOGGLY_TOKEN")
  local new_host = "logs-01.loggly.com"

  local path = core.concat()
  path:add("/inputs/")
  path:add(secret)
  path:add(".gif")

  local query = core.concat()
  query:add(tostring(txn.f:query()))
  query:add("&forwardedFor=")
  query:add(tostring(txn.f:src()))
  query:add("&eventTime=")
  query:add(headers["x-request-start"])
  query:add("&useragent=")
  query:add(urlencode(headers["user-agent"]))
  query:add("&referer=")
  query:add(urlencode(headers["referer"]))

  local uri = core.concat()
  uri:add("https://")
  uri:add(new_host)
  uri:add(path:dump())
  uri:add("?")
  uri:add(query:dump())
  -- print(uri:dump())
  return uri:dump()

end)
