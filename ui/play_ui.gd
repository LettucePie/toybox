extends Control

@onready var tree : AnimationTree = $AnimationTree
@onready var playback : AnimationNodeStateMachinePlayback = tree.get("parameters/playback")
@onready var anim : AnimationPlayer = $AnimationPlayer

## Drawer Buttons
@onready var side_show_hide : Button = $side_drawer/show_hide
@onready var bottom_show_hide : Button = $bottom_drawer/drawer_controls/show_hide
@onready var bottom_prev : Button = $bottom_drawer/drawer_controls/previous
@onready var bottom_next : Button = $bottom_drawer/drawer_controls/next

## Drawer States
var side_drawer_visible : bool = true
var bottom_drawer_visible : bool = false
var drawer_blend_target : Vector2 = Vector2(0, 1)


func _ready():
	_ready_position()
	_connect_buttons()


func _connect_buttons():
	side_show_hide.pressed.connect(_show_hide.bind(side_show_hide))
	bottom_show_hide.pressed.connect(_show_hide.bind(bottom_show_hide))


func _ready_position():
	side_drawer_visible = true
	bottom_drawer_visible = false
	_play_anim("all_hide")
	_play_anim("side_show")
	_play_anim("bottom_hide")
	## TODO replace with icons
	side_show_hide.text = "Hide"
	bottom_show_hide.text = "Show"
	drawer_blend_target = Vector2(0, 1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	tree.set("parameters/drawer_pos/blend_position", 
		tree["parameters/drawer_pos/blend_position"].lerp(
			drawer_blend_target,
			delta * 5)
		)


func _show_hide(drawer : Button):
	var hiding : bool = false
	if drawer == bottom_show_hide:
		print("Bottom Show Hide")
		if bottom_drawer_visible:
			bottom_drawer_visible = false
			## TODO replace text with icons
			## Maybe put icons in animationplayer
			bottom_show_hide.text = "Show"
		else:
			bottom_drawer_visible = true
			bottom_show_hide.text = "Hide"
			side_drawer_visible = false
			side_show_hide.text = "Show"
	elif drawer == side_show_hide:
		print("Side Show Hide")
		if side_drawer_visible:
			side_drawer_visible = false
			side_show_hide.text = "Show"
		else:
			side_drawer_visible = true
			side_show_hide.text = "Hide"
			bottom_drawer_visible = false
			bottom_show_hide.text = "Show"
	drawer_blend_target = Vector2(
		int(bottom_drawer_visible), 
		int(side_drawer_visible))


## Animation Tree Override
func _play_anim(animation : String):
	if anim.has_animation(animation):
		anim.play(animation)
