package graphics

import sg "../../sokol/gfx"
import "core:strings"

DEFAULT_SAMPLER_KEY :: "__default__"

SamplerProps :: struct {
	min_filter: string,
	mag_filter: string,
	wrap_u:     string,
	wrap_v:     string,
}

sampler_loaded: map[string]sg.Sampler = map[string]sg.Sampler{}
sampler_used: map[string]bool = map[string]bool{}

load_sampler :: proc() {

}

string_to_sampler_wrap :: proc(s: string) -> sg.Wrap {
	switch s {
	case "clamp_to_edge":
		return .CLAMP_TO_EDGE
	case "repeat":
		return .REPEAT
	case "mirrored_repeat":
		return .MIRRORED_REPEAT
	case "clamp_to_border":
		return .CLAMP_TO_BORDER
	}
	return .CLAMP_TO_EDGE
}

string_to_sampler_filter :: proc(s: string) -> sg.Filter {
	switch s {
	case "nearest":
		return .NEAREST
	case "linear":
		return .LINEAR
	}
	return .NEAREST
}

sampler_string_key :: proc(props: SamplerProps) -> string {
	return strings.concatenate({props.min_filter, props.mag_filter, props.wrap_u, props.wrap_v})
}
