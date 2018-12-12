local http = require("socket.http")   -- Used to do requests to the Kong Controller service

  -- This function does a HTTP request to Kong Controller on the supplied path using
  -- at least a sessionToken. Other params can be provided as argument.
function kongControllerRequest(conf, path, params)
  -- Get sessionToken from query parameter
  local sessionToken   = kong.request.get_query()["sessionToken"]
  local controller_url = conf['kong_controller_url']
  if not sessionToken then
    return false, { code = 400, message = "Missing query parameter sessionToken" }
  end

  local url = controller_url .. path .. "?sessionToken=" .. sessionToken .. params
  local result, statuscode = http.request(url)

  if statuscode == "connection refused" then
    return false, { code = 400, message = "Could not connect to Kong Controller on " .. controller_url }
  else
    return true, { result = result, statuscode = statuscode}
  end
end

return kongControllerRequest
