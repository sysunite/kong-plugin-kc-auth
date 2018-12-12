local kongControllerRequest = require("kong.plugins.kc-auth.util.kh-request")

-- Supply a list of graph names that this user has access to within the project
function supplyAllowedGraphs(conf)
  local projectId = kong.request.get_query()["projectId"]

  if conf['supply_allowed_graphs_upstream'] and projectId then
    local ok, result = kongControllerRequest(conf, '/getAllowedGraphAccess', "&projectId=" .. projectId )
    ngx.req.set_header("X-Kong-KP-Controller-Allowed-Graphs", result["result"])
  end

  return true
end

return supplyAllowedGraphs
