@header package shader_quad
@header import sg "../../../sokol/gfx"

/* quad vertex shader */
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