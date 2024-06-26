extends Node

@export var scale_curve : Curve
@export var min_len : float = 1000.0
@export var max_len : float = 5500.0
@export var min_sca : float = 0.8
@export var max_sca : float = 4.0

func _ready():
	get_viewport().size_changed.connect(rescale_theme)
	rescale_theme()


func rescale_theme():
	var size_factor = get_viewport().size.length()
	var target_scale = lerp(min_sca, max_sca, scale_curve.sample(inverse_lerp(min_len, max_len, size_factor)))
	print("SETTING THEME SCALE TO ", target_scale)
	ThemeDB.set_fallback_base_scale(target_scale)
	
