extends Node
class_name Play
#### This is the Central host of the UI and the actual Playable Objects aka Toys.
#### The objective is to use this as a bridge way between necessary objects \
#### and interactions between toys and the display.
#### Also this manages the instantiation and removal of Toy Objects

@onready var toybox : Toybox = $toybox
@onready var ui : PlayUI = $play_ui
@onready var room : Node3D = $room_a

class ToyInstance:
	var meta : ToyMeta
	var menu_instance : Control
	var objects : Array

var loaded_toys : Array[ToyInstance] = []
var selected_toy_instance : int = -1

func load_toy(toy_name : String):
	var new_instance : ToyInstance = ToyInstance.new()
	new_instance.meta = toybox.get_toymeta(toy_name)
	print("instantiate, associate, then add the menu to playui")
	print("instantiate, associate, then add objects to room")
