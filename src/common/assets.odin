package common

Asset_Entry :: struct {
	path:   string,
	cache:  []byte,
	size:   int,
	offset: int,
}

Asset_Archive :: struct {
	entries: []Asset_Entry,
	path:    string,
}
