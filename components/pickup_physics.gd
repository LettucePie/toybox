extends RigidBody3D
class_name PickupPhysics

signal object_grabbed(object)
signal object_released(object)

## Input -> Process variables
var grabbing : bool = false
var grab_time : int = 0
var grabbed : bool = false
var screen_relative : Vector2 = Vector2.ZERO


func _ready():
	_connect_signals()


func _connect_signals():
	if !input_event.is_connected(self._on_input_event):
		input_event.connect(self._on_input_event)


## Handles Direct input against the physics object.
## Use only for object targeting
## Fires for all inputs that connect to physics object.
func _on_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			if !grabbing and !grabbed:
				print(self, " Grabbing...")
				grabbing = true
				grab_time = Time.get_ticks_msec()


## Handles all Input regardless of positioning in relation to physics object.
## Use for handling states and gathering directional inputs.
## Fires for all inputs
func _input(event):
	if event is InputEventMouseButton \
	and event.button_index == 1 \
	and !event.pressed:
		if grabbing:
			grabbing = false
		if grabbed:
			grabbed = false
			emit_signal("object_released", self)
	if event is InputEventMouseMotion and grabbed:
		screen_relative = event.relative


func _physics_process(delta):
	if (grabbing and !grabbed) and Time.get_ticks_msec() - grab_time > 100:
		print(self, " Grabbed!")
		grabbed = true
		emit_signal("object_grabbed", self)
	if grabbed:
		## Check if Mouse Velocity is actually moving
		if Input.get_last_mouse_velocity().length_squared() > 2:
			## Calculate World Relative by rotating against camera.y
			var world_relative : Vector3 = Vector3(
				screen_relative.x,
				0,
				screen_relative.y
			).rotated(
				Vector3.UP, 
				get_viewport().get_camera_3d().global_rotation.y)
			## Wow trying to keep lines within the brace is getting kinda crazy
			
			## TODO replace with proper add_force calls and stuff
			position += world_relative * delta
