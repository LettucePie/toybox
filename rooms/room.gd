extends Node3D
class_name Room

var toy_objects : Array = []

func add_toys(objects : Array, toyname : String):
	var new_toy : Node3D = Node3D.new()
	new_toy.name = toyname
	for piece in objects:
		new_toy.add_child(piece)
	add_child(new_toy)
	toy_objects.append(new_toy)

