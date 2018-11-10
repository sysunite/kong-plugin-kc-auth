-- The name to set in the Kong configuration `plugins` setting is kh-auth.
package = "kong-plugin-kh-auth"

-- The version '0.1.0' is the source code version, the trailing '1' is the version of this rockspec.
-- Whenever the source version changes, the rockspec should be reset to 1. The rockspec version is only
-- updated (incremented) when this file changes, but the source remains the same.
version = "0.1.0-1"

supported_platforms = {"linux", "macosx"}
source = {
  url = "https://github.com/weaverplatform/kong-plugin-kh-auth",
  tag = "0.1.0"
}

description = {
  summary  = "The kh-auth (kong-handler authentication) Kong plugin provides authentication for services accessed by the Weaver SDK that are proxied through Kong.",
  homepage = "http://weaverplatform.org",
  license  = "GPL-3.0"
}

dependencies = {
}

build = {
  type = "builtin",
  modules = {
    ["kong.plugins.kh-auth.handler"] = "kong/plugins/kh-auth/handler.lua",
    ["kong.plugins.kh-auth.schema"]  = "kong/plugins/kh-auth/schema.lua",
  }
}
