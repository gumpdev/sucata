package core

tags: map[string][dynamic]string = {}

has_tag :: proc(entity_id: string, tag: string) -> bool {
	if tag := tags[tag]; tag != nil {
		for id in tag {
			if id == entity_id {
				return true
			}
		}
	}
	return false
}

add_tag :: proc(entity_id: string, tag: string) {
	if _, exists := tags[tag]; !exists {
		tags[tag] = [dynamic]string{}
	}
	append(&tags[tag], entity_id)
}

remove_tag :: proc(entity_id: string, tag: string) {
	if tag_list, exists := tags[tag]; exists {
		for i: int = 0; i < len(tag_list); i += 1 {
			if tag_list[i] == entity_id {
				ordered_remove(&tag_list, i)
				if len(tags[tag]) == 0 {
					delete(tags[tag])
					delete_key(&tags, tag)
				}
				break
			}
		}
	}
}

get_entities :: proc(tag: string) -> ^[dynamic]string {
	if tag_list, exists := tags[tag]; exists {
		return &tags[tag]
	}
	return nil
}

remove_entity_tags :: proc(entity_id: string) {
	for tag, tag_list in tags {
		for i: int = 0; i < len(tag_list); i += 1 {
			if tag_list[i] == entity_id {
				ordered_remove(&tags[tag], i)
				if len(tags[tag]) == 0 {
					delete(tags[tag])
					delete_key(&tags, tag)
				}
				break
			}
		}
	}
}

cleanup_tags :: proc() {
	for tag, tag_list in tags {
		delete(tag_list)
	}
	delete(tags)
	tags = {}
}
