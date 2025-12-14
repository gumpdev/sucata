package build

import "../core"
import "../fs"
import "../lua"
import "../path"
import "core:fmt"
import "core:os"
import "core:path/filepath"
import "core:strings"

get_build_assets_path :: proc() -> string {
	executable_path, _ := filepath.abs(os.args[0])
	executable_dir := filepath.dir(executable_path)
	return filepath.join({executable_dir, DEFAULT_ASSETS_PATH})
}

run :: proc(assets_hash: string) {
	file_path, _ := filepath.abs(os.args[0])
	dir_path := filepath.dir(file_path)
	assets_path := filepath.join({dir_path, DEFAULT_ASSETS_PATH})

	actual_assets_hash := get_assets_hash(assets_path)

	if !strings.equal_fold(assets_hash, actual_assets_hash) {
		fmt.panicf(
			"Build assets hash mismatch! Expected: ",
			assets_hash,
			" Got: ",
			actual_assets_hash,
		)
	}

	path.init_build_paths(assets_path)
	fs.load_assets(assets_path)
	fmt.println("Running Sucata script: ", path.location.file)

	main_path := filepath.join({dir_path, "main.lua"})
	lua.init_lua(path.location.file)
	core.main()
}
