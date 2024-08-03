extends Node

class_name DataController
@export var buildables: Array[Buildable]

func _ready() -> void:
	EventBus.emit_signal("on_build_data_ready", buildables)

## Returns next pos in array or back to start
func next_buildable_pos(pos: int) -> int:
	return (pos + 1) % buildables.size()
