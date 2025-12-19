package shader_quad

import sg "../../../sokol/gfx"

load_rect_shader :: proc() -> sg.Shader {
	return sg.make_shader(quad_shader_desc(sg.query_backend()))
}
