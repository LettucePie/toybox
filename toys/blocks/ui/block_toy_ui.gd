extends ToyUI

## UI Setup
@export var block_scenes : Array[PackedScene]
@export var block_names : PackedStringArray
@export var block_button_container : Container

## Dynamic Settings
@export var block_material : BaseMaterial3D
@export var block_color_pallete : Array[Color]
var random_colors : bool = false

## Block Selection
var current_block : PickupPhysics = null
@onready var current_block_section : Container = $scroll_pad_area/options_v/VBoxContainer/current_block_container
@onready var current_block_pos_labels : Dictionary = {
	"x" : $scroll_pad_area/options_v/VBoxContainer/current_block_container/position_container/pos_x_input,
	"y" : $scroll_pad_area/options_v/VBoxContainer/current_block_container/position_container/pos_y_input,
	"z" : $scroll_pad_area/options_v/VBoxContainer/current_block_container/position_container/pos_z_input
}
@onready var position_modifier_add_container : Container = $scroll_pad_area/options_v/VBoxContainer/current_block_container/position_add
@onready var position_modifier_sub_container : Container = $scroll_pad_area/options_v/VBoxContainer/current_block_container/position_sub
@onready var current_block_scale_slider : Slider = $scroll_pad_area/options_v/VBoxContainer/current_block_container/scale_container/scale_slider
@onready var current_block_scale_label : Label = $scroll_pad_area/options_v/VBoxContainer/current_block_container/scale_container/scale_label


## Refers to signals and variables in the ToyUI Extension.
func _ready():
	objects_set.connect(_indoctrinate_blocks)
	objects_changed.connect(_indoctrinate_blocks)
	if block_button_container != null:
		_connect_buttons()
	if current_block_section != null:
		current_block_section.hide()
	get_viewport().size_changed.connect(rescale)
	rescale()


func _connect_buttons():
	for child in block_button_container.get_children():
		if child is HapticButton:
			child.pressed.connect(self.spawn_block_button)
	var axes := ["x", "y", "z"]
	for axis in axes:
		current_block_pos_labels[axis].text_submitted.connect(set_block_pos.bind(axis))
	for button in position_modifier_add_container.get_children():
		button.pressed.connect(adjust_block_pos.bind(
			axes[button.get_index(false)],
			true))
	for button in position_modifier_sub_container.get_children():
		button.pressed.connect(adjust_block_pos.bind(
			axes[button.get_index(false)],
			false))
	current_block_scale_slider.value_changed.connect(set_block_scale)


## Connects the blocks selected state to this ui, so that options can be loaded
func _indoctrinate_blocks(blocks : Array):
	print("Indoctrinate Blocks called: ", blocks)
	for block in blocks:
		if block.has_signal("object_grabbed"):
			if !block.object_grabbed.is_connected(self.block_selected):
				block.object_grabbed.connect(self.block_selected)
			if !block.object_released.is_connected(self.block_deselected):
				block.object_released.connect(self.block_deselected)


## Manages Controls that need to be rescaled manually.
func rescale():
	if get_viewport().size.length() > 1800:
		$scroll_pad_area/options_v/VBoxContainer/random_colors.theme_type_variation = "CheckButton_2x"
	else:
		$scroll_pad_area/options_v/VBoxContainer/random_colors.theme_type_variation = ""


func block_selected(block : PickupPhysics, held : bool):
	print("BlockToyUI Received Block selection: ", block)
	current_block = block
	if held:
		current_block_section.show()
		for label in current_block_pos_labels:
			print(label)
			if label is LineEdit:
				label.clear()
		display_block_stats()


func block_deselected(block : PickupPhysics):
	print("BlockToyUI Received Block release: ", block)
	if block == current_block \
	and !block.menu_mode:
		current_block = null
		current_block_section.hide()
	elif block == current_block \
	and block.menu_mode:
		display_block_stats()


func spawn_block_button(id : String):
	print("Block_Toy_UI spawning block: ", id)
	if is_play_connected() and block_names.has(id):
		var new_block = play_node.add_toy_object(
			block_scenes[block_names.find(id)], self)
		print(new_block)
		if new_block != null and new_block is PickupPhysics:
			_indoctrinate_blocks([new_block])
			if random_colors:
				print("Recoloring on entry")
				block_color_pallete.shuffle()
				set_block_material(new_block, block_color_pallete[0])


func display_block_stats():
		current_block_pos_labels["x"].text = str(current_block.global_position.x)
		current_block_pos_labels["y"].text = str(current_block.global_position.y)
		current_block_pos_labels["z"].text = str(current_block.global_position.z)
		current_block_scale_label.text = String.num(current_block.scale.x, 3)


func set_block_pos(new_text : String, axis : String):
	print("BlockToyUI setting position axis: ", axis, " to: ", new_text)
	var target : Vector3 = current_block.global_position
	if axis == "x":
		target.x = new_text.to_float()
	if axis == "y":
		target.y = new_text.to_float()
	if axis == "z":
		target.z = new_text.to_float()
	current_block.global_position = target
	var cam_target : Vector3 = Vector3(target.x, 0.0, target.z)
	play_node.room.set_camera_position(cam_target)
	#play_node.room.set_camera_zoom(0.1)


func adjust_block_pos(axis : String, add : bool):
	print("BlockToyUI adjusting block position at axis: ", axis, " adding? ", add)
	var value : float = 0
	if axis == "x":
		value = current_block.global_position.x
	if axis == "y":
		value = current_block.global_position.y
	if axis == "z":
		value = current_block.global_position.z
	if add:
		value += 1.0
	else:
		value -= 1.0
	set_block_pos(str(value), axis)
	display_block_stats()


func set_block_scale(value : float):
	print("BlockToyUI Setting block scale: ", value)
	current_block.set_scale(Vector3(value, value, value))
	display_block_stats()


func set_block_material(block : PickupPhysics, color : Color):
	var new_mat : BaseMaterial3D = block_material.duplicate()
	new_mat.albedo_color = color
	for child in block.get_children():
		if child is MeshInstance3D:
			child.set_surface_override_material(0, new_mat)
		else:
			if child.get_child_count() > 0:
				for sub_child in child.get_children():
					if sub_child is MeshInstance3D:
						sub_child.set_surface_override_material(0, new_mat)


func _on_random_colors_toggled(toggled_on):
	random_colors = toggled_on
	var blocks = null
	if has_toy_objects():
		blocks = get_toy_objects()
	if toggled_on and blocks != null:
		randomize()
		for block in blocks:
			block_color_pallete.shuffle()
			set_block_material(block, block_color_pallete[0])
	elif !toggled_on and blocks != null:
		for block in blocks:
			set_block_material(block, Color.WHITE)

