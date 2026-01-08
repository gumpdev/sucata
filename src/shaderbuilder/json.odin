package shader_builder

import "core:encoding/json"
import "core:fmt"
import "core:os"
import "core:path/filepath"

inject_shader_data :: proc(yaml_data: YamlValue) -> YamlValue {
	shaders := yaml_data.(map[string]YamlValue)["shaders"].([]YamlValue)

	for shader in shaders {
		program := shader.(map[string]YamlValue)["programs"].([]YamlValue)[0].(map[string]YamlValue)

		vertex_func := program["vertex_func"].(map[string]YamlValue)
		fragment_func := program["fragment_func"].(map[string]YamlValue)

		vertex_path := vertex_func["path"].(string)
		fragment_path := fragment_func["path"].(string)

		vertex_data, vertex_ok := os.read_entire_file_from_filename(vertex_path)
		fragment_data, fragment_ok := os.read_entire_file_from_filename(fragment_path)

		if !vertex_ok || !fragment_ok {
			fmt.println("Failed to read shader files: ", vertex_path, ", ", fragment_path)
			continue
		}

		vertex_func["data"] = vertex_data
		fragment_func["data"] = fragment_data
	}

	return yaml_data
}

generate_json :: proc(yaml_path: string, output_path: string) -> (string, bool) {
	data, data_ok := os.read_entire_file_from_filename(yaml_path)

	if !data_ok {
		fmt.println("Failed to read generated shader file: ", yaml_path)
		return "", false
	}

	data_string := string(data)
	yaml_data := inject_shader_data(parse_yaml(data_string))

	json_data, json_ok := json.marshal(yaml_data)

	if json_ok != json.Marshal_Data_Error.None {
		fmt.println("Failed to convert YAML to JSON for shader: ", yaml_path)
		return "", false
	}

	os.write_entire_file(output_path, json_data)

	return output_path, true
}
