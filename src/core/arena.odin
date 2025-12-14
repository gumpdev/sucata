package core

import "core:mem"

temp_arena: mem.Dynamic_Arena
temp_allocator: mem.Allocator
TEMP_ARENA_SIZE :: 4 * mem.Megabyte

init_temp_arena :: proc() {
	mem.dynamic_arena_init(&temp_arena, alignment = 64)
	temp_allocator = mem.dynamic_arena_allocator(&temp_arena)
}
