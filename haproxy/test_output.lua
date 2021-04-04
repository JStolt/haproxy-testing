-- core.register_action("my-test", {"http-req"}, function(txn)
core.register_fetches("my-test", function(txn)
  local url = require "net.url"

  function url_escape(str)
      local escape_next = 0;
      local escaped = str:gsub('.',function(char)
          local ord = char:byte(1);
          if(escape_next > 0) then
              escape_next = escape_next - 1;
          elseif(ord <= 127) then               -- single-byte utf-8
              if(char:match("[0-9a-zA-Z%-%._~]")) then -- only these do not get escaped
                  return char;
              elseif char == ' ' then           -- also space, becomes '+'
                  return '+';
              end;
          elseif(ord >= 192 and ord < 224) then -- utf-8 2-byte
              escape_next = 1;
          elseif(ord >= 224 and ord < 240) then -- utf-8 3-byte
              escape_next = 2;
          elseif(ord >= 240 and ord < 248) then -- utf-8 4-byte
              escape_next = 3;
          end;
          return string.format('%%%02X',ord);
      end);
      return escaped;
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

  function table_print (tt, indent, done)
    done = done or {}
    indent = indent or 0
    if type(tt) == "table" then
      local sb = {}
      for key, value in pairs (tt) do
        table.insert(sb, string.rep (" ", indent)) -- indent it
        if type (value) == "table" and not done [value] then
          done [value] = true
          table.insert(sb, key .. " = {\n");
          table.insert(sb, table_print (value, indent + 2, done))
          table.insert(sb, string.rep (" ", indent)) -- indent it
          table.insert(sb, "}\n");
        elseif "number" == type(key) then
          table.insert(sb, string.format("\"%s\"\n", tostring(value)))
        else
          table.insert(sb, string.format(
              "%s = \"%s\"\n", tostring (key), tostring(value)))
         end
      end
      return table.concat(sb)
    else
      return tt .. "\n"
    end
  end

  function to_string( tbl )
      if  "nil"       == type( tbl ) then
          return tostring(nil)
      elseif  "table" == type( tbl ) then
          return table_print(tbl)
      elseif  "string" == type( tbl ) then
          return tbl
      else
          return tostring(tbl)
      end
  end

  local secret = os.getenv("LOGGLY_TOKEN")
  local new_host = "logs-01.loggly.com/inputs"


  print(to_string(headers))

  myurl = url.parse(txn.f:url()):normalize()
  myurl.query.event_date = headers["x-request-start"]
  if headers["user-agent"] ~= nil then
    myurl.query.user_agent = url_escape(headers["user-agent"])
  end
  myurl.query.forwarded_for = tostring(txn.f:src())
  if headers["referer"] ~= nil then
    myurl.query.referer = url_escape(headers["referer"])
  end
  myurl.query.forwarded_host = headers["host"]
  myurl.scheme = "https"
  myurl.host = new_host
  myurl.path = myurl.path:gsub("pixel", secret)
  --
  -- print(myurl.host)

  -- print(myurl.scheme)
  print(myurl:build())
  return myurl:build()
end)










-- print(tostring(txn.f:src()))
-- print(tostring(txn.f:url()))
-- print(tostring(txn.f:path()))

  -- for i,v in pairs(txn.sf) do
  --   print(i)
  --   print(v)
  -- end



  -- print(to_string(txt.sf:req_fhdr()))


  -- local str = ""
  -- str = str .. txn.sf:req_fhdr("host")
  -- str = str .. txn.sf:path()
  -- str = str .. txn.sf:src()
  -- txn:Info(str)


--
-- function mirror(txn)
--   core.Debug("Hello HAProxy!\n")
--   local buffer = ""
--   local response = ""
--   local mydate = txn.sc:http_date(txn.f:date())
--   buffer = buffer .. "You sent the following headersrn"
--   buffer = buffer .. "===============================================rn"
--   buffer = buffer .. txn.req:dup()
--   buffer = buffer .. "===============================================rn"
--   response = response .. "HTTP/1.0 200 OKrn"
--   response = response .. "Server: haproxy-lua/mirrorrn"
--   response = response .. "Content-Type: text/htmlrn"
--   response = response .. "Date: " .. mydate .. "rn"
--   response = response .. "Content-Length: " .. buffer:len() .. "rn"
--   response = response .. "Connection: closern"
--   response = response .. "rn"
--   response = response .. buffer
--   txn.res:send(response)
--   txn:close()
-- end

-- core.register_fetches("hello", function(txn)
--     core.Debug("Hello HAProxy!\n")
--     return txn.sf:req_fhdr("host")
-- end)

-- function test_function(txn)
--   core.Debug("Hello HAProxy!\n")
--   return txn.
-- end
-- core.register("test_func", test_function)
--
-- -- core.Debug(txn:req)
-- -- core.register_service("hello_world_http", )
--
-- 1. function my_hash(txn, salt)
--       local str = ""
--       str = str .. salt
--       str = str .. txn.sf:req_fhdr("host")
--       str = str .. txn.sf:path()
--       str = str .. txn.sf:src()
--       local result = txn.sc:sdbm(str, 1)
--       return result
--    end
--
--   core.register_fetches("my-hash", my_hash)
