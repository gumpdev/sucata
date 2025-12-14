package common

Entity :: struct {
	id:        string,
	table:     i32,
	update:    i32,
	draw:      i32,
	free:      i32,
	init:      i32,
	initiated: bool,
	destroyed: bool,
}
