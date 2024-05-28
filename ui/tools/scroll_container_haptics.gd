extends ScrollContainer
class_name ScrollHaptics

var clicked : bool = false
@export_range(0.2, 2.0, 0.1) var drag_speed : float = 1.0


func _ready():
	if !is_connected("gui_input", _on_gui_input):
		self.connect("gui_input", _on_gui_input)


func _on_gui_input(event : InputEvent):
	if event is InputEventMouseButton:
		clicked = event.pressed
	if clicked and event is InputEventMouseMotion:
		scroll_horizontal -= event.relative.x * drag_speed
		scroll_vertical -= event.relative.y * drag_speed


func dragging(event : InputEvent, drag : bool):
	if !clicked and drag and event is InputEventMouseMotion:
		scroll_horizontal -= event.relative.x * drag_speed
		scroll_vertical -= event.relative.y * drag_speed
