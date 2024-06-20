extends Node3D
#### How can I save a reference pointer in memory?


@export var reposition_child_by_parent : bool = true
@export_enum("Pos", "Rot", "Sca") var dataset : int
@export_enum("x", "y", "z") var datapoint : int
@export var min_data : float
@export var max_data : float
@export var adjust_curve : Curve
@export var min_var : float
@export var max_var : float
@export_enum("Pos", "Rot", "Sca") var varset : int
@export_enum("x", "y", "z") var varpoint : int

func _decipher_set(target : Node3D, set_code : int) -> Vector3:
	var result : Vector3 = target.position
	if set_code == 1:
		result = target.rotation
	elif set_code == 2:
		result = target.scale
	return result


func _decipher_point(set_vec : Vector3, point_code : int) -> float:
	var result = set_vec.x
	if point_code == 1:
		result = set_vec.y
	if point_code == 2:
		result = set_vec.z
	return result


func _set_point(target : Node3D, set_code : int, point_code : int, value : float):
	if set_code == 0:
		if point_code == 0:
			target.position.x = value
		if point_code == 1:
			target.position.y = value
		if point_code == 2:
			target.position.z = value
	if set_code == 1:
		if point_code == 0:
			target.rotation.x = value
		if point_code == 1:
			target.rotation.y = value
		if point_code == 2:
			target.rotation.z = value
	if set_code == 2:
		if point_code == 0:
			target.scale.x = value
		if point_code == 1:
			target.scale.y = value
		if point_code == 2:
			target.scale.z = value


func _process_curve(child : Node3D, parent : Node3D):
	var data_percent = inverse_lerp(
		min_data, max_data, 
		_decipher_point(_decipher_set(parent, dataset), datapoint))
	var curved_percent = adjust_curve.sample(data_percent)
	var var_value = lerp(min_var, max_var, curved_percent)
	_set_point(child, varset, varpoint, var_value)


func _physics_process(delta):
	## Fix the Orientation
	global_rotation = Vector3.ZERO
	if reposition_child_by_parent:
		for child in get_children():
			_process_curve(child, get_parent())
