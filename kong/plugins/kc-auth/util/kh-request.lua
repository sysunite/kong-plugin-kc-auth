local http = require("socket.http")   -- Used to do requests to the Kong Handler service

  -- This function does a HTTP request to Kong Handler on the supplied path using
  -- at least a sessionToken. Other params can be provided as argument.
function kongHandlerRequest(conf, path, params)
  -- Get sessionToken from query parameter
  local sessionToken = kong.request.get_query()["sessionToken"]
  local handler_url  = conf['kong_handler_url']
  if not sessionToken then
    return false, { code = 400, message = "Missing query parameter sessionToken" }
  end

  local url = handler_url .. path .. "?sessionToken=" .. sessionToken .. params
  local result, statuscode = http.request(url)

  if statuscode == "connection refused" then
    return false, { code = 400, message = "Could not connect to Kong Handler on " .. handler_url }
  else
    return true, { result = result, statuscode = statuscode}
  end
end

return kongHandlerRequest
