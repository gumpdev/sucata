package core

import "../graphics"
import "core:fmt"

PostLoadShader :: struct {
	shader_name: string,
	shader_path: string,
}

PostCommand :: union {
	PostLoadShader,
}

post_commands := [dynamic]PostCommand{}

add_post_command :: proc(data: PostCommand) {
	if is_game_started {
		process_post_command(data)
		return
	}
	append(&post_commands, data)
}

process_post_commands :: proc() {
	for command in post_commands {
		process_post_command(command)
	}
	clear(&post_commands)
}

process_post_command :: proc(data: PostCommand) {
	switch v in data {
	case PostLoadShader:
		graphics.init_shader(v.shader_name, v.shader_path)
	}
}
