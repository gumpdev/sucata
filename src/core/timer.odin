package core

import "core:crypto"
import "core:encoding/uuid"
import lua "vendor:lua/5.4"

Timer :: struct {
	left_time: f64,
	time:      f64,
	callback:  i32,
	one_shot:  bool,
	running:   bool,
	repeat:    bool,
}

timers := map[string]^Timer{}

create_timer :: proc(
	callback_ref: i32,
	time: f64,
	auto_start: bool,
	one_shot: bool,
	repeat: bool,
) -> string {
	context.random_generator = crypto.random_generator()

	id := uuid.to_string(uuid.generate_v4())

	timer := new(Timer)
	timer.callback = callback_ref
	timer.time = time
	timer.left_time = time
	timer.running = auto_start
	timer.one_shot = one_shot
	timer.repeat = repeat

	timers[id] = timer

	return id
}

start_timer :: proc(id: string) {
	if timer := timers[id]; timer != nil {
		timer.running = true
	}
}
pause_timer :: proc(id: string) {
	if timer := timers[id]; timer != nil {
		timer.running = false
	}
}
stop_timer :: proc(id: string) {
	if timer := timers[id]; timer != nil {
		lua.L_unref(LUA_GLOBAL_STATE, lua.REGISTRYINDEX, timer.callback)
		delete_key(&timers, id)
		free(timer)
	}
}

update_timers :: proc(delta_time: f64) {
	for id, timer in timers {
		if timer.running {
			timer.left_time -= delta_time
			if timer.left_time <= 0 {
				call_lua_function(LUA_GLOBAL_STATE, timer.callback)
				if timer.repeat {
					timer.left_time = timer.time
				} else {
					if timer.one_shot {
						stop_timer(id)
					} else {
						pause_timer(id)
					}
				}
			}
		}
	}
}

cleanup_timers :: proc() {
	for id, timer in timers {
		lua.L_unref(LUA_GLOBAL_STATE, lua.REGISTRYINDEX, timer.callback)
		delete(id)
		free(timer)
	}
	delete(timers)
	timers = {}
}
