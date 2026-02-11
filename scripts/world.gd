extends Node3D

var time_passed = 0.0
var interval = 20.0

func _ready() -> void:
	AudioManager.playMain("Main")

func _process(delta: float) -> void:
	time_passed += delta
	
	if time_passed >= interval:
		AudioManager.playHorns("Horns")
		time_passed = 0.0
