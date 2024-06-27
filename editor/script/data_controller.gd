extends Node

class_name DataController
@export var buildables: Array[Buildable]

## Returns next pos in array or back to start
func next_buildable_pos(pos: int) -> int:
	return (pos + 1) % buildables.size()
