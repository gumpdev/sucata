package file_system

import lua_common "../lua_common"

FILE_SYSTEM_NAMESPACE :: lua_common.LuaNamespace {
	name      = "filesystem",
	functions = []lua_common.LuaFunction {
		EXISTS_FUNCTION,
		REMOVE_FUNCTION,
		MKDIR_FUNCTION,
		READ_FILE_FUNCTION,
		READ_DIR_FUNCTION,
		RENAME_FUNCTION,
		WRITE_FUNCTION,
	},
}
