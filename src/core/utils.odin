package core

import "core:c"
import "core:fmt"
import lua "vendor:lua/5.4"

call_lua_function :: proc(L: ^lua.State, function_ref: i32) -> bool {
	top := lua.gettop(L)
	if function_ref <= 0 {
		return false
	}

	if lua.checkstack(L, 1) == 0 {
		fmt.println("Error: Lua stack overflow")
		return false
	}

	lua.rawgeti(L, lua.REGISTRYINDEX, lua.Integer(function_ref))

	if !lua.isfunction(L, -1) {
		lua.pop(L, 1)
		return false
	}

	result := lua.pcall(L, 0, 0, 0)
	if result != 0 {
		msg := lua.tostring(L, -1)
		fmt.println("Error calling Lua function: ", msg)
		lua.pop(L, 1)

		lua.gc(L, lua.GCCOLLECT, 0)
	}

	lua.settop(L, top)

	return result == 0
}

call_lua_function_with_table_ref :: proc(
	L: ^lua.State,
	function_ref: i32,
	table_ref: i32,
) -> bool {
	top := lua.gettop(L)
	if function_ref <= 0 || table_ref <= 0 {
		fmt.println("Invalid function or table reference")
		return false
	}

	if lua.checkstack(L, 3) == 0 {
		fmt.println("Error: Lua stack overflow")
		return false
	}

	lua.rawgeti(L, lua.REGISTRYINDEX, lua.Integer(function_ref))
	lua.rawgeti(L, lua.REGISTRYINDEX, lua.Integer(table_ref))

	if !lua.isfunction(L, -2) {
		lua.pop(L, 2)
		return false
	}
	if !lua.istable(L, -1) {
		lua.pop(L, 2)
		return false
	}

	result := lua.pcall(L, 1, 0, 0)
	if result != 0 {
		msg := lua.tostring(L, -1)
		fmt.println("Error calling Lua function: ", msg)
		lua.pop(L, 1)

		lua.gc(L, lua.GCCOLLECT, 0)
	}

	lua.settop(L, top)

	return result == 0
}

get_memory_usage :: proc(L: ^lua.State) -> (kb_used: c.int, bytes_used: c.int) {
	if L == nil do return 0, 0

	kb_used = lua.gc(L, lua.GCCOUNT, 0)
	bytes_used = lua.gc(L, lua.GCCOUNTB, 0)
	return
}

monitor_gc :: proc(L: ^lua.State) {
	if L == nil do return

	kb, bytes := get_memory_usage(L)
	count := lua.gettop(L)
	fmt.printf("GC Monitor: %d na stack\n", count)
	fmt.printf("GC Monitor: %dKB + %d bytes em uso\n", kb, bytes)
}
