package = "wow-dev-core"
rockspec_format = "3.1"
version = "1.0.4-1"
source = {
   url = "git+ssh://git@github.com/WoW-U/core-luarock.git",
   tag = "v1.0.4"
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
      ["amstaffix/core/event_dispatcher"] = "src/amstaffix/core/event_dispatcher",
      ["amstaffix/core/event_mediator"] = "src/amstaffix/core/event_mediator",
      ["amstaffix/core/context"] = "src/amstaffix/core/context"
   }
}
test_dependencies = {

}
