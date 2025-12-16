package graphic

hex_to_rgba :: proc(color: string) -> [4]f32 {
	hex := color
	if len(hex) > 0 && hex[0] == '#' {
		hex = hex[1:]
	}

	if len(hex) == 3 || len(hex) == 4 {
		expanded := make([]u8, len(hex) * 2)
		defer delete(expanded)
		for i in 0 ..< len(hex) {
			expanded[i * 2] = hex[i]
			expanded[i * 2 + 1] = hex[i]
		}
		hex = string(expanded)
	}

	if len(hex) != 6 && len(hex) != 8 {
		return [4]f32{0, 0, 0, 1}
	}

	hex_byte := proc(s: string) -> u8 {
		result: u8 = 0
		for ch in s {
			result *= 16
			if ch >= '0' && ch <= '9' {
				result += u8(ch - '0')
			} else if ch >= 'a' && ch <= 'f' {
				result += u8(ch - 'a' + 10)
			} else if ch >= 'A' && ch <= 'F' {
				result += u8(ch - 'A' + 10)
			}
		}
		return result
	}

	r := f32(hex_byte(hex[0:2])) / 255.0
	g := f32(hex_byte(hex[2:4])) / 255.0
	b := f32(hex_byte(hex[4:6])) / 255.0
	a := f32(1.0)

	if len(hex) == 8 {
		a = f32(hex_byte(hex[6:8])) / 255.0
	}

	return [4]f32{r, g, b, a}
}
