extends Node3D
class_name PickupRay

## Setup components
@export var physics_object : CollisionObject3D = null
@export var physics_shapes : Array[CollisionShape3D] = []
@export var up_distance : float = 10.0
@export var down_distance : float = -10.0
@export var climb_height : float = 20.0
@export var climb_distance : float = -40.0
@export var climb_reach : float = 4.0

var previous_position : Vector3 = Vector3.ZERO
var relative : Vector3 = Vector3.ZERO
@onready var rays : Array = [$up, $down, $climb]
var up_point : Vector3 = Vector3.ZERO
var down_point : Vector3 = Vector3.ZERO
var climb_point : Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	_check_setup()
	_apply_ray_variables()
	previous_position = physics_object.position


func _check_setup():
	if physics_object == null or physics_shapes.is_empty():
		print("ERROR: Pickup Ray not configured... attempting to fix")
		if get_parent() is CollisionObject3D:
			physics_object = get_parent()
			for child in physics_object.get_children():
				if child is CollisionShape3D:
					physics_shapes.append(child)
		if physics_object == null or physics_shapes.is_empty():
			print("ERROR: Failed to configure PickupRay. killing")
			self.queue_free()
		else:
			print("RECOVERY: Found parent physics object and physics shapes")


func _apply_ray_variables():
	$up.target_position = Vector3(0, up_distance, 0)
	$down.target_position = Vector3(0, down_distance, 0)
	$climb.target_position = Vector3(0, climb_distance, 0)


## Shift the ClimbRay in the direction the object is moving so that it can \
## detect inclines.
func _move_climb_ray():
	var direction : Vector3 = Vector3(relative.x, 0, relative.z).normalized()
	$climb.position = Vector3(
		direction.x * climb_reach, 
		climb_height, 
		direction.z * climb_reach)


func _calculate_hoverpoint():
	if $up.is_colliding():
		pass
		#print("up: ", $up.get_collision_point())
	if $down.is_colliding():
		pass
		#print("down: ", $down.get_collision_point())


func _physics_process(delta):
	relative = physics_object.position - previous_position
	previous_position = physics_object.position
	## Fix the Orientation
	global_rotation = Vector3.ZERO
	_move_climb_ray()
	_calculate_hoverpoint()
