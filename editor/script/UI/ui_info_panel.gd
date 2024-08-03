extends MarginContainer

@export var build_status: Label
@export var overlapping_status: Label

func _ready() -> void:
	assert(build_status != null, "Build status unset")
	assert(overlapping_status != null, "Overlapping unset")
	
	EventBus.connect("on_build_overlap_change", _update_overlap_text)
	EventBus.connect("on_build_change", _update_build_text)

## Update our preview overlap text
func _update_overlap_text(overlap: bool):
	if overlap: 
		overlapping_status.text = "Piece Overlapping: Yes"
		overlapping_status.label_settings.font_color = Color.RED
	else:
		overlapping_status.text = "Piece Overlapping: No"
		overlapping_status.label_settings.font_color = Color.GREEN
		
## Update our current build text	
func _update_build_text(build: Buildable, _ui_element: Control):
	if build != null: 
		var build_tier = build.base_tier()
		if build_tier != null:
			build_status.text = "Build: {cName} ({tier})".format({"cName": build_tier.code_name, "tier": build_tier.tier})
			return
	build_status.text = "Build: None"
