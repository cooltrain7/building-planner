extends Node3D

class_name BuildableCursor

@export var data_control: DataController
@export_category("UI Labels")
@export var overlap_label: Label
@export var build_label: Label

var cursor_build: CursorSelection
var overlap_area: Area3D = null :
	get:
		return overlap_area
	set(new_area):
		# Remove the previous overlap_area signal connections
		if overlap_area != null:
			overlap_area.disconnect("area_entered", _on_overlap_begin)
			overlap_area.disconnect("area_exited", _on_overlap_stop)
			
		overlap_area = new_area
		
		# The curosr does not need to be detectable by other areas
		overlap_area.monitorable = false
		# The cursor must be able to detect other areas
		overlap_area.monitoring = true
		
		# Reset the collision mask and layer
		overlap_area.collision_layer = 0
		overlap_area.collision_mask = 0
		
		# The cursor must look for areas on layer 2 
		overlap_area.set_collision_mask_value(2, true)
		
		# Connect colision signals to the appropriate functions
		overlap_area.connect("area_entered", _on_overlap_begin)
		overlap_area.connect("area_exited", _on_overlap_stop)
var is_placable: bool = false :
	get:
		return is_placable
	set(new_status):
		is_placable = new_status
		if !is_placable:
			overlap_label.text = "Piece Overlapping: Yes"
			overlap_label.label_settings.font_color = Color.RED
		else:
			overlap_label.text = "Piece Overlapping: No"
			overlap_label.label_settings.font_color = Color.GREEN

func _ready():
	is_placable = true
	_setupCursor()
	_update_preview()

## Create a new cursor object with its starting selection
func _setupCursor():
	cursor_build = CursorSelection.new()
	cursor_build.build = data_control.buildables[cursor_build.build_pos]
	cursor_build.tier = cursor_build.build.base_tier()

func _input(event):
	if event is InputEventKey && event.is_pressed():
		if event.keycode == KEY_ESCAPE:
			cursor_build = null
			_update_preview()
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if is_placable && cursor_build != null:
				place_buildable()
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if cursor_build == null:
				return
			cursor_build.tier = cursor_build.build.next_tier(cursor_build.tier)
			print("Switched tiers: ",cursor_build.tier)
			_update_preview()
		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if cursor_build == null:
				_setupCursor()
			cursor_build.build_pos = data_control.next_buildable_pos(cursor_build.build_pos)
			cursor_build.build = data_control.buildables[cursor_build.build_pos]
			cursor_build.tier = cursor_build.build.base_tier()
			print("Switched build: ",cursor_build.build.get_tier(cursor_build.tier).code_name)
			_update_preview()

## Create an instance of our current buildable at our position
func place_buildable():
	var build_tier = cursor_build.build.get_tier(cursor_build.tier)
	if build_tier != null:
		var instance = build_tier.instance.instantiate()
		(instance as Node3D).position = position
		get_parent().add_child(instance)

## Remove and recreate the current preview mesh instance
func _update_preview() -> void:
	if get_child_count() > 0:
		var current_preview = get_child(0)
		if current_preview != null:
			current_preview.queue_free()
	
	if cursor_build != null:
		var build_tier = cursor_build.build.get_tier(cursor_build.tier) as BuildableTier
		build_label.text = "Build: {cName} ({tier})".format({"cName": build_tier.code_name, "tier": build_tier.tier})
		var instance = build_tier.instance.instantiate()
		(instance as Node3D).name = "preview_mesh"
		overlap_area = (instance as Area3D)
		add_child(instance)
	else:
		build_label.text = "Build: None"

# Called when another object begins overlapping
func _on_overlap_begin(_area):
	is_placable = false

# Called when another object is no longer overlapping
func _on_overlap_stop(_area):
	# Check if there are any other objects that still overlap
	if !overlap_area.has_overlapping_areas():
		is_placable = true

##Inner class container for a cursor selection
class CursorSelection:
	var build: Buildable
	var tier: int
	##Debug until a UI menu would be used to select other builds
	var build_pos: int
