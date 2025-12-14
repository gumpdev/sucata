@header package shader_text
@header import sg "shared:sokol/gfx"

/* text vertex shader */
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