package core

import sapp "../../sokol/app"
import "core:strings"

string_to_mouse_cursor :: proc(s: string) -> sapp.Mouse_Cursor {
	s_lower := strings.to_lower(s)
	defer delete(s_lower)

	switch s_lower {
	case "default":
		return .DEFAULT
	case "arrow":
		return .ARROW
	case "ibeam":
		return .IBEAM
	case "crosshair":
		return .CROSSHAIR
	case "pointing_hand":
		return .POINTING_HAND
	case "resize_ew":
		return .RESIZE_EW
	case "resize_ns":
		return .RESIZE_NS
	case "resize_nwse":
		return .RESIZE_NWSE
	case "resize_nesw":
		return .RESIZE_NESW
	case "resize_all":
		return .RESIZE_ALL
	case "not_allowed":
		return .NOT_ALLOWED

	case "custom_0":
		return .CUSTOM_0
	case "custom_1":
		return .CUSTOM_1
	case "custom_2":
		return .CUSTOM_2
	case "custom_3":
		return .CUSTOM_3
	case "custom_4":
		return .CUSTOM_4
	case "custom_5":
		return .CUSTOM_5
	case "custom_6":
		return .CUSTOM_6
	case "custom_7":
		return .CUSTOM_7
	case "custom_8":
		return .CUSTOM_8
	case "custom_9":
		return .CUSTOM_9
	case "custom_10":
		return .CUSTOM_10
	case "custom_11":
		return .CUSTOM_11
	case "custom_12":
		return .CUSTOM_12
	case "custom_13":
		return .CUSTOM_13
	case "custom_14":
		return .CUSTOM_14
	case "custom_15":
		return .CUSTOM_15
	}

	return .DEFAULT
}

mouse_cursor_to_string :: proc(c: sapp.Mouse_Cursor) -> string {
	switch c {
	case .DEFAULT:
		return "default"
	case .ARROW:
		return "arrow"
	case .IBEAM:
		return "ibeam"
	case .CROSSHAIR:
		return "crosshair"
	case .POINTING_HAND:
		return "pointing_hand"
	case .RESIZE_EW:
		return "resize_ew"
	case .RESIZE_NS:
		return "resize_ns"
	case .RESIZE_NWSE:
		return "resize_nwse"
	case .RESIZE_NESW:
		return "resize_nesw"
	case .RESIZE_ALL:
		return "resize_all"
	case .NOT_ALLOWED:
		return "not_allowed"

	case .CUSTOM_0:
		return "custom_0"
	case .CUSTOM_1:
		return "custom_1"
	case .CUSTOM_2:
		return "custom_2"
	case .CUSTOM_3:
		return "custom_3"
	case .CUSTOM_4:
		return "custom_4"
	case .CUSTOM_5:
		return "custom_5"
	case .CUSTOM_6:
		return "custom_6"
	case .CUSTOM_7:
		return "custom_7"
	case .CUSTOM_8:
		return "custom_8"
	case .CUSTOM_9:
		return "custom_9"
	case .CUSTOM_10:
		return "custom_10"
	case .CUSTOM_11:
		return "custom_11"
	case .CUSTOM_12:
		return "custom_12"
	case .CUSTOM_13:
		return "custom_13"
	case .CUSTOM_14:
		return "custom_14"
	case .CUSTOM_15:
		return "custom_15"
	}

	return "default"
}


set_cursor :: proc(cursor: string) {
	sapp.set_mouse_cursor(string_to_mouse_cursor(cursor))
}

get_cursor :: proc() -> string {
	return mouse_cursor_to_string(sapp.get_mouse_cursor())
}
