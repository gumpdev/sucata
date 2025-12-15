package core

import "../common"
import "../fs"
import "../graphics"
import "base:runtime"
import "core:sort"
import sapp "shared:sokol/app"
import lua "vendor:lua/5.4"

LUA_GLOBAL_STATE: ^lua.State
DEFAULT_CONTEXT: runtime.Context

width: i32 = 800
height: i32 = 600

is_build_mode: bool = false

scene: [dynamic]^common.Entity = {}
renderQueue: [dynamic]common.GraphicObjectProps = {}
destroyQueue: [dynamic]^common.Entity = {}

main :: proc() {
	init_sokol()
}

load_scene :: proc(entities: [dynamic]^common.Entity) {
	if scene != nil && len(scene) > 0 {
		run_free()
	}

	scene = entities
	run_init()
}

destroy :: proc(entity: ^common.Entity) {
	for i := 0; i < len(scene); i += 1 {
		if scene[i] == entity {
			ordered_remove(&scene, i)
			break
		}
	}
	free_obj(entity)
}

spawn :: proc(entity: ^common.Entity) -> string {
	if entity == nil {
		return ""
	}

	append(&scene, entity)
	gObj := scene[len(scene) - 1]
	init(gObj)
	return gObj.id
}

run_init :: proc() {
	if scene == nil || len(scene) == 0 {
		return
	}
	for &entity in scene {
		if entity != nil {
			init(entity)
		}
	}
}

init :: proc(entity: ^common.Entity) {
	if entity.initiated {
		return
	}
	if entity.init > 0 {
		call_lua_function_with_table_ref(LUA_GLOBAL_STATE, entity.init, entity.table)
	}
	entity.initiated = true
}

run_update :: proc() {
	if scene == nil || len(scene) == 0 {
		return
	}
	for i := len(scene) - 1; i >= 0; i -= 1 {
		if i >= len(scene) {
			continue
		}
		entity := scene[i]
		if entity != nil {
			update(entity)
		}
	}
}

update :: proc(entity: ^common.Entity) {
	if entity.update > 0 {
		call_lua_function_with_table_ref(LUA_GLOBAL_STATE, entity.update, entity.table)
	}
}

run_draw :: proc() {
	draw_debug_info()
	if scene == nil || len(scene) == 0 {
		return
	}
	for &entity in scene {
		if entity != nil {
			draw(entity)
		}
	}
	order_render_queue()
	draw_render_queue()
	clear_render_queue()
	graphics.destroy_unused_images()
}

draw :: proc(entity: ^common.Entity) {
	if entity.draw > 0 {
		call_lua_function_with_table_ref(LUA_GLOBAL_STATE, entity.draw, entity.table)
	}
}

run_free :: proc() {
	if scene == nil {
		return
	}
	for &entity in scene {
		free_obj(entity)
	}
	delete(scene)
	scene = {}

	if is_build_mode {
		fs.unload_assets()
	}
}

cleanup_scene :: proc() {
	if scene != nil && len(scene) > 0 {
		run_free()
	}
}

get_scene_count :: proc() -> int {
	if scene == nil {
		return 0
	}
	return len(scene)
}

free_obj :: proc(entity: ^common.Entity) {
	if entity == nil {
		return
	}

	if entity.free > 0 {
		call_lua_function_with_table_ref(LUA_GLOBAL_STATE, entity.free, entity.table)
		lua.L_unref(LUA_GLOBAL_STATE, lua.REGISTRYINDEX, entity.free)
	}

	if entity.init > 0 {
		lua.L_unref(LUA_GLOBAL_STATE, lua.REGISTRYINDEX, entity.init)
	}
	if entity.draw > 0 {
		lua.L_unref(LUA_GLOBAL_STATE, lua.REGISTRYINDEX, entity.draw)
	}
	if entity.update > 0 {
		lua.L_unref(LUA_GLOBAL_STATE, lua.REGISTRYINDEX, entity.update)
	}
	if entity.table > 0 {
		lua.L_unref(LUA_GLOBAL_STATE, lua.REGISTRYINDEX, entity.table)
	}

	remove_handler_owner(entity.id)
	remove_entity_tags(entity.id)
	delete_entity_id(entity)
	delete(entity.id)
	free(entity)
}

get_scene :: proc() -> [dynamic]^common.Entity {
	return scene
}

clear_scene :: proc() {
	if scene != nil && len(scene) > 0 {
		run_free()
	}
	scene = {}
}

quit :: proc() {
	sapp.quit()
}

add_to_render_queue :: proc(props: common.GraphicObjectProps) {
	append(&renderQueue, props)
}

add_to_destroy_queue :: proc(entity: ^common.Entity) {
	entity.destroyed = true
	append(&destroyQueue, entity)
}

process_destroy_queue :: proc() {
	for &entity in destroyQueue {
		destroy(entity)
	}
	clear(&destroyQueue)
}

clear_render_queue :: proc() {
	clear(&renderQueue)
}

draw_render_queue :: proc() {
	for v in renderQueue {
		switch obj in v {
		case common.QuadObjectProps:
			graphics.quad(obj)
		case common.TextObjectProps:
			graphics.text(obj)
		}
	}
}

order_render_queue :: proc() {
	sort.quick_sort_proc(
		renderQueue[:],
		proc(a: common.GraphicObjectProps, b: common.GraphicObjectProps) -> int {
			a_z_index: i32
			b_z_index: i32

			switch v in a {
			case common.QuadObjectProps:
				a_z_index = v.zIndex
			case common.TextObjectProps:
				a_z_index = v.zIndex
			}

			switch v in b {
			case common.QuadObjectProps:
				b_z_index = v.zIndex
			case common.TextObjectProps:
				b_z_index = v.zIndex
			}

			if a_z_index < b_z_index {return -1}
			if a_z_index > b_z_index {return 1}
			return 0
		},
	)
}
