package core

import sapp "../../sokol/app"
import sg "../../sokol/gfx"
import sglue "../../sokol/glue"
import shelpers "../../sokol/helpers"
import st "../../sokol/time"
import "../graphics"
import "base:runtime"
import "core:fmt"
import "core:strings"
import lua "vendor:lua/5.4"

delta_time: f64 = 0.016
time_scale: f64 = 1.0
fps: u64 = 0.0

clear_color := sg.Color {
	r = 0.0,
	g = 0.0,
	b = 0.0,
	a = 1.0,
}
last_frame_time: u64
first_frame: bool = true

calc_time :: proc() {
	current_time := st.now()

	if first_frame {
		last_frame_time = current_time
		first_frame = false
		delta_time = 0.016
		return
	}

	delta_ticks := current_time - last_frame_time
	delta_seconds := st.sec(delta_ticks)

	if delta_seconds < 0.001 {
		delta_time = 0.001
	} else if delta_seconds > 0.1 {
		delta_time = 0.1
	} else {
		delta_time = delta_seconds
	}

	last_frame_time = current_time

	if delta_time > 0.0 {
		fps = u64(1.0 / delta_time)
	}
}

init_sokol :: proc() {
	window_title := strings.clone_to_cstring(windowConfig.title)
	defer delete(window_title)

	sapp.run(
		{
			width = windowConfig.width,
			height = windowConfig.height,
			window_title = window_title,
			allocator = sapp.Allocator(shelpers.allocator(&DEFAULT_CONTEXT)),
			logger = sapp.Logger(shelpers.logger(&DEFAULT_CONTEXT)),
			swap_interval = windowConfig.vsync,
			fullscreen = windowConfig.fullscreen,
			init_cb = init_callback,
			frame_cb = frame_callback,
			cleanup_cb = cleanup_callback,
			event_cb = event_callback,
		},
	)
}

init_callback :: proc "c" () {
	context = DEFAULT_CONTEXT

	st.setup()
	sg.setup(
		{
			environment = sglue.environment(),
			allocator = sg.Allocator(shelpers.allocator(&DEFAULT_CONTEXT)),
			logger = sg.Logger(shelpers.logger(&DEFAULT_CONTEXT)),
		},
	)
	graphics.set_game_dimensions(windowConfig.width, windowConfig.height)
	graphics.init_graphics()
	fmt.printfln("Engine started with %s", sg.query_backend())

	if audio_engine_init() {
		fmt.printfln("Audio engine initialized")
	} else {
		fmt.printfln("Failed to initialize audio engine")
	}
}

cleanup_callback :: proc "c" () {
	context = DEFAULT_CONTEXT

	run_free()
	cleanup_event_handlers()
	cleanup_tags()
	cleanup_timers()
	cleanup_entities()
	audio_shutdown()
	graphics.shutdown_graphics()

	if LUA_GLOBAL_STATE != nil {
		lua.close(LUA_GLOBAL_STATE)
		LUA_GLOBAL_STATE = nil
	}

	delete(windowConfig.title)

	sg.shutdown()
	cleanup_temp_arena()
}

elapsed_time := 0.0
frame_callback :: proc "c" () {
	context = DEFAULT_CONTEXT
	context.temp_allocator = temp_allocator
	defer reset_temp_arena()

	sapp.show_mouse(windowConfig.visible_mouse)
	sapp.lock_mouse(windowConfig.lock_mouse)

	calc_time()
	update_timers(delta_time)
	audio_update()
	run_update()
	process_hoverables()

	elapsed_time += delta_time

	pass_action := sg.Pass_Action{}
	pass_action.colors[0] = {
		load_action = .CLEAR,
		clear_value = clear_color,
	}
	sg.begin_pass({swapchain = sglue.swapchain(), action = pass_action})

	if windowConfig.keep_aspect > 0 {
		screen_width := sapp.width()
		screen_height := sapp.height()
		x, y, w, h: i32

		if windowConfig.keep_aspect == 2 {
			x, y, w, h = get_game_screen_crop(screen_width, screen_height)
		} else {
			x, y, w, h = get_game_screen(screen_width, screen_height)
		}

		sg.apply_viewport(x, y, w, h, true)
		sg.apply_scissor_rect(x, y, w, h, true)
	}

	run_draw()
	sg.end_pass()

	sg.commit()
	elapsed_time = 0.0

	clear_input()
	process_destroy_queue()
}

event_callback :: proc "c" (event: ^sapp.Event) {
	context = DEFAULT_CONTEXT

	if event.type == .RESIZED {
		handle_window_resize(event.window_width, event.window_height)
	}

	handle_input_event(event)
}

handle_window_resize :: proc(width, height: i32) {
	if windowConfig.keep_aspect > 0 {
		graphics.set_game_dimensions(windowConfig.width, windowConfig.height)
	} else {
		graphics.set_game_dimensions(width, height)
	}
}
