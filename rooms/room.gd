extends Node3D
class_name Room

## Settings
@export var room_dimensions : Vector3 = Vector3(50, 50, 50)

## Toy Management
var toy_objects : Array = []

## Camera Stuff
@onready var cam_dolly : Node3D = $camera_doll
@onready var cam_path : Path3D = $camera_doll/cam_path
@onready var cam_track : PathFollow3D = $camera_doll/cam_path/cam_follow
var floor_clicked : bool = false
var click_index : int = 0


####
#### Utility
####

func find_raycast_point(from : Vector3) -> Vector3:
	var result : Vector3 = Vector3.ZERO
	$spawn_ray.position = from
	$spawn_ray.position.y = 50
	$spawn_ray.force_raycast_update()
	if $spawn_ray.is_colliding():
		result = $spawn_ray.get_collision_point()
	else:
		result = from
	return result


####
#### Toy Object Instantiation and Stuff
####

func add_toys(objects : Array, toyname : String, spawn_point : Vector3):
	var new_toy : Node3D = Node3D.new()
	new_toy.name = toyname
	for piece in objects:
		new_toy.add_child(piece)
		piece.position += spawn_point
	add_child(new_toy)
	toy_objects.append(new_toy)


func add_toy_object(
	object : Node3D, 
	root_name : String, 
	spawn_point : Vector3, 
	raycast_point : bool):
	##
	var root_node : Node3D = get_toy(root_name)
	if self.has_node(root_node.get_path()) \
	or toy_objects.has(root_node):
		root_node.add_child(object)
		var target_position : Vector3 = spawn_point
		if raycast_point:
			target_position = find_raycast_point(spawn_point)
		object.position = Vector3(
			target_position.x, 
			object.position.y + target_position.y, 
			target_position.z)
	else:
		print("ERROR: Room cannot add toy object onto null Root Node")


func get_toy(root_name : String) -> Node3D:
	var result = null
	for toy_root in toy_objects:
		if toy_root.name == root_name:
			result = toy_root
	return result


func remove_toy(toy_id : String):
	var target = get_toy(toy_id)
	if target != null:
		toy_objects.erase(target)
		target.queue_free()


####
#### Camera Stuff
####

func set_camera_position(target : Vector3):
	cam_dolly.position = target


func set_camera_zoom(percent : float):
	cam_track.progress_ratio = percent


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
