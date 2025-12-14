package shader_text

import sg "shared:sokol/gfx"

load_text_shader :: proc() -> sg.Shader {
	return sg.make_shader(text_shader_desc(sg.query_backend()))
}
