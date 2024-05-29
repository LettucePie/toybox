extends Node3D
class_name PickupRay

## Setup components
@export var physics_object : PickupPhysics = null
@export var physics_shapes : Array[CollisionShape3D] = []
@export var hover_height : float = 4.0
@export var up_distance : float = 10.0
@export var down_distance : float = 20.0
@export var down_radius : float = 2.0

var hover_point : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	_check_setup()
	_apply_ray_variables()


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
	$down.position.y = down_distance
	$down.target_position = Vector3(0, -down_distance, 0)
	$down.shape.height = down_distance * 2
	$down.shape.radius = down_radius


func _calculate_hoverpoint():
	if $down.is_colliding():
		var largest_value : float = physics_object.position.y - down_distance
		var valid : bool = false
		for col_index in $down.get_collision_count():
			if $down.get_collision_point(col_index).y > largest_value \
			and $down.get_collider(col_index) != physics_object:
				largest_value = $down.get_collision_point(col_index).y
				valid = true
		if valid:
			hover_point = largest_value + hover_height
			print("Highest HoverPoint: ", hover_point)
		else:
			hover_point = physics_object.position.y
		if $up.is_colliding() and $up.get_collider() != physics_object:
			var up_point = $up.get_collision_point()
			## shrink by up point to prevent bopping head of object into things
			if hover_point > (up_point.y - hover_height):
				print("Ceiling Capped")
				#hover_point = up_point.y - hover_height
				hover_point = physics_object.position.y
	else:
		hover_point = physics_object.position.y


func _physics_process(delta):
	## Fix the Orientation
	global_rotation = Vector3.ZERO
	$up.enabled = physics_object.grabbed
	$down.enabled = physics_object.grabbed
	if physics_object.grabbed:
		_calculate_hoverpoint()
		print("Target HoverPoint: ", hover_point)
		physics_object.position.y = lerp(
			physics_object.position.y, hover_point, 0.33
		)
