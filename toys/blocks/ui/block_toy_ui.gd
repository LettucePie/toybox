extends Control

var blocks_parent : Node3D = null
var blocks : Array = []
var current_block : Node3D = null

## Receiver Function
## Should be called from Play during Toy Instantiation
func receive_blocks(new_blocks : Array):
	print("BlockToy UI Receiving Blocks: ", new_blocks)
	blocks = new_blocks
	blocks_parent = blocks[0].get_parent()
	_indoctrinate_blocks()


## Connects the blocks selected state to this ui, so that options can be loaded
func _indoctrinate_blocks():
	for block in blocks:
		if block.has_signal("object_grabbed"):
			if !block.object_grabbed.is_connected(self.block_selected):
				block.object_grabbed.connect(self.block_selected)


func block_selected(block : Node3D):
	print("BlockToyUI Received Block selection: ", block)
	current_block = block
