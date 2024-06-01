extends Panel
## Animating controls kinda sucks, or I just can't figure it out.
## This is a bodge solution... kinda nice having the more granular control tho

## Usersetting?
@export_range(0.2, 0.8, 0.01) var screen_percent : float = 0.33

@onready var lip : float = $drawer_controls.anchor_bottom
var shown_pos : Vector2
var hide_pos : Vector2
var shown : bool = false

func _ready():
	get_window().size_changed.connect(self._rescale)
	_rescale()


func _rescale():
	var win_dim : Vector2i = get_window().size
	var target_size : Vector2 = Vector2(win_dim.x, win_dim.y * screen_percent)
	shown_pos = Vector2(0, win_dim.y - target_size.y)
	hide_pos = Vector2(
		0, 
		shown_pos.y + target_size.y - target_size.y * lip)
	self.size = target_size
	if shown:
		self.position = shown_pos
	else:
		self.position = hide_pos


func show_hide(tf):
	if tf:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position", shown_pos, 0.5)
		#tween.tween_callback(tween.queue_free())
	else:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "position", hide_pos, 0.5)
		#tween.tween_callback(tween.queue_free())
