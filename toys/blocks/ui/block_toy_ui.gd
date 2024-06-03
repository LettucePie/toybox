extends ToyUI

var current_block : Node3D = null

## Refers to signals and variables in the ToyUI Extension.
func _ready():
	objects_set.connect(_indoctrinate_blocks)
	objects_changed.connect(_indoctrinate_blocks)

## Connects the blocks selected state to this ui, so that options can be loaded
func _indoctrinate_blocks(blocks : Array):
	print("Indoctrinate Blocks called: ", blocks)
	for block in blocks:
		if block.has_signal("object_grabbed"):
			if !block.object_grabbed.is_connected(self.block_selected):
				block.object_grabbed.connect(self.block_selected)


func block_selected(block : Node3D, held : bool):
	print("BlockToyUI Received Block selection: ", block)
	current_block = block
