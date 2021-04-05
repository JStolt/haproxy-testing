core.register_converters("urlencode", function(url)
  local char_to_hex = function(c)
    return string.format("%%%02X", string.byte(c))
  end

  if url == nil then
    return
  end
  url = url:gsub("\n", "\r\n")
  url = url:gsub("([^%w ])", char_to_hex)
  url = url:gsub(" ", "+")
  -- print(url)
  return url
end)
