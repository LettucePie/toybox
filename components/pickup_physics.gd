extends RigidBody3D
class_name PickupPhysics

signal object_grabbed(object, hold)
signal object_released(object)

## Usersetting variables
## Quick Drag is the function to pickup and immediately move something.
## It will also use the PickupRay component if one is attached.
var quick_drag : bool = true
## How far you have to drag within the grab_fast timeframe to activate \
## Quick Drag.
var quick_drag_sensitivity : int = 112

## Input -> Process variables
var grabbing : bool = false
var grab_time : int = 0
var grab_mouse_pos : Vector2 = Vector2.ZERO
var grabbed_fast : bool = false
var grabbed_long : bool = false
var screen_relative : Vector2 = Vector2.ZERO
var mouse_world : Vector3 = Vector3.ZERO
## Control Input -> Process variables
var menu_mode : bool = false
var translate_only : bool = false
var vertical_only : bool = false
var rotate_only : bool = false


func _ready():
	_connect_signals()


func _connect_signals():
	if !input_event.is_connected(self._on_input_event):
		input_event.connect(self._on_input_event)


func grab_object(tf : bool):
	print("Grab Object: ", tf)
	if tf:
		grabbed_fast = true
		emit_signal("object_grabbed", self, false)
	else:
		grabbing = false
		grabbed_fast = false
		grabbed_long = false
		menu_mode = false
		set_control_mode("clear")
		emit_signal("object_released", self)


func hold_object(tf : bool):
	print("Hold Object: ", tf)
	if tf:
		grabbed_long = true
		menu_mode = true
		grabbed_fast = false
		emit_signal("object_grabbed", self, true)
	else:
		grabbing = false
		grabbed_long = false
		menu_mode = false
		set_control_mode("clear")
		grabbed_fast = false
		emit_signal("object_released", self)


func set_control_mode(mode : String):
	if mode == "translate":
		translate_only = true
		vertical_only = false
		rotate_only = false
	elif mode == "vertical":
		translate_only = false
		vertical_only = true
		rotate_only = false
	elif mode == "rotate":
		translate_only = false
		vertical_only = false
		rotate_only = true
	elif mode == "clear" or mode == "":
		translate_only = false
		vertical_only = false
		rotate_only = false


## Handles Direct input against the physics object.
## Use only for object targeting
## Fires for all inputs that connect to physics object.
func _on_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			if !grabbing and (!grabbed_long or !grabbed_fast):
				grabbing = true
				grab_time = Time.get_ticks_msec()
				grab_mouse_pos = get_viewport().get_mouse_position()


## Handles all Input regardless of positioning in relation to physics object.
## Use for handling states and gathering directional inputs.
## Fires for all inputs
func _input(event):
	if event is InputEventMouseButton \
	and event.button_index == 1 \
	and !event.pressed:
		if grabbing:
			grabbing = false
		if grabbed_fast:
			grab_object(false)
		if grabbed_long:
			## Call Hold_object(false) when done with menu.
			## until then only emit the release signal.
			emit_signal("object_released", self)
			translate_only = false
			vertical_only = false
			rotate_only = false


func _update_mouse_world():
	var mouse_pos := get_viewport().get_mouse_position()
	var cam := get_viewport().get_camera_3d()
	var origin := cam.project_ray_origin(mouse_pos)
	var end := origin + cam.project_ray_normal(mouse_pos) * cam.far
	var query := PhysicsRayQueryParameters3D.create(origin, end, 16)
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	if !result.is_empty():
		mouse_world = result["position"]


## integrate forces overrides default physics thread behaviours.
## We don't want to touch this too much, currently I'm only negating \
## gravitational buildup to prevent slamming
func _integrate_forces(state):
	if grabbed_fast or grabbed_long:
		var linear_vel : Vector3 = state.get_linear_velocity()
		linear_vel = linear_vel.lerp(Vector3.ZERO, 0.5)
		state.set_linear_velocity(Vector3(linear_vel.x, 0.0, linear_vel.z))


func _translate_movement(delta):
	## Check if Mouse Velocity is actually moving
	if Input.get_last_mouse_velocity().length_squared() > 2:
		_update_mouse_world()
		var flattened_target : Vector3 = Vector3(
			mouse_world.x,
			position.y,
			mouse_world.z
		)
		position = position.lerp(flattened_target, 5 * delta)


func _physics_process(delta):
	if grabbing and (!grabbed_fast and !grabbed_long):
		var hold_time : int = Time.get_ticks_msec() - grab_time
		var drag_distance : float = get_viewport().get_mouse_position()\
		.distance_squared_to(grab_mouse_pos)
		if drag_distance >= quick_drag_sensitivity and hold_time > 60:
			grab_object(true)
		elif drag_distance < quick_drag_sensitivity and hold_time > 120:
			hold_object(true)
	if grabbed_fast:
		_translate_movement(delta)
	elif grabbed_long:
		## Suspend location, only affecting if translate, vertical, or rotate
		if translate_only:
			_translate_movement(delta)
