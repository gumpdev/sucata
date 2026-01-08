package shader_builder

import "core:strconv"
import "core:strings"

YamlValue :: union {
	string,
	f32,
	i64,
	bool,
	[]byte,
	[]YamlValue,
	map[string]YamlValue,
}

parse_yaml :: proc(data: string) -> YamlValue {
	lines := strings.split_lines(data)
	line_index := 0
	result := parse_yaml_recursive(lines, &line_index, 0)
	return result
}

parse_yaml_recursive :: proc(lines: []string, line_index: ^int, base_indent: int) -> YamlValue {
	result: map[string]YamlValue

	for line_index^ < len(lines) {
		line := lines[line_index^]

		if strings.trim_space(line) == "" {
			line_index^ += 1
			continue
		}

		indent := get_indent(line)

		if indent < base_indent {
			break
		}

		if indent > base_indent {
			line_index^ += 1
			continue
		}

		trimmed := strings.trim_left_space(line)

		if strings.has_prefix(trimmed, "-") {
			return parse_yaml_list(lines, line_index, base_indent)
		}

		if strings.contains(trimmed, ":") {
			parts := strings.split_n(trimmed, ":", 2)
			if len(parts) != 2 {
				line_index^ += 1
				continue
			}

			key := strings.trim_space(parts[0])
			value_str := strings.trim_space(parts[1])

			line_index^ += 1

			if value_str == "" {
				if line_index^ < len(lines) {
					next_indent := get_indent(lines[line_index^])
					if next_indent > indent {
						result[key] = parse_yaml_recursive(lines, line_index, next_indent)
					}
				}
			} else {
				result[key] = parse_primitive_value(value_str)
			}
		} else {
			line_index^ += 1
		}
	}

	return result
}

parse_yaml_list :: proc(lines: []string, line_index: ^int, base_indent: int) -> YamlValue {
	result: [dynamic]YamlValue

	for line_index^ < len(lines) {
		line := lines[line_index^]

		if strings.trim_space(line) == "" {
			line_index^ += 1
			continue
		}

		indent := get_indent(line)

		if indent < base_indent {
			break
		}

		trimmed := strings.trim_left_space(line)

		if strings.has_prefix(trimmed, "-") {
			rest := strings.trim_left_space(trimmed[1:])

			if strings.contains(rest, ":") && rest != "" {
				parts := strings.split_n(rest, ":", 2)
				if len(parts) == 2 {
					key := strings.trim_space(parts[0])
					value_str := strings.trim_space(parts[1])

					item: map[string]YamlValue

					if value_str == "" {
						line_index^ += 1
						if line_index^ < len(lines) {
							next_indent := get_indent(lines[line_index^])
							if next_indent > indent {
								obj := parse_yaml_recursive(lines, line_index, next_indent)
								if obj_map, ok := obj.(map[string]YamlValue); ok {
									item[key] = obj_map
								}
							}
						}
					} else {
						item[key] = parse_primitive_value(value_str)
						line_index^ += 1
					}

					append(&result, item)
				} else {
					line_index^ += 1
				}
			} else if rest == "" {
				line_index^ += 1
				if line_index^ < len(lines) {
					next_indent := get_indent(lines[line_index^])
					if next_indent > indent {
						obj := parse_yaml_recursive(lines, line_index, next_indent)
						append(&result, obj)
					}
				}
			} else {
				append(&result, parse_primitive_value(rest))
				line_index^ += 1
			}
		} else {
			break
		}
	}

	return result[:]
}

get_indent :: proc(line: string) -> int {
	count := 0
	for c in line {
		if c == ' ' {
			count += 1
		} else if c == '\t' {
			count += 4
		} else {
			break
		}
	}
	return count
}

parse_primitive_value :: proc(value: string) -> YamlValue {
	value := strings.trim_space(value)

	if bool_value, ok := strconv.parse_bool(value); ok {
		return bool_value
	}

	if int_value, ok := strconv.parse_i64(value); ok {
		return int_value
	}

	if f32_value, ok := strconv.parse_f32(value); ok {
		return f32_value
	}

	return value
}

parse_yaml_value :: proc(line: string) -> YamlValue {
	parts := strings.split(line, ":")
	key := strings.trim(parts[0], " \t\n")
	value := strings.trim(parts[1], " \t\n")

	if bool_value, ok := strconv.parse_bool(value); ok {
		return bool_value
	} else if f32_value, ok := strconv.parse_f32(value); ok {
		return f32_value
	}
	return value
}
