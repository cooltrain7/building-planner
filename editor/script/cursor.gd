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

var current_spline: Node3D = null
var spline_start: Vector3
var spline_end: Vector3

func _ready() -> void:
	assert(data_control != null)
	
	is_placable = true
	_setup_cursor()
	_update_preview()

## Create a new cursor object with its starting selection
func _setup_cursor() -> void:
	build = data_control.buildables[build_pos]
	tier = build.base_tier()
	build_pos = 0
	spline_start = Vector3.ZERO

## Handle build input, place, next build, cancel
func _process(_delta) -> void:
	if Input.is_action_just_pressed("build_cancel"):
		build = null
		tier = 0
		_update_preview()
	if Input.is_action_just_pressed("build_next"):
		if build == null:
			_setup_cursor()
		build_pos = data_control.next_buildable_pos(build_pos)
		build = data_control.buildables[build_pos]
		tier = build.base_tier()
		print("Switched build: ",build.get_tier(tier).code_name)
		_update_preview()
	if build == null:
		return
	if Input.is_action_just_pressed("build_place"):
		if is_placable:
			_place_buildable()
	if Input.is_action_just_pressed("build_next_tier"):
		tier = build.next_tier(tier)
		print("Switched tiers: ",tier)
		_update_preview()
	# Splines need constant updates to redraw
	if build.build_type == Buildable.BuildType.Spline:
		_update_spline_build()

## Place the correct type of build
func _place_buildable() -> void:
	if build == null:
		return
	match build.build_type:
		Buildable.BuildType.Static:
			_place_static_build()
		Buildable.BuildType.Spline:
			_place_spline_build()

## Place a new static build
func _place_static_build() -> void:
	var build_tier = build.get_tier(tier)
	if build_tier == null:
		return
	var instance = build_tier.mesh.get_default_mesh().instantiate()
	(instance as Node3D).position = position
	get_parent().add_child(instance)

## Start a new spline build
func _place_spline_build() -> void:
	if current_spline != null:
		current_spline = null
		return
	current_spline = Node3D.new()
	current_spline.name = "BuildableSpline"
	spline_start = position
	get_parent().add_child(current_spline,true)

## Recreate our active spline with the correct amount of segments
func _update_spline_build() -> void:
	if current_spline == null:
		return
	#Skip recreation if positions are the same
	if position == spline_end:
		return
	#Wipe our current spline objects before recreation
	_clear_children(current_spline)	
	
	var direction = (position - spline_start).normalized()
	if direction == Vector3.ZERO:
		return
	var distance = spline_start.distance_to(position)
	# TODO /1 should be by the size of mesh, look in getting mesh AABB
	var num_seg = ceilf(distance / 1.05)
	var step_size = distance / num_seg
	var rot = Basis().rotated(Vector3.UP, atan2(direction.x, direction.z) - (PI/2))
	
	#Loop through and create our segments
	var mesh_info = build.tiers[0].mesh as SplineMeshData
	for i in range(num_seg):
		var base_pos = spline_start + direction * (i * step_size) #+ Vector3(0.5,0,0)
		
		# Place our starting mesh if set
		if i == 0 && mesh_info.start_mesh != null:
			var start_instance = mesh_info.start_mesh.instantiate() 
			current_spline.add_child(start_instance)
			start_instance.transform.origin = base_pos + (direction * -0.35)
			start_instance.global_transform.basis = rot
			
		# Place our middle mesh along our spline at the set mesh freq
		if mesh_info.middle_mesh != null && mesh_info.middle_mesh_freq > 0 && i % mesh_info.middle_mesh_freq == 0:
			#Only place middle mesh if its not going to be at the start or end segment
			if !(mesh_info.start_mesh && i == 0 || mesh_info.end_mesh && i == num_seg - 1):
				var middle_instance = mesh_info.middle_mesh.instantiate()
				current_spline.add_child(middle_instance)
				middle_instance.transform.origin = base_pos
				middle_instance.global_transform.basis = rot
			
		# Place our main segments
		var seg_instance = mesh_info.get_default_mesh().instantiate()
		current_spline.add_child(seg_instance)
		seg_instance.transform.origin = base_pos
		seg_instance.global_transform.basis = rot
		
		# Place our end mesh if set
		if i == (num_seg -1) && mesh_info.end_mesh != null:
			var end_instance = mesh_info.end_mesh.instantiate()
			current_spline.add_child(end_instance)
			end_instance.transform.origin = base_pos + (direction * 0.75)
			end_instance.global_transform.basis = rot
	
	#Finally update our position
	spline_end = position

## Clear all children on a given node
func _clear_children(node: Node) -> void:
	if node == null:
		return
	for n in node.get_children():	
		node.remove_child(n)
		n.queue_free()

## Remove and recreate the current preview mesh instance
func _update_preview() -> void:
	if get_child_count() > 0:
		var current_preview = get_child(0)
		if current_preview != null:
			current_preview.free()
	if current_spline != null:
		_clear_children(current_spline)
		spline_start = Vector3.ZERO
		current_spline = null
	
	if build != null:
		var build_tier = build.get_tier(tier) as BuildableTier
		build_label.text = "Build: {cName} ({tier})".format({"cName": build_tier.code_name, "tier": build_tier.tier})
		if build.build_type == Buildable.BuildType.Spline:
			return;
		preview_instance = build_tier.mesh.get_default_mesh().instantiate()
		preview_instance.name = "preview_mesh"
		add_child(preview_instance)
	else:
		build_label.text = "Build: None"

## Called when another object begins overlapping our preview
func _on_preview_overlap_enter(_area) -> void: 
	is_placable = false

## Called when another object is no longer overlapping our preview
func _on_preview_overlap_exit(_area) -> void:
	# Check if there are any other objects that still overlap
	if !preview_instance.has_overlapping_areas():
		is_placable = true
