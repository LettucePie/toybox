extends Node

@export var scaled_themes : Array[Theme]

@export var scale_curve : Curve
@export var min_len : float = 1000.0
@export var max_len : float = 5500.0
@export var min_sca : int = 10
@export var max_sca : int = 48


func _ready():
	get_viewport().size_changed.connect(rescale_theme_fonts)
	rescale_theme_fonts()


func rescale_theme_fonts():
	var size_factor = get_viewport().size.length()
	var target_scale = lerp(min_sca, max_sca, scale_curve.sample(inverse_lerp(min_len, max_len, size_factor)))
	target_scale = int(target_scale)
	ThemeDB.fallback_font_size = target_scale
	if scaled_themes.size() > 0:
		for font in scaled_themes:
			font.default_font_size = target_scale
	
