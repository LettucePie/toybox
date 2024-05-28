extends PanelContainer
#### This script is going to be the primary button script for any button \
#### resting within a Scroll Container. Goes along with the \
#### Scroll Contain Haptics i still don't think haptics is the right word...

signal forward_gui_input(event, clicked)


var scroll_haptics : ScrollHaptics = null
var initial_pos : Vector2 = Vector2.ZERO
var screen_pressed : bool = false
@export var drag_threshold : float = 150
var dragging : bool = false


func _ready():
	if _find_scroll_haptics():
		connect("forward_gui_input", scroll_haptics.dragging)
		#self.forward_gui_input.connect(scroll_haptics._on_gui_input)
	self.gui_input.connect(_on_gui_input)


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


func _on_gui_input(event : InputEvent):
	if event is InputEventMouseButton:
		if !screen_pressed and event.pressed:
			initial_pos = event.position
			screen_pressed = true
		if !event.pressed:
			dragging = false
			initial_pos = Vector2.ZERO
			screen_pressed = false
	if event is InputEventMouseMotion and screen_pressed:
		if initial_pos.distance_squared_to(event.position) > drag_threshold:
			dragging = true
		if dragging:
			emit_signal("forward_gui_input", event, dragging)
