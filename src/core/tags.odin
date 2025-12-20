package core

import "core:strings"

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
	tag_key := strings.clone(tag)
	entity_id_clone := strings.clone(entity_id)

	if _, exists := tags[tag_key]; !exists {
		tags[tag_key] = [dynamic]string{}
	}
	append(&tags[tag_key], entity_id_clone)
}

remove_tag :: proc(entity_id: string, tag: string) {
	if tag_list, exists := tags[tag]; exists {
		for i: int = 0; i < len(tag_list); i += 1 {
			if tag_list[i] == entity_id {
				delete(tag_list[i])
				ordered_remove(&tags[tag], i)
				if len(tags[tag]) == 0 {
					delete(tags[tag])
					delete(tag)
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
	keys_to_delete := make([dynamic]string, context.temp_allocator)
	for tag in tags {
		tag_list := &tags[tag]
		for i := len(tag_list) - 1; i >= 0; i -= 1 {
			if tag_list[i] == entity_id {
				delete(tag_list[i])
				ordered_remove(tag_list, i)
			}
		}
		if len(tag_list) == 0 {
			append(&keys_to_delete, tag)
		}
	}
	for key in keys_to_delete {
		delete(tags[key])
		delete(key)
		delete_key(&tags, key)
	}
}

cleanup_tags :: proc() {
	for tag, tag_list in tags {
		for entity_id in tag_list {
			delete(entity_id)
		}
		delete(tag_list)
		delete(tag)
	}
	delete(tags)
	tags = {}
}
