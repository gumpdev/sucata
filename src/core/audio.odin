package core

import "../fs"
import "../path"
import "base:runtime"
import "core:strings"
import ma "vendor:miniaudio"

Sound :: struct {
	id:       u32,
	sound:    ma.sound,
	decoder:  ma.decoder,
	is_valid: bool,
}

AudioMixer :: struct {
	engine:  ma.engine,
	groups:  map[string]^ma.sound_group,
	sounds:  [512]Sound,
	next_id: u32,
}

mixer := AudioMixer{}

audio_engine_init :: proc() -> bool {
	context = DEFAULT_CONTEXT

	engineConfig := ma.engine_config_init()

	if ma.engine_init(&engineConfig, &mixer.engine) != .SUCCESS {
		return false
	}

	create_audio_group("default")
	mixer.next_id = 1
	return true
}

create_audio_group :: proc(audio_group: string) -> bool {
	mixer.groups[audio_group] = new(ma.sound_group)

	sound_group_config := ma.sound_group_config_init_2(&mixer.engine)
	if result := ma.sound_group_init_ex(
		&mixer.engine,
		&sound_group_config,
		mixer.groups[audio_group],
	); result != .SUCCESS {
		return false
	}

	ma.sound_group_set_volume(mixer.groups[audio_group], 1.0)

	return true
}

audio_shutdown :: proc() {
	for &s in mixer.sounds {
		if s.is_valid {
			ma.sound_stop(&s.sound)
		}
	}

	for &s in mixer.sounds {
		if s.is_valid {
			ma.sound_uninit(&s.sound)
			ma.decoder_uninit(&s.decoder)
			s.is_valid = false
		}
	}

	for g in mixer.groups {
		ma.sound_group_uninit(mixer.groups[g])
		free(mixer.groups[g])
	}

	ma.engine_uninit(&mixer.engine)
}

find_free_slot :: proc() -> (^Sound, bool) {
	for &s in mixer.sounds {
		if !s.is_valid {
			return &s, true
		}
	}

	for &s in mixer.sounds {
		if s.is_valid && !ma.sound_is_looping(&s.sound) {
			if !ma.sound_is_playing(&s.sound) && ma.sound_at_end(&s.sound) {
				ma.sound_uninit(&s.sound)
				ma.decoder_uninit(&s.decoder)
				s.is_valid = false
				return &s, true
			}
		}
	}

	return nil, false
}

find_sound_by_id :: proc(id: u32) -> (^Sound, bool) {
	for &s in mixer.sounds {
		if s.is_valid && s.id == id {
			return &s, true
		}
	}
	return nil, false
}

audio_update :: proc() {
	for &s in mixer.sounds {
		if s.is_valid {
			if !ma.sound_is_looping(&s.sound) {
				if !ma.sound_is_playing(&s.sound) && ma.sound_at_end(&s.sound) {
					ma.sound_uninit(&s.sound)
					ma.decoder_uninit(&s.decoder)
					s.is_valid = false
				}
			}
		}
	}
}


load_sound :: proc(sound_path: string, group: string = "default") -> (u32, bool) {
	context = DEFAULT_CONTEXT

	slot, ok := find_free_slot()
	if !ok {
		return 0, false
	}

	mixer_group := mixer.groups[group]
	if mixer_group == nil {
		create_audio_group(group)
		mixer_group = mixer.groups[group]
	}

	if asset_data, ok := fs.get_asset(sound_path); ok && len(asset_data) > 0 {
		if ma.decoder_init_memory(&asset_data[0], len(asset_data), nil, &slot.decoder) !=
		   .SUCCESS {
			return 0, false
		}

		if ma.sound_init_from_data_source(
			   &mixer.engine,
			   cast(^ma.data_source)&slot.decoder,
			   {.STREAM},
			   mixer_group,
			   &slot.sound,
		   ) !=
		   .SUCCESS {
			ma.decoder_uninit(&slot.decoder)
			return 0, false
		}
	} else {
		c_path := strings.clone_to_cstring(path.get_path(sound_path))
		defer delete(c_path)
		result := ma.sound_init_from_file(
			&mixer.engine,
			c_path,
			{.STREAM},
			mixer_group,
			nil,
			&slot.sound,
		)
		if result != .SUCCESS {
			return 0, false
		}
	}

	slot.id = mixer.next_id
	slot.is_valid = true

	mixer.next_id += 1

	return slot.id, true
}

play_sound :: proc(id: u32, volume: f32 = 1.0, pitch: f32 = 1.0, loop: b32 = false) {
	s, ok := find_sound_by_id(id)
	if !ok {
		return
	}

	ma.sound_set_volume(&s.sound, volume)
	ma.sound_set_looping(&s.sound, loop)
	ma.sound_set_pitch(&s.sound, pitch)

	ma.sound_seek_to_pcm_frame(&s.sound, 0)
	ma.sound_start(&s.sound)
}

unpause_sound :: proc(id: u32) {
	s, ok := find_sound_by_id(id)
	if !ok {
		return
	}
	ma.sound_start(&s.sound)
}

pause_sound :: proc(id: u32) {
	s, ok := find_sound_by_id(id)
	if !ok {
		return
	}
	ma.sound_stop(&s.sound)
}

stop_sound :: proc(id: u32) {
	s, ok := find_sound_by_id(id)
	if !ok {
		return
	}
	ma.sound_stop(&s.sound)
	ma.sound_uninit(&s.sound)
	ma.decoder_uninit(&s.decoder)
	s.is_valid = false
}

set_sound_volume :: proc(id: u32, volume: f32) {
	s, ok := find_sound_by_id(id)
	if !ok {
		return
	}
	ma.sound_set_volume(&s.sound, volume)
}

get_sound_volume :: proc(id: u32) -> f32 {
	s, ok := find_sound_by_id(id)
	if !ok {
		return 0.0
	}
	return ma.sound_get_volume(&s.sound)
}

set_sound_pitch :: proc(id: u32, pitch: f32) {
	s, ok := find_sound_by_id(id)
	if !ok {
		return
	}
	ma.sound_set_pitch(&s.sound, pitch)
}

get_sound_pitch :: proc(id: u32) -> f32 {
	s, ok := find_sound_by_id(id)
	if !ok {
		return 0.0
	}
	return ma.sound_get_pitch(&s.sound)
}

set_group_volume :: proc(group: string, volume: f32) {
	if _, ok := mixer.groups[group]; !ok {
		return
	}
	ma.sound_group_set_volume(mixer.groups[group], volume)
}

get_group_volume :: proc(group: string) -> f32 {
	if _, ok := mixer.groups[group]; !ok {
		return 0.0
	}
	return ma.sound_group_get_volume(mixer.groups[group])
}

set_group_pitch :: proc(group: string, pitch: f32) {
	if _, ok := mixer.groups[group]; !ok {
		return
	}
	ma.sound_group_set_pitch(mixer.groups[group], pitch)
}

get_group_pitch :: proc(group: string) -> f32 {
	if _, ok := mixer.groups[group]; !ok {
		return 0.0
	}
	return ma.sound_group_get_pitch(mixer.groups[group])
}
