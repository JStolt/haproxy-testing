core.register_fetches("handle-events", function(txn)

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

  -- Get headers and Loggly Token
  local headers = txn.http:req_get_headers()
  local secret = os.getenv("LOGGLY_TOKEN")
  local new_host = "logs-01.loggly.com"

  -- Create Path
  local path = core.concat()
  path:add("/inputs/")
  path:add(secret)
  path:add(".gif")

  -- Append headers to query
  local query = core.concat()
  query:add(tostring(txn.f:query()))
  -- Source IP
  if txn.f:src() ~= nil then
    query:add("&forwardedFor=")
    query:add(tostring(txn.f:src()))
  end
  -- HAProxy generated eventtime
  query:add("&eventTime=")
  query:add(headers["x-request-start"][0])
  -- User Agent
  if headers["user-agent"] ~= nil then
    query:add("&useragent=")
    query:add(urlencode(headers["user-agent"][0]))
  end
  -- Referer
  if headers["referer"] ~= nil then
    query:add("&referer=")
    query:add(urlencode(headers["referer"][0]))
  end
  -- Build URI
  local uri = core.concat()
  uri:add("https://")
  uri:add(new_host)
  uri:add(path:dump())
  uri:add("?")
  uri:add(query:dump())
  -- print(uri:dump())
  return uri:dump()

end)
