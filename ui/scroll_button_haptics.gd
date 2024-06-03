extends Container
class_name HapticButton
#### This script is going to be the primary button script for any button \
#### resting within a Scroll Container. Goes along with the \
#### Scroll Contain Haptics i still don't think haptics is the right word...

signal forward_gui_input(event, clicked)
signal pressed(id)

## Button Properties
@export_node_path("TextureRect") var icon_path : NodePath
@export_node_path("Label") var label_path : NodePath
@export var manual_assign : bool = false
@export var manual_icon : Texture2D
@export var manual_text : String = ""

## Haptics
var scroll_haptics : ScrollHaptics = null
var initial_pos : Vector2 = Vector2.ZERO
var screen_pressed : bool = false
var hold_frames : int = 0
@export var drag_threshold : float = 150
var dragging : bool = false


func _ready():
	if _find_scroll_haptics():
		connect("forward_gui_input", scroll_haptics.dragging)
		#self.forward_gui_input.connect(scroll_haptics._on_gui_input)
	self.gui_input.connect(_on_gui_input)
	if manual_assign:
		set_properties(manual_text, manual_icon)


func _find_scroll_haptics() -> bool:
	if get_parent() != null:
		if get_parent() is ScrollHaptics:
			print("Haptics Found")
			scroll_haptics = get_parent()
		elif get_parent() is VBoxContainer \
		or get_parent() is HBoxContainer:
			if get_parent().get_parent() is ScrollHaptics:
				print("Haptics Found, layer + 1")
				scroll_haptics = get_parent().get_parent()
	return scroll_haptics != null


func set_properties(text : String, icon : Texture2D):
	get_node(icon_path).texture = icon
	get_node(label_path).text = text


func _on_gui_input(event : InputEvent):
	if event is InputEventMouseButton:
		if !screen_pressed and event.pressed:
			initial_pos = event.position
			screen_pressed = true
			hold_frames = Time.get_ticks_msec()
		if !event.pressed:
			if Time.get_ticks_msec() - hold_frames < 200 and !dragging:
				print("Click!\nSend out a Pressed Signal")
				var id = manual_text
				if !manual_assign:
					id = get_node(label_path).text
				emit_signal("pressed", id)
			dragging = false
			initial_pos = Vector2.ZERO
			screen_pressed = false
			hold_frames = 0
	if event is InputEventMouseMotion and screen_pressed:
		if initial_pos.distance_squared_to(event.position) > drag_threshold:
			dragging = true
		if dragging:
			emit_signal("forward_gui_input", event, dragging)
