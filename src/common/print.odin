package common

import "core:fmt"

print_error :: proc(msg: string) {
	fmt.printfln("\x1b[31mError: %s\x1b[0m", msg)
}

print_warning :: proc(msg: string) {
	fmt.printfln("\x1b[33mWarning: %s\x1b[0m", msg)
}

print_info :: proc(msg: string) {
	fmt.printfln("\x1b[34mInfo: %s\x1b[0m", msg)
}
