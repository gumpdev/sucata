package common

Asset_Entry :: struct {
	path:   string,
	size:   int,
	offset: int,
}

Asset_Archive :: struct {
	entries:           []Asset_Entry,
	decompressed_data: []byte,
}
