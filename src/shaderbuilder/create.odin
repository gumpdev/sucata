package shader_builder

import "core:os"

QUAD_DEFAULT: string = `/* quad vertex shader */
@vs vs
layout(binding=0) uniform vs_params {
    mat4 mvp;
};

in vec2 position;
in vec4 col;
in vec2 uv;

out vec4 color;
out vec2 texcoord;

void main() {
    gl_Position = mvp * vec4(position, 0.0, 1.0);
    color = col;
    texcoord = uv;
}
@end

/* quad fragment shader */
@fs fs
layout(binding=0) uniform texture2D tex;
layout(binding=0) uniform sampler smp;

in vec4 color;
in vec2 texcoord;

out vec4 frag_color;

void main() {
    vec4 tex_color = texture(sampler2D(tex,smp), texcoord);
    vec4 final_color = tex_color * color;
    
    frag_color = final_color;
}
@end

/* quad shader program */
@program quad vs fs
`

FONT_DEFAULT: string = `/* text vertex shader */
@vs vs
layout(binding=0) uniform vs_params {
    mat4 mvp;
};

in vec2 position;
in vec4 col;
in vec2 uv;

out vec4 color;
out vec2 texcoord;

void main() {
    gl_Position = mvp * vec4(position, 0.0, 1.0);
    color = col;
    texcoord = uv;
}
@end

/* text fragment shader */
@fs fs
layout(binding=0) uniform texture2D tex;
layout(binding=0) uniform sampler smp;

in vec4 color;
in vec2 texcoord;

out vec4 frag_color;

void main() {
    vec4 tex_color = texture(sampler2D(tex,smp), texcoord);
    float alpha = tex_color.r * color.a;
    frag_color = vec4(color.rgb, alpha);
}
@end

/* text shader program */
@program text vs fs
`

POST_PROCESSING_DEFAULT: string = `/* post-processing vertex shader */
@vs vs
layout(location = 0) in vec2 a_pos;
layout(location = 1) in vec2 a_uv;

out vec2 v_uv;

void main() {
    v_uv = a_uv;
    gl_Position = vec4(a_pos, 0.0, 1.0);
}
@end

/* post-processing fragment shader */
@fs fs
uniform sampler2D u_scene;

in vec2 v_uv;
out vec4 frag_color;

void main() {
    vec4 color = texture(u_scene, v_uv);

    float gray = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    frag_color = vec4(vec3(gray), color.a);
}
@end

/* quad shader program */
@program quad vs fs`

create_default_quad :: proc(path: string) {
	bytes := transmute([]u8)QUAD_DEFAULT
	os.write_entire_file(path, bytes)
}

create_default_post_processing :: proc(path: string) {
	bytes := transmute([]u8)POST_PROCESSING_DEFAULT
	os.write_entire_file(path, bytes)
}

create_default_font_shader :: proc(path: string) {
	bytes := transmute([]u8)FONT_DEFAULT
	os.write_entire_file(path, bytes)
}
