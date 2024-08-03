extends Node3D

class_name BuildableCursor

var build: Buildable = null
var tier: int = 0
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
		EventBus.emit_signal("on_build_overlap_change", !is_placable)
			
func _ready():
	is_placable = true
	_update_preview()
	EventBus.connect("on_build_change", _build_change)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("build_cancel"):
		build = null
		tier = 0
		_update_preview()
	if event.is_action_pressed("build_place"):
		if is_placable && build != null:
			place_buildable()
	if event.is_action_pressed("build_next_tier"):
		if build == null:
			return
		tier = build.next_tier_num(tier)
		print("Switched tiers: ",tier)
		_update_preview()


func _build_change(event_build: Buildable, _ui_element: Control) -> void:
	build = event_build
	
	if event_build != null:
		tier = build.base_tier_num()
		print("Switched build: ",build.get_tier(tier).code_name)
	else:
		tier = 0

	_update_preview()

## Create an instance of our current buildable at our position
func place_buildable():
	var build_tier = build.get_tier(tier)
	if build_tier != null:
		var instance = build_tier.mesh.instantiate()
		(instance as Node3D).position = position
		get_parent().add_child(instance)
		EventBus.emit_signal("on_build_place", build, tier)

## Remove and recreate the current preview mesh instance
func _update_preview() -> void:
	if get_child_count() > 0:
		var current_preview = get_child(0)
		if current_preview != null:
			current_preview.queue_free()
	
	if build != null:
		var build_tier = build.get_tier(tier) as BuildableTier
		preview_instance = build_tier.mesh.instantiate()
		preview_instance.name = "preview_mesh"
		add_child(preview_instance)

# Called when another object begins overlapping our preview
func _on_preview_overlap_enter(_area) -> void: 
	is_placable = false

# Called when another object is no longer overlapping our preview
func _on_preview_overlap_exit(_area) -> void:
	# Check if there are any other objects that still overlap
	if !preview_instance.has_overlapping_areas():
		is_placable = true
