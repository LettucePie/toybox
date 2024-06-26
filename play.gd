extends Node
class_name Play
#### This is the Central host of the UI and the actual Playable Objects aka Toys.
#### The objective is to use this as a bridge way between necessary objects \
#### and interactions between toys and the display.
#### Also this manages the instantiation and removal of Toy Objects

@onready var toybox : Toybox = $toybox
@onready var ui : PlayUI = $play_ui
@onready var room : Room = $room_a

class ToyInstance:
	var meta : ToyMeta
	var random_id : String
	var menu_instance : ToyUI
	var objects : Array

var loaded_toys : Array[ToyInstance] = []
var selected_toy_instance : int = -1

func load_toy(toy_name : String):
	## Create ToyInstance Classobject
	var new_instance : ToyInstance = ToyInstance.new()
	## Retrieve metadata from toybox
	new_instance.meta = toybox.get_toymeta(toy_name)
	## Build random id
	new_instance.random_id = new_instance.meta.name \
	+ "_" \
	+ str(randi_range(1000, 9999))
	## Instantiate and associate toy menu then send to playui
	new_instance.menu_instance = new_instance.meta.menu.instantiate()
	new_instance.menu_instance.set_play_node(self)
	ui.add_toy_menu(new_instance.menu_instance)
	## Instantiate and associate toy objects / pieces then send to room
	new_instance.objects.clear()
	var target_position : Vector3 = new_instance.meta.spawn_at_position
	if new_instance.meta.spawn_at_camera:
		target_position = room.cam_dolly.position
	for scene in new_instance.meta.objects:
		new_instance.objects.append(scene.instantiate())
	room.add_toys(new_instance.objects, new_instance.random_id, target_position)
	loaded_toys.append(new_instance)
	## connect grab signals to playui, if applicable
	if new_instance.meta.objects_have_pickup_physics:
		for toy_object in new_instance.objects:
			if toy_object is PickupPhysics:
				toy_object.object_grabbed.connect(ui.physics_toy_grabbed)
				toy_object.object_released.connect(ui.physics_toy_released)
	## pass array of objects to ToyUI
	new_instance.menu_instance.set_toy_objects(new_instance.objects)


## Instantiates the toy object and connects it to the room and toy menu.
## Returns the newly instanced variable for shortcut purposes.
## Returns null if it failed to add the toy object, so debug help i guess.
func add_toy_object(toy_object : PackedScene, from : ToyUI) -> Node:
	var result = null
	print("Adding Toy: ", toy_object, " from: ", from)
	var instance : ToyInstance = find_instance_by_menu(from)
	if instance != null:
		var new_toy_object = toy_object.instantiate()
		var target_position : Vector3 = instance.meta.spawn_at_position
		if instance.meta.spawn_at_camera:
			target_position = room.cam_dolly.global_position
		instance.objects.append(new_toy_object)
		room.add_toy_object(new_toy_object, 
		instance.random_id, 
		target_position,
		instance.meta.raycast_spawn_point)
		instance.menu_instance.add_toy_object(new_toy_object)
		if new_toy_object is PickupPhysics:
			new_toy_object.object_grabbed.connect(ui.physics_toy_grabbed)
			new_toy_object.object_released.connect(ui.physics_toy_released)
		result = new_toy_object
	else:
		print("ERROR: Cannot add ToyObject to null ToyInstance")
	return result


## This function is meant to be reached from the Play UI.
## When player toggles through the different toymenus in the bottom \
## drawer, we want the game to highlight and "fit in screen" all the pieces \
## of the toy.
func toy_menu_focused(toy_menu : ToyUI):
	print("Find toy instance and highlight pieces")


func find_instance_by_menu(menu : ToyUI) -> ToyInstance:
	var result = loaded_toys.front()
	for instance in loaded_toys:
		if instance.menu_instance == menu:
			result = instance
	return result
