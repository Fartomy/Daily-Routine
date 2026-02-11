extends Node

var active_sound: AudioStreamPlayer

@export_group("Main")
@export var clips: Node

func playMain(audio_name: String, from_pos: float = 0.0) -> void:
	active_sound = clips.get_node(audio_name)
	active_sound.play(from_pos)

func playHorns(audio_name: String, from_pos: float = 0.0) -> void:
	active_sound = clips.get_node(audio_name)
	active_sound.play(from_pos)
