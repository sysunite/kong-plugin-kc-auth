local kongHandlerRequest = require("kong.plugins.kh-auth.util.kong-handler-request")

-- Supply a list of graph names that this user has access to within the project
function supplyAllowedGraphs(conf)
  local projectId = kong.request.get_query()["projectId"]

  if conf['supply_allowed_graphs_upstream'] and projectId then
    local ok, result = kongHandlerRequest(conf, '/getAllowedGraphAccess', "&projectId=" .. projectId )
    ngx.req.set_header("X-Kong-KP-Handler-Allowed-Graphs", result["result"])
  end

  return true
end

return supplyAllowedGraphs
