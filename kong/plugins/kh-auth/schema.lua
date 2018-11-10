return {
  -- This plugin is only available on APIs, not on global consumers
  no_consumer = true,

  -- The plugin configuration's schema is described here.
  fields = {

    -- The url of Kong Handler to check permission on a specific route
    kong_handler_url = {
      required = true,
      type     = "string",
      default  = "http://host.docker.internal:7090",
    },

    -- If the checked privileges should be cached
    cache_privileges = {
      type    = "boolean",
      default = false,
    },

    -- Using projectId, verify if the user has access to this project
    verify_project_access = {
      type    = "boolean",
      default = true,
    },

    -- Using projectId, supply an array of graphs that this user has access to
    -- within this project to the upstream service in a specific header setting
    supply_allowed_graphs_upstream = {
      type    = "boolean",
      default = false,
    },
  }
}
