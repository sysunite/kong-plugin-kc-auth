local kongHandlerRequest = require("kong.plugins.kh-auth.util.kong-handler-request")

-- Verify if current user has access to supplied projectId if given
function verifyProjectAccess(conf)
  -- Only verify if project_id is supplied in the query
  local projectId = kong.request.get_query()["projectId"]
  if not projectId then
    return true
  end

  local ok, result = kongHandlerRequest(conf, '/projectAccess', "&projectId=" .. projectId )

  if not ok then
    return false, result
  elseif result["statuscode"] ~= 200 then
    return false, { code = 403, message = "You are unauthorized to use the supplied project" }
  end

  return true
end

return verifyProjectAccess
