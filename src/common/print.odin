package common

import "core:fmt"

print_error :: proc(template: string, args: ..any) {
	fmt.printfln("\x1b[31mError: %s\x1b[0m", fmt.tprintf(template, ..args))
}

print_warning :: proc(template: string, args: ..any) {
	fmt.printfln("\x1b[33mWarning: %s\x1b[0m", fmt.tprintf(template, ..args))
}

print_info :: proc(msg: string, args: ..any) {
	fmt.printfln("\x1b[34m%s\x1b[0m", fmt.tprintf(msg, ..args))
}

print_success :: proc(msg: string, args: ..any) {
	fmt.printfln("\x1b[32m%s\x1b[0m", fmt.tprintf(msg, ..args))
}

print :: proc(msg: string, args: ..any) {
	fmt.printfln(msg, ..args)
}
