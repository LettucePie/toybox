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
@onready var toymenu_frame : Control = $bottom_drawer/toymenu_frame

## Drawer States
var side_drawer_visible : bool = true
var bottom_drawer_visible : bool = false

## Control Menus
@onready var physics_popup : Control = $popup_controls

## Toy Menus
var toy_menus : Array[Control] = []
var current_toy_menu : int = 0


func _ready():
	_load_toybox()
	_ready_position()
	_connect_buttons()


####
#### Toybox and Play Loader integration functions
####

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
			new_listing.pressed.connect(toy_selected)


func toy_selected(toy_name : String):
	print("Toy Selected: ", toy_name)
	play.load_toy(toy_name)
	_show_hide(side_show_hide)


func add_toy_menu(menu_node : Control):
	print("Adding MenuNode: ", menu_node)
	toymenu_frame.add_child(menu_node)
	toy_menus.append(menu_node)
	if toy_menus.size() <= 1:
		bottom_prev.hide()
		bottom_next.hide()
	else:
		bottom_prev.show()
		bottom_next.show()
	set_current_toy_menu(toy_menus.size() - 1)


func focus_toy_menu(menu_node : Control):
	print("Focus Bottom Drawer to toy menu")
	var target_index : int = toy_menus.find(menu_node)
	if target_index >= 0:
		set_current_toy_menu(target_index)
	else:
		print("ERROR: Cannot Focus to Toy Menu not in Toy Menu List")


func remove_toy_menu(menu_node : Control):
	print("Removing MenuNode: ", menu_node)
	toy_menus.erase(menu_node)
	## Some other stuff then queue_free
	menu_node.queue_free()
	if toy_menus.size() <= 1:
		bottom_prev.hide()
		bottom_next.hide()
	else:
		bottom_prev.show()
		bottom_next.show()


func _shift_current_toy_menu(dir : int):
	print("Shifting to next Toy Menu: ", dir)
	current_toy_menu += dir
	if current_toy_menu >= toy_menus.size():
		current_toy_menu = 0
	if current_toy_menu < 0:
		current_toy_menu = toy_menus.size() - 1
	set_current_toy_menu(current_toy_menu)


func set_current_toy_menu(index : int):
	print("Setting Current Toy Menu: ", index)
	for menu in toy_menus:
		menu.visible = false
	toy_menus[index].visible = true
	current_toy_menu = index


func physics_toy_grabbed(toy : PickupPhysics, held : bool):
	print("playui received toy: ", toy, " long_hold: ", held)
	physics_popup.show()
	var mouse_pos : Vector2i = get_local_mouse_position()
	var win_size : Vector2i = get_window().size
	var popup_dim : Vector2i = physics_popup.size
	if mouse_pos.x < win_size.x / 2 and mouse_pos.y < win_size.y / 2:
		physics_popup.set_position(mouse_pos)
	elif mouse_pos.x < win_size.x / 2 and mouse_pos.y >= win_size.y / 2:
		physics_popup.set_position(Vector2i(
			mouse_pos.x, 
			mouse_pos.y - popup_dim.y))
	elif mouse_pos.x >= win_size.x / 2 and mouse_pos.y < win_size.y / 2:
		physics_popup.set_position(Vector2i(
			mouse_pos.x - popup_dim.x,
			mouse_pos.y))
	elif mouse_pos >= win_size / 2:
		physics_popup.set_position(mouse_pos - popup_dim)


func physics_toy_released(toy: PickupPhysics):
	print("playui releasing toy: ", toy)
	physics_popup.hide()


####
#### Actual UI Control functions
####

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
	bottom_prev.pressed.connect(_shift_current_toy_menu.bind(-1))
	bottom_next.pressed.connect(_shift_current_toy_menu.bind(1))


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
