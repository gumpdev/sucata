package lua

import core "../core"
import "../fs"
import "../path"
import "./audio"
import cam "./camera"
import "./file_system"
import mathns "./math"
import "./scene"
import "./window"
import "base:runtime"
import "core:c"
import "core:fmt"
import "core:os"
import "core:strings"
import "events"
import "graphic"
import "input"
import lua_common "lua_common"
import timens "time"
import lua "vendor:lua/5.4"

GC_Config :: struct {
	pause:        c.int,
	step_mul:     c.int,
	step_size:    c.int,
	emergency_gc: bool,
	auto_gc:      bool,
}

default_gc_config := GC_Config {
	pause        = 200,
	step_mul     = 200,
	step_size    = 1024,
	emergency_gc = true,
	auto_gc      = true,
}

lua_namespaces :: []lua_common.LuaNamespace {
	audio.AUDIO_NAMESPACE,
	cam.CAMERA_NAMESPACE,
	file_system.FILE_SYSTEM_NAMESPACE,
	graphic.GRAPHIC_NAMESPACE,
	scene.SCENE_NAMESPACE,
	timens.TIME_NAMESPACE,
	events.EVENTS_NAMESPACE,
	input.INPUT_NAMESPACE,
	mathns.MATH_NAMESPACE,
	window.WINDOW_NAMESPACE,
}

lua_allocator :: proc "c" (ud: rawptr, ptr: rawptr, osize, nsize: c.size_t) -> (buf: rawptr) {
	old_size := int(osize)
	new_size := int(nsize)
	context = core.DEFAULT_CONTEXT

	if ptr == nil {
		data, err := runtime.mem_alloc(new_size)
		return raw_data(data) if err == .None else nil
	} else {
		if nsize > 0 {
			data, err := runtime.mem_resize(ptr, old_size, new_size)
			return raw_data(data) if err == .None else nil
		} else {
			runtime.mem_free(ptr)
			return
		}
	}
}

load_file_as_cstring :: proc(path: string) -> (cstring, bool) {
	data, ok := os.read_entire_file(path)
	if !ok {
		return "", false
	}
	s := strings.clone_to_cstring(string(data))
	delete(data)
	return s, true
}

custom_loader :: proc "c" (L: ^lua.State) -> c.int {
	context = core.DEFAULT_CONTEXT

	module_name := lua.tostring(L, 1)
	if module_name == nil {
		return 0
	}

	module_str := string(module_name)
	module_path, ok := strings.replace_all(module_str, ".", "/")
	defer delete(module_path)

	asset_patterns := []string {
		fmt.tprintf("src://%s.lua", module_path),
		fmt.tprintf("src://%s/init.lua", module_path),
		fmt.tprintf("%s.lua", module_path),
		fmt.tprintf("%s/init.lua", module_path),
	}

	for pattern in asset_patterns {
		if asset_data, ok := fs.get_asset(pattern); ok && len(asset_data) > 0 {
			code := strings.clone_to_cstring(string(asset_data))
			defer delete_cstring(code)

			if lua.L_loadstring(L, code) == .OK {
				return 1
			}
		}
	}

	fs_patterns := []string {
		fmt.tprintf("%s.lua", module_path),
		fmt.tprintf("%s/init.lua", module_path),
	}

	for pattern in fs_patterns {
		full_path := path.get_path(pattern)
		if os.exists(full_path) {
			data, read_ok := os.read_entire_file(full_path)
			if read_ok {
				code := strings.clone_to_cstring(string(data))
				delete(data)
				defer delete_cstring(code)

				if lua.L_loadstring(L, code) == .OK {
					return 1
				}
			}
		}
	}

	return 0
}

load_path :: proc() {
	L := core.LUA_GLOBAL_STATE

	lua.getglobal(L, "package")
	lua.getfield(L, -1, "searchers")

	lua.pushcfunction(L, custom_loader)
	lua.rawseti(L, -2, 1)

	lua.pop(L, 1)

	lua.getfield(L, -1, "path")
	old_path := lua.tostring(L, -1)
	lua.pop(L, 1)

	script_dir := path.location.src

	new_path := fmt.tprintf(
		"%s;%s/?.lua;%s/?/init.lua;%s/?/?.lua",
		old_path,
		script_dir,
		script_dir,
		script_dir,
	)
	cstring_new_path := strings.clone_to_cstring(new_path)
	defer delete_cstring(cstring_new_path)

	lua.pushstring(L, cstring_new_path)
	lua.setfield(L, -2, "path")

	lua.pop(L, 1)
}

init_lua :: proc(path: string, entity_file: string = "") {
	L := lua.newstate(lua_allocator, &core.DEFAULT_CONTEXT)
	core.LUA_GLOBAL_STATE = L

	lua.L_openlibs(L)
	setup_garbage_collector(L, default_gc_config)
	create_namespaces(L)
	load_path()

	fmt.println("Loading Lua script:", path)

	code: cstring
	ok: bool

	if entity_file != "" {
		lua_code := fmt.tprintf(
			"local Entity = require('%s')\nsucata.scene.load_scene({{Entity()}})\nprint('oieu')",
			entity_file,
		)
		ok = true
		code = strings.clone_to_cstring(lua_code)
	} else if asset_data, found := fs.get_asset(path); found && len(asset_data) > 0 {
		code = strings.clone_to_cstring(string(asset_data))
		ok = true
	} else {
		code, ok = load_file_as_cstring(path)
	}

	if !ok {
		return
	}
	defer delete_cstring(code)

	if lua.L_dostring(L, code) != 0 {
		err := lua.tostring(L, -1)
		fmt.println("Erro Lua:", err)
		lua.pop(L, 1)
	} else {
		if lua.gettop(L) > 0 && lua.isstring(L, -1) {
			msg := lua.tostring(L, -1)
			fmt.print(msg)
		}
	}
}

create_namespaces :: proc(L: ^lua.State) {
	lua.newtable(L)
	for namespace in lua_namespaces {
		lua.newtable(L)

		for func in namespace.functions {
			lua.pushcfunction(L, func.func_ptr)
			lua.setfield(L, -2, func.name)
		}

		lua.setfield(L, -2, namespace.name)
	}
	lua.setglobal(L, "sucata")
}

setup_garbage_collector :: proc(L: ^lua.State, config: GC_Config) {
	if !config.auto_gc {
		lua.gc(L, lua.GCSTOP, 0)
	} else {
		lua.gc(L, lua.GCRESTART, 0)
	}

	lua.gc(L, lua.GCSETPAUSE, config.pause)
	lua.gc(L, lua.GCSETSTEPMUL, config.step_mul)

	fmt.printf(
		"GC configurado - Pause: %d%%, StepMul: %d%%, Auto: %t\n",
		config.pause,
		config.step_mul,
		config.auto_gc,
	)
}
