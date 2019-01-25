local kongControllerRequest = require("kong.plugins.kc-auth.util.kc-request")

-- Verify if current user has access to current route
function verifyRouteAccess(conf)
  local ok, result = kongControllerRequest(conf, '/routeAccess', "&routeId=" .. conf['route_id'] )

  if not ok then
    return false, result
  elseif result["statuscode"] ~= 200 then
    return false, { code = 403, message = "You are unauthorized to request this route" }
  end

  return true
end

return verifyRouteAccess
