extends RigidBody3D

var translating_object : bool = false
var floor_plane : bool = false
var camera_dir : Vector3 = Vector3.ZERO
var object_start_position : Vector3 = Vector3.ZERO
var translation_start_point : Vector2 = Vector2.ZERO
var translation_relative : Vector2 = Vector2.ZERO


func begin_translating(pressed : bool, floor : bool, mouse_pos : Vector2, cam_dir : Vector3):
	translating_object = pressed
	floor_plane = floor
	camera_dir = cam_dir
	translation_start_point = mouse_pos
	object_start_position = self.position


func _physics_process(delta):
	if translating_object:
		translate_object()


func translate_object():
	var mouse_input_dir : Vector3 = Vector3(
		translation_relative.x,
		translation_relative.y,
		translation_relative.x
	)
	if floor_plane:
		mouse_input_dir.z = translation_relative.y
	translate(mouse_input_dir * camera_dir)


func _input(event):
	if event is InputEventMouseMotion and translating_object:
		translation_relative = event.relative
		print(event.relative)
	if event is InputEventMouseButton and translating_object:
		translating_object = event.pressed


func _input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		print("Clicked! Button = ", event.button_index, " | ", event.pressed)
		var mouse_pos : Vector2 = event.global_position
		begin_translating(event.pressed, 
			event.button_index == 1,
			mouse_pos, 
			Vector3.UP * camera.basis)
