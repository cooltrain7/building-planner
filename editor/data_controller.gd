extends Node

class_name DataController
@export var buildables: Array[Buildable]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process0(_delta):
	pass

func next_buildable_pos(pos: int) -> int:
	if(pos >= buildables.size()-1):
		return 0
	return pos +1

func next_buildable(pos: int) -> Buildable:
	if(pos > buildables.size()-1):
		return buildables[0]
	return buildables[pos]
