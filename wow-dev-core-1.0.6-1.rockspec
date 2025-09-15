package = "wow-dev-core"
rockspec_format = "3.1"
version = "1.0.6-1"
source = {
   url = "git+ssh://git@github.com/WoW-U/core-luarock.git",
   tag = "v1.0.6"
}
description = {
   homepage = "https://github.com/WoW-U/core-luarock",
   license = "MIT"
}
dependencies = {
   "lua >= 5.1",
}
build_dependencies = {
   "lua >= 5.1",
}
build = {
   type = "builtin",
   modules = {
      ["amstaffix.core.event_dispatcher"] = "src/amstaffix/core/event_dispatcher.lua",
      ["amstaffix.core.event_mediator"] = "src/amstaffix/core/event_mediator.lua",
      ["amstaffix.core.context"] = "src/amstaffix/core/context.lua",
      ["amstaffix.core.feature_switcher"] = "src/amstaffix/core/feature_switcher.lua",
      ["amstaffix.core.printer_dbg_registry"] = "src/amstaffix/core/printer_dbg_registry.lua",
      ["amstaffix.core.printer_dbg"] = "src/amstaffix/core/printer_dbg.lua",
      ["amstaffix.core.printer"] = "src/amstaffix/core/printer.lua",
   }
}
test_dependencies = {

}
