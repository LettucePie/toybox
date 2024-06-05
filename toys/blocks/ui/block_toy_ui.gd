extends ToyUI

@export var block_scenes : Array[PackedScene]
@export var block_names : PackedStringArray = [
	"Cube",
	"Half",
	"Corner"
]
@export var block_button_container : Container

## Block Selection
var current_block : PickupPhysics = null
@onready var current_block_section : Container = $scroll_pad_area/options_v/VBoxContainer/current_block_container

## Refers to signals and variables in the ToyUI Extension.
func _ready():
	objects_set.connect(_indoctrinate_blocks)
	objects_changed.connect(_indoctrinate_blocks)
	if block_button_container != null:
		_connect_buttons()
	if current_block_section != null:
		current_block_section.hide()


func _connect_buttons():
	for child in block_button_container.get_children():
		if child is HapticButton:
			child.pressed.connect(self.spawn_block_button)


## Connects the blocks selected state to this ui, so that options can be loaded
func _indoctrinate_blocks(blocks : Array):
	print("Indoctrinate Blocks called: ", blocks)
	for block in blocks:
		if block.has_signal("object_grabbed"):
			if !block.object_grabbed.is_connected(self.block_selected):
				block.object_grabbed.connect(self.block_selected)
			if !block.object_released.is_connected(self.block_deselected):
				block.object_released.connect(self.block_deselected)


func block_selected(block : PickupPhysics, held : bool):
	print("BlockToyUI Received Block selection: ", block)
	current_block = block
	current_block_section.show()


func block_deselected(block : PickupPhysics):
	print("BlockToyUI Received Block release: ", block)
	if block == current_block \
	and !block.menu_mode:
		current_block = null
		current_block_section.hide()


func spawn_block_button(id : String):
	print("Block_Toy_UI spawning block: ", id)
	if is_play_connected() and block_names.has(id):
		play_node.add_toy_object(block_scenes[block_names.find(id)], self)
