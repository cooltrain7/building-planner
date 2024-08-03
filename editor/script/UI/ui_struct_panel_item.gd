extends PanelContainer
class_name StructPanelItem

@export var struct_icon: TextureRect
@export var struct_name: Label

var _build: Buildable

## Cache our item style
var _style: StyleBoxFlat
## Element selected
var _selected: bool

var col_default: Color = Color(0.1, 0.1, 0.1, 0.6)
var col_hover: Color = Color(0.2, 0.2, 0.2, 0.8)
var col_click: Color = Color(0.2, 0.2, 0.2, 1.0)

func _ready() -> void:
	assert(struct_icon != null, "Icon element unset")
	assert(struct_name != null, "Name element unset")
	
	# Set a unique style per button so we can change the bg on hover
	var style = StyleBoxFlat.new()
	style.bg_color = col_default
	self.add_theme_stylebox_override("panel",style)
	_style = style
	
## Updates our panel item with data from a buildable
func update_item(build: Buildable) -> void:
	if build == null:
		return
	var base_tier = build.base_tier()
	struct_name.text = base_tier.disp_name
	if base_tier.icon != null:
		struct_icon.texture = base_tier.icon
	_build = build

## Select this item and trigger a build change event
func select() -> void:
	if _selected:
		deselect()
		EventBus.emit_signal("on_build_change", null, self)
	else:
		_style.bg_color = col_click
		_selected = true
		EventBus.emit_signal("on_build_change", _build, self)

## Deselect this item 
func deselect() -> void:
	_style.bg_color = col_default
	_selected = false

## Handle our element click
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouse && event.is_pressed():
		select()

func _on_mouse_entered() -> void:
	if _build == null || _selected:
		return
	_style.bg_color = col_hover

func _on_mouse_exited() -> void:
	if _build == null || _selected:
		return
	_style.bg_color = col_default
