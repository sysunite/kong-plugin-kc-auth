---------------------------------------------------------------------------------------------
-- The handlers are based on the OpenResty handlers, see the OpenResty docs for details
-- on when exactly they are invoked and what limitations each handler has.
--
-- The call to `.super.xxx(self)` is a call to the base_plugin, which does nothing, except logging
-- that the specific handler was executed.
---------------------------------------------------------------------------------------------

local BasePlugin = require("kong.plugins.base_plugin")
local http       = require("socket.http")   -- Used to do requests to the Kong Handler service

-- This is the plugin object that this file must return
local KhAuth = BasePlugin:extend()

-- set the plugin priority, which determines plugin execution order
KhAuth.PRIORITY = 1000

-- constructor
function KhAuth:new()
  KhAuth.super.new(self, "kh-auth")
end


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


-- Verify if current user has access to current route
function verifyRouteAccess(conf)
  local ok, result = kongHandlerRequest(conf, '/routeAccess', "&routeId=" .. conf['route_id'] )

  if not ok then
    return false, result
  elseif result["statuscode"] ~= 200 then
    return false, { code = 403, message = "You are unauthorized to request this route" }
  end

  return true
end

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


-- Supply a list of graph names that this user has access to within the project
function supplyAllowedGraphs(conf)
  local projectId = kong.request.get_query()["projectId"]

  if conf['supply_allowed_graphs_upstream'] and projectId then
    local ok, result = kongHandlerRequest(conf, '/getAllowedGraphAccess', "&projectId=" .. projectId )
    ngx.req.set_header("X-Kong-KP-Handler-Allowed-Graphs", result["result"])
  end

  return true
end

-- The steps in order of executation for the complete authentication
-- If either of the steps fail to authenticate, further execution of the other steps is halted
local steps = {
  verifyRouteAccess,
  verifyProjectAccess,
  supplyAllowedGraphs,
}

-- This is the actual access handler where we need to all the checking
function KhAuth:access(conf)
  KhAuth.super.access(self)

  for _, step in ipairs(steps) do
    local ok, err = step(conf)
    if not ok then
      return kong.response.exit(err.code, { message = err.message })
    end
  end

  -- All good, set this header which might be useful for the upstream service
  ngx.req.set_header("X-Kong-KP-Handler", "authenticated")
end


return KhAuth
