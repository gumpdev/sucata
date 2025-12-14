package scene

import core "../../core"
import lua_common "../lua_common"
import "base:runtime"
import "core:c"
import "core:strings"
import lua "vendor:lua/5.4"

GET_ENTITIES_FUNCTION :: lua_common.LuaFunction {
	name = "get_entities",
	func_ptr = proc "c" (L: ^lua.State) -> c.int {
		context = core.DEFAULT_CONTEXT

		entities := core.get_scene()

		lua.newtable(L)

		if entities != nil {
			for i := 0; i < len(entities); i += 1 {
				id := strings.clone_to_cstring(entities[i].id)
				defer delete(id)
				lua.pushinteger(L, lua.Integer(i + 1))
				lua.pushstring(L, id)
				lua.settable(L, -3)
			}
		}

		return 1
	},
}
