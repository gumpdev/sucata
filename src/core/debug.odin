package core

import common "../common"
import "core:fmt"
import sg "shared:sokol/gfx"
import lua "vendor:lua/5.4"

draw_y: f32 = 10.0
draw_info_text :: proc(text: string) {
	add_to_render_queue(
		common.TextObjectProps {
			text = text,
			position = [2]f32{10, draw_y},
			color = [4]f32{1.0, 1.0, 1.0, 1.0},
			font = "",
			origin = [2]f32{0.0, 0.0},
			rotation = 0.0,
			scale = [2]f32{1.0, 1.0},
			size = 16,
			zIndex = 1000,
			fixed = true,
		},
	)
	draw_y += 20.0
}

draw_debug_info :: proc() {
	if !windowConfig.draw_debug_info {
		return
	}

	context.temp_allocator = temp_allocator

	frame_stats := sg.query_stats()
	frame_time_ms := delta_time * 1000.0
	lua_memory_kb := f64(lua.gc(LUA_GLOBAL_STATE, lua.GCCOUNT, 0))
	draw_calls := frame_stats.cur_frame.num_draw
	alives :=
		frame_stats.total.buffers.alive +
		frame_stats.total.images.alive +
		frame_stats.total.pipelines.alive +
		frame_stats.total.samplers.alive +
		frame_stats.total.views.alive +
		frame_stats.total.shaders.alive

	draw_info_text(fmt.tprintf("FPS: %d", fps))
	draw_info_text(fmt.tprintf("Entities: %d", get_scene_count()))
	draw_info_text(fmt.tprintf("Draw Calls: %d", draw_calls))
	draw_info_text(fmt.tprintf("Frame Time: %.2f ms", frame_time_ms))
	draw_info_text(fmt.tprintf("Lua Memory: %.2f KB", lua_memory_kb))
	draw_info_text(fmt.tprintf("Sokol Obj Alives: %d", alives))

	draw_y = 10.0
}
