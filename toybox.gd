extends Node
class_name Toybox
#### This functions as the Save Data, and core Resource center.
#### Toys should be loaded from here and instantiated into the 3D Rooms.

## The grand list of all Toy Metadatas
@export var toy_metadatas : Array[ToyMeta] = []

## The save data of unlocked toys
var unlocked_toys : PackedStringArray = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
