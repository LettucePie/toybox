extends AudioStreamPlayer3D
class_name ImpactSound

@export var col_obj : CollisionObject3D = null
@export var magnitude_decibal_curve : Curve
@export var min_impact_magnitude : float = 0.4
@export var max_impact_magnitude : float = 300.0
@export var min_decibal_linear : float = 0.2
@export var max_decibal_linear : float = 1.2


func _ready():
	if col_obj == null:
		if get_parent() is CollisionObject3D:
			col_obj = get_parent()
	if col_obj.has_signal("body_entered"):
		if !col_obj.body_entered.is_connected(play_sound):
			col_obj.body_entered.connect(play_sound)
		if col_obj.max_contacts_reported == 0:
			col_obj.contact_monitor = true
			col_obj.max_contacts_reported = 1


func play_sound(node):
	var impact_velocity = PhysicsServer3D \
		.body_get_direct_state(col_obj.get_rid()) \
		.get_contact_local_velocity_at_position(0)
	#print(impact_velocity.length_squared() * col_obj.mass)
	var impact_magnitude = impact_velocity.length_squared() * col_obj.mass
	var decibal_percent = magnitude_decibal_curve.sample(
		inverse_lerp(
			min_impact_magnitude, 
			max_impact_magnitude, 
			impact_magnitude))
	volume_db = linear_to_db(lerp(
		min_decibal_linear, 
		max_decibal_linear, 
		decibal_percent))
	play()
