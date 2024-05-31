extends Control
class_name Rescale

@export var screen_ratio : float = 3.25
@export var recenter : bool = true
@export var all_children : bool = false
#@export var recursive : bool = false

func _ready():
	get_window().size_changed.connect(self._rescale)
	_rescale()


func _rescale():
	var old_size : Vector2 = size
	size = get_window().size / screen_ratio
	var percent_change : float = size.length() / old_size.length()
	if recenter:
		position = Vector2(get_window().size) / screen_ratio - size / 2
	if all_children:
		for child in get_children():
			if child is Control:
				child.size *= percent_change
				#if recursive:
