extends ScrollContainer
class_name ScrollHaptics

var clicked : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if !is_connected("gui_input", _on_gui_input):
		self.connect("gui_input", _on_gui_input)


func _on_gui_input(event : InputEvent):
	if event is InputEventMouseButton:
		clicked = event.pressed
	if clicked and event is InputEventMouseMotion:
		scroll_horizontal -= event.relative.x * 1.5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
