extends Node3D
class_name Room

## Toy Management
var toy_objects : Array = []

## Camera Stuff
@onready var cam_dolly : Node3D = $camera_doll
@onready var cam_path : Path3D = $camera_doll/cam_path
@onready var cam_track : PathFollow3D = $camera_doll/cam_path/cam_follow
var floor_clicked : bool = false
var click_index : int = 0


func add_toys(objects : Array, toyname : String, spawn_point : Vector3):
	var new_toy : Node3D = Node3D.new()
	new_toy.name = toyname
	for piece in objects:
		new_toy.add_child(piece)
		piece.position += spawn_point
	add_child(new_toy)
	toy_objects.append(new_toy)

#### Camera Stuff

func _on_static_body_3d_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton \
	and event.pressed:
		click_index = event.button_index
		floor_clicked = true
	if event is InputEventScreenTouch \
	and event.pressed\
	and event.index > 0:
		click_index = clamp(event.index + 1, 0, 2)
		floor_clicked = true


func _input(event):
	if event is InputEventMouseButton \
	and event.button_index == click_index \
	and !event.pressed \
	and floor_clicked:
		click_index = 0
		floor_clicked = false
	if event is InputEventScreenTouch \
	and !event.pressed \
	and floor_clicked:
		click_index = clamp(click_index - 1, 0, 2)
		floor_clicked = false
	if event is InputEventMouseMotion and floor_clicked:
		if click_index == 1:
			var orientated_dir = Vector3(event.relative.x, 0, event.relative.y) * -1.0
			cam_dolly.translate(orientated_dir * 0.01)
		elif click_index == 2:
			cam_dolly.rotate(Vector3.UP, event.relative.x * 0.01)
			cam_track.progress_ratio = clamp(
				cam_track.progress_ratio + event.relative.y * -0.001,
				0.0,
				1.0)
