---------------------------------------------------------------------------------------------
-- The handlers are based on the OpenResty handlers, see the OpenResty docs for details
-- on when exactly they are invoked and what limitations each handler has.
---------------------------------------------------------------------------------------------

local BasePlugin = require("kong.plugins.base_plugin")

-- This is the plugin object that this file must return
local KhAuth = BasePlugin:extend()

-- set the plugin priority, which determines plugin execution order
KhAuth.PRIORITY = 1000

-- constructor
function KhAuth:new()
  -- The call to `.super` is a call to the base_plugin, which does nothing,
  -- except loggin that the specific handler was executed.
  KhAuth.super.new(self, "kc-auth")
end

-- The steps in order of executation for the complete authentication
-- If either of the steps fail to authenticate, further execution of the other steps is halted
local steps = {
  "verify-route-access",
  "verify-project-access",
  "supply-allowed-graphs",
}

-- This is the actual access handler where we need to all the checking
function KhAuth:access(conf)
  KhAuth.super.access(self)

  for _, stepFile in ipairs(steps) do
    local step = require("kong.plugins.kc-auth.steps." .. stepFile)
    local ok, err = step(conf)
    if not ok then
      return kong.response.exit(err.code, { message = err.message })
    end
  end

  -- All good, set this header which might be useful for the upstream service
  ngx.req.set_header("X-Kong-KP-Controller", "authenticated")
end

return KhAuth
