package scene

import common "../../common"
import core "../../core"
import lua_common "../lua_common"
import "core:c"
import lua "vendor:lua/5.4"

LOAD_SCENE_FUNCTION :: lua_common.LuaFunction {
	name = "load_scene",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		if lua.gettop(L) < 1 {
			lua.pushstring(L, "load_scene expects at least 1 argument (table)")
			lua.error(L)
			return 0
		}

		if !lua.istable(L, 1) {
			lua.pushstring(L, "First argument must be a table")
			lua.error(L)
			return 0
		}

		entities := [dynamic]^common.Entity{}

		lua.len(L, 1)
		table_length := lua.tointeger(L, -1)
		lua.pop(L, 1)

		for i in 1 ..= table_length {
			lua.rawgeti(L, 1, lua.Integer(i))
			if lua.istable(L, -1) {
				entity := lua_common.create_entity_by_lua(L, lua.gettop(L))
				append(&entities, entity)
			}
			lua.pop(L, 1)
		}

		core.load_scene(entities)

		return 0
	},
}
