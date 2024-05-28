extends ScrollContainer
class_name ScrollHaptics

var clicked : bool = false

func _ready():
	if !is_connected("gui_input", _on_gui_input):
		self.connect("gui_input", _on_gui_input)


func _on_gui_input(event : InputEvent):
	if event is InputEventMouseButton:
		clicked = event.pressed
	if clicked and event is InputEventMouseMotion:
		scroll_horizontal -= event.relative.x * 1.5
		scroll_vertical -= event.relative.y * 1.5


func dragging(event : InputEvent, clicked : bool):
	if clicked and event is InputEventMouseMotion:
		scroll_horizontal -= event.relative.x * 1.5
		scroll_vertical -= event.relative.y * 1.5
