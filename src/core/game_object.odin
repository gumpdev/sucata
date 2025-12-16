package core

import common "../common"

entities: map[string]^common.Entity = {}

find_by_id :: proc(id: string) -> ^common.Entity {
	if obj_ptr := entities[id]; obj_ptr != nil {
		if !obj_ptr.destroyed {
			return obj_ptr
		}
	}
	return nil
}

save_entity_id :: proc(entity: ^common.Entity) {
	entities[entity.id] = entity
}

delete_entity_id :: proc(entity: ^common.Entity) {
	if entity == nil {
		return
	}
	delete_key(&entities, entity.id)
}

cleanup_entities :: proc() {
	delete(entities)
	entities = {}
}
