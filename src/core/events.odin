package core

import common "../common"
import lua "vendor:lua/5.4"

event_handlers: map[string][dynamic]common.EventHandler = {}

add_handler :: proc(owner: string, event: string, function_ref: i32) {
	if _, exists := event_handlers[event]; !exists {
		event_handlers[event] = [dynamic]common.EventHandler{}
	}
	handler := common.EventHandler {
		function = function_ref,
		owner    = owner,
	}
	append(&event_handlers[event], handler)
}

remove_handler :: proc(owner: string, event: string, function_ref: i32) {
	if handlers, exists := event_handlers[event]; exists {
		for i: int = 0; i < len(handlers); i += 1 {
			handler := handlers[i]
			if handler.owner == owner && handler.function == function_ref {
				ordered_remove(&handlers, i)
				break
			}
		}
	}
}

remove_handler_owner :: proc(owner: string) {
	for event, handlers in event_handlers {
		for i: int = 0; i < len(handlers); i += 1 {
			handler := handlers[i]
			if handler.owner == owner {
				ordered_remove(&event_handlers[event], i)
			}
		}
		if len(event_handlers[event]) == 0 {
			delete(event_handlers[event])
			delete_key(&event_handlers, event)
		}
	}
}

emit_event :: proc(event: string, data: i32) {
	if handlers, exists := event_handlers[event]; exists {
		for i: int = 0; i < len(handlers); i += 1 {
			handler := handlers[i]
			call_lua_function_with_table_ref(LUA_GLOBAL_STATE, handler.function, data)
		}
	}
}

cleanup_event_handlers :: proc() {
	for event, handlers in event_handlers {
		for handler in handlers {
			lua.L_unref(LUA_GLOBAL_STATE, lua.REGISTRYINDEX, handler.function)
		}
		delete(handlers)
	}
	delete(event_handlers)
	event_handlers = {}
}
