extends Node3D

class_name BuildableCursor

@export var data_control: DataController
@export_category("UI Labels")
@export var overlap_label: Label
@export var build_label: Label

var build: Buildable = null
var tier: int = 0
var build_pos: int = 0
var preview_instance: Area3D = null :
	get:
		return preview_instance
	set(new_preview):
		# Remove the previous instance signal connections
		if preview_instance != null:
			preview_instance.disconnect("area_entered", _on_preview_overlap_enter)
			preview_instance.disconnect("area_exited", _on_preview_overlap_exit)
			
		preview_instance = new_preview
		
		# The curosr does not need to be detectable by other areas
		preview_instance.monitorable = false
		# The cursor must be able to detect other areas
		preview_instance.monitoring = true
		
		# Reset the collision mask and layer
		preview_instance.collision_layer = 0
		preview_instance.collision_mask = 0
		
		# The cursor must look for areas on layer 2 
		preview_instance.set_collision_mask_value(2, true)
		
		# Connect colision signals to the appropriate functions
		preview_instance.connect("area_entered", _on_preview_overlap_enter)
		preview_instance.connect("area_exited", _on_preview_overlap_exit)
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
	assert(data_control != null)
	
	is_placable = true
	_setup_cursor()
	_update_preview()

## Create a new cursor object with its starting selection
func _setup_cursor():
	build = data_control.buildables[build_pos]
	tier = build.base_tier()
	build_pos = 0

## Handle build input, place, next build, cancel
func _process(_delta):
	if Input.is_action_just_pressed("build_cancel"):
		build = null
		tier = 0
		_update_preview()
	if Input.is_action_just_pressed("build_place"):
		if is_placable && build != null:
			place_buildable()
	if Input.is_action_just_pressed("build_next_tier"):
		if build == null:
			return
		tier = build.next_tier(tier)
		print("Switched tiers: ",tier)
		_update_preview()
	if Input.is_action_just_pressed("build_next"):
		if build == null:
			_setup_cursor()
		build_pos = data_control.next_buildable_pos(build_pos)
		build = data_control.buildables[build_pos]
		tier = build.base_tier()
		print("Switched build: ",build.get_tier(tier).code_name)
		_update_preview()

## Create an instance of our current buildable at our position
func place_buildable():
	var build_tier = build.get_tier(tier)
	if build_tier != null:
		var instance = build_tier.mesh.instantiate()
		(instance as Node3D).position = position
		get_parent().add_child(instance)

## Remove and recreate the current preview mesh instance
func _update_preview() -> void:
	if get_child_count() > 0:
		var current_preview = get_child(0)
		if current_preview != null:
			current_preview.queue_free()
	
	if build != null:
		var build_tier = build.get_tier(tier) as BuildableTier
		build_label.text = "Build: {cName} ({tier})".format({"cName": build_tier.code_name, "tier": build_tier.tier})
		preview_instance = build_tier.mesh.instantiate()
		preview_instance.name = "preview_mesh"
		add_child(preview_instance)
		
	else:
		build_label.text = "Build: None"

# Called when another object begins overlapping our preview
func _on_preview_overlap_enter(_area) -> void: 
	is_placable = false

# Called when another object is no longer overlapping our preview
func _on_preview_overlap_exit(_area) -> void:
	# Check if there are any other objects that still overlap
	if !preview_instance.has_overlapping_areas():
		is_placable = true
