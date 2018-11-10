# kh-auth kong plugin
The kh-auth (kong-handler authentication) Kong plugin provides authentication for services accessed by the Weaver SDK that are proxied through Kong. This plugin requires a running and reachable Kong Handler instance (https://github.com/weaverplatform/kong-handler).

## Motivation
In applications where Weaver is deployed, we tend to promote a microservice architecture of small, reusable and standalone http services that are accessed by the Weaver SDK. Kong fits very well in providing a single endpoint through which these services and routes are exposed to the Weaver SDK. This plugin provides authentication on a per route basis for every service, allowing fine grained ACL control on all endpoints.

####  Kong
Kong is essentially a customizable API Management Layer built on top of Nginx that utilizes OpenResty to dynamically configure NGINX and process HTTP requests.

#### OpenResty
OpenResty is a software suite that bundles NGINX, a set of modules, LuaJIT, and a set of Lua libraries. Chief among these is `ngx_http_lua_module`, an NGINX module which embeds Lua and provides Lua equivalents for most NGINX request phases. This effectively allows development of NGINX modules in Lua while maintaining high performance (LuaJIT is quite fast), and Kong uses it to provide its core configuration management and plugin management infrastructure.

## Plugin Structure
A Kong plugin allows injecting custom logic (in Lua) at several entry-points in the life-cycle of a request/response as it is proxied by Kong. To do so, one must implement one or several of the methods of the base_plugin.lua interface.

The main plugin files of kh-auth are:
- schema.lua
- handler.lua

#### schema.lua
This file holds the schema of kh-auth configuration, so that the user can only enter valid configuration values. This configuration is set per route.

#### handler.lua
This file is where the methods of the base_plugin.lua interface are implemented and contain the logic at the entry-points in the request life-cycle. For kh-auth, only the `access` entry-point is used to deny further access if authentication at Kong Handler failed.

## How to install
1. Preferably use Docker to run Kong
2. Set the following environment variables:
  - `KONG_PLUGINS: bundled,kh-auth`
  - `KONG_LUA_PACKAGE_PATH: /usr/local/custom/?.lua;;`
3. Mount or place the plugin contents in `/usr/local/custom` at the docker container. For example, The file `handler.lua` will then be located under `/usr/local/custom/kong/plugins/kh-auth/handler.lua`
