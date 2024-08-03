extends MarginContainer

@export var build_item_scene: PackedScene
@export var build_list_parent: VBoxContainer

var build_items: Array[BuildItem]
var selected_ele: StructPanelItem

func _ready() -> void:
	assert(build_item_scene != null, "Build item unset")
	assert(build_list_parent != null, "Build list parent unset")
	
	EventBus.connect("on_build_data_ready",_on_build_data)
	EventBus.connect("on_build_change", _on_build_change)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("build_cancel"):
		if selected_ele != null:
			selected_ele.deselect()

## Called when the data controller has completed its processing
func _on_build_data(buildables: Array[Buildable]) -> void:
	for build in buildables:
		_add_build_item(build)

## Called by a structure panel item being selected
func _on_build_change(_build: Buildable, ui_element: Control) -> void:
	if selected_ele != null && selected_ele != ui_element:
		selected_ele.deselect()
	selected_ele = ui_element

## Add a new build item into our UI
func _add_build_item(build: Buildable) -> void:
	if build == null || build.base_tier() == null:
		return
	print("Adding item ", build.base_tier().disp_name)
	var item = BuildItem.new()
	var ele = _create_build_ui(build)
	item.element = ele
	item.build = build
	build_list_parent.add_child(ele)
	build_items.append(item)

## Create our build item elements
func _create_build_ui(build: Buildable) -> Control:
	var ele = build_item_scene.instantiate() as StructPanelItem
	ele.update_item(build)
	return ele;

## Create our build item elements
func _create_build_ui_old(build: Buildable) -> Control:
	var base_tier = build.base_tier()
	var parent = PanelContainer.new()
	var hbox = HBoxContainer.new()
	var icon = TextureRect.new()
	var lbl = Label.new()
	
	hbox.add_child(icon)
	hbox.add_child(lbl)
	parent.add_child(hbox)
	
	icon.texture = base_tier.icon
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.custom_minimum_size = Vector2(48, 48)
	
	lbl.text = base_tier.disp_name
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.size_flags_vertical = Control.SIZE_FILL
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.custom_minimum_size = Vector2(200, 48)
	lbl.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
	return parent

## Container for build data and an ui element
class BuildItem:
	var build: Buildable
	var element: Control
