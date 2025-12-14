package lua_common

import common "../../common"
import "../../core"
import "core:c"
import "core:crypto"
import "core:encoding/uuid"
import "core:fmt"
import "core:strings"
import lua "vendor:lua/5.4"

lua_table_to_entity :: proc(L: ^lua.State, table_index: c.int) -> ^common.Entity {
	context.random_generator = crypto.random_generator()
	id := uuid.to_string(uuid.generate_v4())
	name := get_table_string(L, table_index, "name", "")
	init := get_table_ref(L, table_index, "init")
	draw := get_table_ref(L, table_index, "draw")
	update := get_table_ref(L, table_index, "update")
	free := get_table_ref(L, table_index, "free")

	game_obj := new(common.Entity)
	game_obj^ = common.Entity {
		id     = id,
		init   = init,
		draw   = draw,
		update = update,
		free   = free,
	}

	return game_obj
}

create_entity_by_lua :: proc(L: ^lua.State, table_index: c.int) -> ^common.Entity {
	entity := lua_table_to_entity(L, table_index)
	entity.table = create_processed_lua_table(L, table_index, entity.id)
	core.save_entity_id(entity)
	return entity
}

copy_lua_table_with_modifications :: proc(L: ^lua.State, table_index: c.int, id: string) -> i32 {
	lua.newtable(L)
	new_table_index := lua.gettop(L)

	lua.pushnil(L)
	for lua.next(L, table_index) != 0 {
		lua.pushvalue(L, -2)
		lua.pushvalue(L, -2)
		lua.settable(L, new_table_index)

		lua.pop(L, 1)
	}

	if lua.getmetatable(L, table_index) != 0 {
		lua.setmetatable(L, new_table_index)
	}

	id_cstring := strings.clone_to_cstring(id)
	defer delete_cstring(id_cstring)
	lua.pushstring(L, id_cstring)
	lua.setfield(L, new_table_index, "id")

	return lua.L_ref(L, lua.REGISTRYINDEX)
}

create_processed_lua_table :: proc(L: ^lua.State, table_index: c.int, id: string) -> i32 {
	return copy_lua_table_with_modifications(L, table_index, id)
}

get_entity_id :: proc(L: ^lua.State, table_index: c.int) -> string {
	if lua.istable(L, table_index) {
		return get_table_string(L, table_index, "id", "")
	} else if lua.isstring(L, table_index) {
		return string(lua.tostring(L, table_index))
	}
	return ""
}
