extends Control
class_name PlayUI
#### This functions as the Main Host of the Toybox MetaData list and \
#### the unique menus each toy may require. 

## ToyBox Stuff
@export var play : Play
@export var toybox : Toybox
@export var toy_listing : PackedScene

## Animation Stuff
@onready var side_anim : AnimationPlayer = $side_drawer/AnimationPlayer
@onready var bottom_anim : AnimationPlayer = $bottom_drawer/AnimationPlayer

## Drawer Elements
@onready var side_show_hide : Button = $side_drawer/show_hide
@onready var bottom_show_hide : Button = $bottom_drawer/drawer_controls/show_hide
@onready var bottom_prev : Button = $bottom_drawer/drawer_controls/previous
@onready var bottom_next : Button = $bottom_drawer/drawer_controls/next
@onready var side_toy_list : VBoxContainer = $side_drawer/ScrollPadArea/ScrollHaptics/VBoxContainer

## Drawer States
var side_drawer_visible : bool = true
var bottom_drawer_visible : bool = false
#var drawer_blend_target : Vector2 = Vector2(0, 1)


func _ready():
	_load_toybox()
	_ready_position()
	_connect_buttons()


func _load_toybox():
	if play == null:
		print("ERROR: play_ui not connected to Play")
		if get_parent() is Play:
			play = get_parent()
			print("RECOVER: play_ui found Play")
	if toybox == null:
		print("ERROR: play_ui not connected to ToyBox")
		for child in get_parent().get_children():
			if child is Toybox:
				toybox = child
				print("RECOVER: play_ui found ToyBox sibling.")
		if toybox == null:
			print("ERROR: play_ui failed to find ToyBox... giving up")
	if play != null and toybox != null:
		print("Fill Toy Listing with entries")
		for toy in toybox.get_toy_listing():
			var new_listing : HapticButton = toy_listing.instantiate()
			new_listing.set_properties(toy[0], toy[1])
			new_listing.name = str(toy[0])
			side_toy_list.add_child(new_listing)


func _ready_position():
	side_drawer_visible = true
	bottom_drawer_visible = false
	bottom_anim.play("hide")
	side_anim.play("show")
	## TODO replace with icons
	side_show_hide.text = "Hide"
	bottom_show_hide.text = "Show"
	#drawer_blend_target = Vector2(0, 1)


func _connect_buttons():
	side_show_hide.pressed.connect(_show_hide.bind(side_show_hide))
	bottom_show_hide.pressed.connect(_show_hide.bind(bottom_show_hide))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _show_hide(drawer : Button):
	var hiding : bool = false
	if drawer == bottom_show_hide:
		print("Bottom Show Hide")
		if bottom_drawer_visible:
			bottom_drawer_visible = false
			## TODO replace text with icons
			## Maybe put icons in animationplayer
			bottom_show_hide.text = "Show"
			bottom_anim.play("hide")
		else:
			bottom_drawer_visible = true
			bottom_show_hide.text = "Hide"
			bottom_anim.play("show")
			if side_drawer_visible:
				side_anim.play("hide")
				side_drawer_visible = false
				side_show_hide.text = "Show"
	elif drawer == side_show_hide:
		print("Side Show Hide")
		if side_drawer_visible:
			side_drawer_visible = false
			side_show_hide.text = "Show"
			side_anim.play("hide")
		else:
			side_drawer_visible = true
			side_show_hide.text = "Hide"
			side_anim.play("show")
			if bottom_drawer_visible:
				bottom_anim.play("hide")
				bottom_drawer_visible = false
				bottom_show_hide.text = "Show"
