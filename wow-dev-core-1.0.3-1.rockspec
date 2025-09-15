package = "wow-dev-core"
rockspec_format = "3.1"
version = "1.0.3-1"
source = {
   url = "git+ssh://git@github.com/WoW-U/core-luarock.git",
   tag = "v1.0.3"
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
      ["amstaff/core/test"] = "src/test.lua"
   }
}
test_dependencies = {

}
