package = "wow-dev-core"
version = "1.0.7-1"
rockspec_format = "3.1"
source = {
   url = "git+https://github.com/WoW-U/core-luarock.git",
   tag = "v1.0.7",
}
description = {
   homepage = "https://github.com/WoW-U/core-luarock",
   license = "MIT"
}
dependencies = { "lua >= 5.1" }
build_dependencies = { "lua >= 5.1" }
test_dependencies = { "busted" }
test = { type = "busted" }
build = {
   type = "builtin",
   modules = {
      ["amstaffix.core.error"] = "src/amstaffix/core/error.lua",
      ["amstaffix.core.abstract_unlocker"] = "src/amstaffix/core/abstract_unlocker.lua",
      ["amstaffix.core.daemonic.unlocker"] = "src/amstaffix/core/daemonic/unlocker.lua",
      ["amstaffix.core.nilname.unlocker"] = "src/amstaffix/core/nilname/unlocker.lua",
      ["amstaffix.core.tinkr.unlocker"] = "src/amstaffix/core/tinkr/unlocker.lua",
   },
}
