-- The name to set in the Kong configuration `plugins` setting is kc-auth.
package = "kong-plugin-kc-auth"

-- The version '0.1.0' is the source code version, the trailing '1' is the version of this rockspec.
-- Whenever the source version changes, the rockspec should be reset to 1. The rockspec version is only
-- updated (incremented) when this file changes, but the source remains the same.
version = "0.1.0-1"

supported_platforms = {"linux", "macosx"}
source = {
  url = "https://github.com/sysunite/kong-plugin-kc-auth",
  tag = "0.1.0"
}

description = {
  summary  = "The kc-auth (kong-controller authentication) Kong plugin provides authentication for services registered though the Kong Controller.",
  homepage = "http://sysunite.com",
  license  = "GPL-3.0"
}

dependencies = {
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins.kc-auth.handler"] = "kong/plugins/kc-auth/handler.lua",
    ["kong.plugins.kc-auth.schema"]  = "kong/plugins/kc-auth/schema.lua",
  }
}
