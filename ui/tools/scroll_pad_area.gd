extends Control
class_name ScrollPadArea

@export var scroll_container : ScrollHaptics = null

func _ready():
	if scroll_container == null:
		print("Scroll Pad Area searching for Scroll Container Haptics")
		scroll_container = _find_scroll_container()
	if scroll_container != null:
		self.connect("gui_input", scroll_container._on_gui_input)
	mouse_filter = Control.MOUSE_FILTER_PASS


func _find_scroll_container() -> ScrollHaptics:
	var target : ScrollHaptics = null
	for child in get_children():
		if child is ScrollHaptics:
			target = child
	if target == null:
		for child in get_parent().get_children():
			if child is ScrollHaptics:
				target = child
	if target == null:
		print("Failed to find Sibling or Child Scroll Container Haptics!")
	return target


func _process(delta):
	pass
