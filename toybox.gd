extends Node
class_name Toybox
#### This functions as the Save Data, and core Resource center.
#### Toys should be loaded from here and instantiated into the 3D Rooms.

## The grand list of all Toy Metadatas
@export var toy_metadatas : Array[ToyMeta] = []

## The save data of unlocked toys
## why?
var unlocked_toys : PackedStringArray = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


## Filters and Getters
func get_toymeta(toy_name : String) -> ToyMeta:
	var result : ToyMeta = toy_metadatas[0]
	var success : bool = false
	for toy_meta in toy_metadatas:
		if toy_meta.name == toy_name:
			result = toy_meta
			success = true
	if !success:
		print("ERROR: Failed to Find ToyMeta with name: ", toy_name)
	return result


func get_toy_scenes(toy_name : String) -> Array:
	var result : Array = [null]
	result = get_toymeta(toy_name).objects
	return result


func get_toy_ui(toy_name : String) -> PackedScene:
	var result : PackedScene = toy_metadatas[0].menu
	result = get_toymeta(toy_name).menu
	return result


func get_toy_listing() -> Array:
	var result : Array
	for toy_meta in toy_metadatas:
		result.append([toy_meta.name, toy_meta.icon])
	return result
