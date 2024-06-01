extends Node3D
class_name Room

## Toy Management
var toy_objects : Array = []

## Camera Stuff
@onready var cam_dolly : Node3D = $camera_doll
var floor_clicked : bool = false
var click_index : int = 0


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
	and event.pressed:
		click_index = event.button_index
		floor_clicked = true
	if event is InputEventScreenTouch:
		click_index = clamp(event.index + 1, 1, 2)
		floor_clicked = true


func _input(event):
	if event is InputEventMouseButton \
	and event.button_index == click_index \
	and !event.pressed \
	and floor_clicked:
		click_index = 0
		floor_clicked = false
	if event is InputEventScreenTouch \
	and event.index == click_index \
	and !event.pressed \
	and floor_clicked:
		click_index = 0
		floor_clicked = false
	if event is InputEventMouseMotion and floor_clicked:
		if click_index == 1:
			print("Pan")
			var orientated_dir = Vector3(event.relative.x, 0, event.relative.y)
			print("before rotated: ", orientated_dir)
			var angle = (cam_dolly.global_basis * Vector3.RIGHT).angle_to(Vector3.FORWARD)
			orientated_dir = orientated_dir.rotated(Vector3.UP, angle)
			print("after rotate: ", orientated_dir)
			cam_dolly.translate(orientated_dir * 0.01)
		elif click_index == 2:
			print("Rotate")
			cam_dolly.rotate(Vector3.UP, event.relative.x * 0.01)
