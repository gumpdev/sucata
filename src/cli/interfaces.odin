package cli


Command :: struct {
	command:     string,
	args_size:   int,
	handler:     proc(args: []string),
	info_msg:    string,
	error_msg:   string,
	subcommands: []Command,
}
