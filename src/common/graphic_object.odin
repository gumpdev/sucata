package common

TextAlign :: enum {
	Left,
	Center,
	Right,
}

AtlasProps :: struct {
	width:   f32,
	height:  f32,
	spacing: f32,
	margin:  f32,
	x:       f32,
	y:       f32,
}

ShaderArgumentValue :: union {
	f32,
	[2]f32,
	[3]f32,
	[4]f32,
	string,
}

ShaderArgs :: map[string]ShaderArgumentValue

QuadObjectProps :: struct {
	zIndex:      i32,
	position:    [2]f32,
	size:        [2]f32,
	color:       [4]f32,
	texture:     string,
	shader:      string,
	scale:       [2]f32,
	origin:      [2]f32,
	rotation:    f32,
	opacity:     Maybe(f32),
	fixed:       bool,
	atlas:       AtlasProps,
	shader_args: ShaderArgs,
}

TextObjectProps :: struct {
	text:        string,
	zIndex:      i32,
	position:    [2]f32,
	font:        string,
	shader:      string,
	size:        f32,
	color:       [4]f32,
	scale:       [2]f32,
	origin:      [2]f32,
	fixed:       bool,
	rotation:    f32,
	opacity:     Maybe(f32),
	align:       TextAlign,
	maxWidth:    f32,
	shader_args: ShaderArgs,
}

GraphicObjectProps :: union {
	QuadObjectProps,
	TextObjectProps,
}
