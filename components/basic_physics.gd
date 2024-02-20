extends RigidBody3D

var translating_object : bool = false
var translation_up : Vector3 = Vector3.UP
var object_start_position : Vector3 = Vector3.ZERO
var translation_start_point : Vector2 = Vector2.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	if !self.input_event.is_connected(_on_input_event):
		print("Automatically connecting input_event to script.")
		self.input_event.connect(_on_input_event)


func begin_translating(pressed : bool, mouse_pos : Vector2, up : Vector3):
	print("Translating off of ", up, " plane")
	translating_object = pressed
	translation_start_point = mouse_pos
	object_start_position = self.position


func _physics_process(delta):
	if translating_object:
		translate_object()


func translate_object():
	pass
#	Input.
	# Encountering issue.
	# I need to use on_input_event to BEGIN acknowledging input capture.
	# then use _input(event) to dictate input to apply...
	# But i also need to apply this in the physics_process...
#	print("Translating object from start position: ", object_start_position)


func _on_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		print("Clicked! Button = ", event.button_index, " | ", event.pressed)
		var mouse_pos : Vector2 = event.global_position
		if event.button_index == 1:
			begin_translating(event.pressed, 
				mouse_pos, 
				Vector3.UP)
		elif event.button_index == 2:
			begin_translating(event.pressed, 
				mouse_pos, 
				Vector3.FORWARD * camera.basis)
