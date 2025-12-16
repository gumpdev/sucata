package lua_common

import "core:c"
import "core:strings"
import lua "vendor:lua/5.4"

delete_lua_table :: proc(table: LuaTable) {
	for key, value in table {
		switch v in value {
		case string:
			delete(v)
		case LuaTable:
			delete_lua_table(v)
		}
		delete(key)
	}
	delete(table)
}

get_table_number :: proc(
	L: ^lua.State,
	table_index: c.int,
	field: cstring,
	default_value: f64,
) -> f64 {
	lua.pushstring(L, field)
	lua.gettable(L, table_index)

	result := default_value
	if lua.isnumber(L, -1) {
		result = f64(lua.tonumber(L, -1))
	}

	lua.pop(L, 1)
	return result
}

get_table_string :: proc(
	L: ^lua.State,
	table_index: c.int,
	field: cstring,
	default_value: string,
) -> string {
	lua.pushstring(L, field)
	lua.gettable(L, table_index)

	result := default_value
	if lua.isstring(L, -1) {
		lua_str := lua.tostring(L, -1)
		result = strings.clone_from_cstring(lua_str)
	}

	lua.pop(L, 1)
	return result
}

get_table_boolean :: proc(
	L: ^lua.State,
	table_index: c.int,
	field: cstring,
	default_value: bool,
) -> bool {
	lua.pushstring(L, field)
	lua.gettable(L, table_index)

	result := default_value
	if lua.isboolean(L, -1) {
		result = bool(lua.toboolean(L, -1))
	}

	lua.pop(L, 1)
	return result
}

get_table_ref :: proc(L: ^lua.State, table_index: c.int, field: cstring) -> c.int {
	lua.pushstring(L, field)
	lua.gettable(L, table_index)

	result: c.int = -1
	if lua.isfunction(L, -1) || lua.istable(L, -1) || lua.isuserdata(L, -1) {
		result = lua.L_ref(L, lua.REGISTRYINDEX)
	} else {
		lua.pop(L, 1)
	}

	return result
}

lua_table_to_map :: proc(
	L: ^lua.State,
	table_index: c.int,
	ignored_fields: []string = nil,
) -> LuaTable {
	index := table_index
	result := make(LuaTable)

	if index < 0 {
		index = lua.gettop(L) + index + 1
	}

	lua.L_checktype(L, index, 5)

	lua.pushnil(L)

	for lua.next(L, index) != 0 {
		if lua.type(L, -2) == lua.TSTRING {
			key := strings.clone_from_cstring(lua.tostring(L, -2))

			should_ignore := false
			if ignored_fields != nil {
				for ignored_field in ignored_fields {
					if key == ignored_field {
						should_ignore = true
						break
					}
				}
			}

			if !should_ignore {
				value_type := lua.type(L, -1)
				value: any

				#partial switch value_type {
				case lua.TSTRING:
					value = strings.clone_from_cstring(lua.tostring(L, -1))
				case lua.TNUMBER:
					value = f64(lua.tonumber(L, -1))
				case lua.TBOOLEAN:
					value = cast(bool)lua.toboolean(L, -1)
				case lua.TTABLE:
					value = lua_table_to_map(L, -1, ignored_fields)
				case lua.TFUNCTION:
					value = lua.L_ref(L, lua.REGISTRYINDEX)
				case:
					value = nil
				}
				result[key] = value
			}
		}

		lua.pop(L, 1)
	}
	return result
}

get_table_array :: proc(L: ^lua.State, table_index: c.int, field: cstring) -> []c.int {
	lua.pushstring(L, field)
	lua.gettable(L, table_index)

	if !lua.istable(L, -1) {
		lua.pop(L, 1)
		return nil
	}

	length := lua.rawlen(L, -1)
	if length == 0 {
		lua.pop(L, 1)
		return nil
	}

	table_indices := make([dynamic]c.int, 0, length)
	defer delete(table_indices)

	for i: lua.Integer = 1; i <= lua.Integer(length); i += 1 {
		lua.rawgeti(L, -1, i)

		if lua.istable(L, -1) {
			table_ref := lua.L_ref(L, lua.REGISTRYINDEX)
			append(&table_indices, table_ref)
		} else {
			lua.pop(L, 1)
		}
	}

	lua.pop(L, 1)

	return table_indices[:]
}

create_lua_table_with_extras :: proc(
	L: ^lua.State,
	table_index: c.int,
	extra_fields: LuaTable,
	ignored_fields: []string = nil,
) -> i32 {
	base_map := lua_table_to_map(L, table_index, ignored_fields)
	defer delete_lua_table(base_map)

	for key, value in extra_fields {
		base_map[key] = value
	}

	return create_lua_table(L, base_map)
}

entity_IGNORED_FIELDS :: []string{"init", "draw", "update", "free"}

create_lua_table :: proc(L: ^lua.State, data: LuaTable) -> i32 {
	lua.newtable(L)

	for key, value in data {
		switch _ in value {
		case b32:
			lua.pushboolean(L, value.(b32))
		case f32:
			lua.pushnumber(L, lua.Number(value.(f32)))
		case c.int:
			if value.(c.int) > 0 {
				lua.rawgeti(L, lua.REGISTRYINDEX, lua.Integer(value.(c.int)))
			} else {
				lua.pushnumber(L, lua.Number(value.(c.int)))
			}
		case f64:
			lua.pushnumber(L, lua.Number(value.(f64)))
		case i64:
			lua.pushnumber(L, lua.Number(value.(i64)))
		case string:
			str_cstring := strings.clone_to_cstring(value.(string))
			defer delete(str_cstring)
			lua.pushstring(L, str_cstring)
		case LuaTable:
			nested_table_ref := create_lua_table(L, value.(LuaTable))
			lua.rawgeti(L, lua.REGISTRYINDEX, lua.Integer(nested_table_ref))
		}
		key_cstring := strings.clone_to_cstring(key)
		defer delete(key_cstring)
		lua.setfield(L, -2, key_cstring)
	}

	return lua.L_ref(L, lua.REGISTRYINDEX)
}
