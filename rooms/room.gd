extends Node3D
class_name Room

## Toy Management
var toy_objects : Array = []

## Camera Stuff
@onready var cam_dolly : Node3D = $camera_doll
var floor_clicked : bool = false


func add_toys(objects : Array, toyname : String):
	var new_toy : Node3D = Node3D.new()
	new_toy.name = toyname
	for piece in objects:
		new_toy.add_child(piece)
	add_child(new_toy)
	toy_objects.append(new_toy)

#### Camera Stuff

func _on_static_body_3d_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton \
	and event.button_index == 1 \
	and event.pressed:
		floor_clicked = true


func _input(event):
	if event is InputEventMouseButton \
	and event.button_index == 1 \
	and !event.pressed \
	and floor_clicked:
		floor_clicked = false
	if event is InputEventMouseMotion and floor_clicked:
		cam_dolly.rotate(Vector3.UP, event.relative.x * 0.01)
