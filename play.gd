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
	var menu_instance : Control
	var objects : Array

var loaded_toys : Array[ToyInstance] = []
var selected_toy_instance : int = -1

func load_toy(toy_name : String):
	var new_instance : ToyInstance = ToyInstance.new()
	new_instance.meta = toybox.get_toymeta(toy_name)
	new_instance.random_id = new_instance.meta.name + str(randi_range(1000, 9999))
	print("instantiate, associate, then send the menu to playui")
	new_instance.menu_instance = new_instance.meta.menu.instantiate()
	ui.add_toy_menu(new_instance.menu_instance)
	print("instantiate, associate, then send objects to room")
	new_instance.objects.clear()
	for scene in new_instance.meta.objects:
		new_instance.objects.append(scene.instantiate())
	room.add_toys(new_instance.objects, new_instance.random_id)
	if new_instance.meta.pass_objects \
	and new_instance.menu_instance.has_method(new_instance.meta.menu_receiver_function):
			new_instance.menu_instance.call(
				new_instance.meta.menu_receiver_function,
				new_instance.objects)


## This function is meant to be reached from the Play UI.
## When player toggles through the different toymenus in the bottom \
## drawer, we want the game to highlight and "fit in screen" all the pieces \
## of the toy.
func toy_menu_focused(toy_menu : Control):
	print("Find toy instance and highlight pieces")
