extends Node3D
####
#### Click and Drag mouse to move camera.
#### Spacebar to save image into screenshot_destination
#### screenshot_destination must be set manually
#### Load models/subjects as a child of Stage for stage controls.

@export_global_dir var screenshot_destination = null
@export var screenshot_name_override : String = ""

@export var spin_stage : bool = true
@export var spin_speed : float = 2.0

@onready var session_id : int = randi_range(1000, 9999)
var snap_count : int = 0
var mouse_held : bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	if screenshot_destination == null:
		for x in 5:
			print("ERROR: Set Screenshot Destination")
	update_label()


func update_label():
	var textout = "cam_pivot_deg: "
	textout += str($pivot.rotation.y) + "\ncam_distance: "
	textout += str($pivot/dial/Camera3D.position.z)
	$Label.text = textout


func capture_image():
	var image = get_viewport().get_texture().get_image()
	var filename = screenshot_destination + "/"
	if screenshot_name_override != "":
		filename += screenshot_name_override + "_" + str(snap_count)
	else:
		if $Stage.get_child_count() > 0:
			filename += $Stage.get_child(0).name + "_" + str(snap_count)
		else:
			filename += "photoboothsnap_" + str(snap_count)
	snap_count += 1
	filename += "_" + str(session_id)
	print(filename)
	print(image.save_jpg(filename + ".jpg"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if spin_stage:
		$Stage.rotate_y(spin_speed * delta)


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index < 2:
			mouse_held = event.pressed
	if event is InputEventMouseMotion:
		if mouse_held:
			$pivot.rotate_y(event.relative.x * 0.01)
			$pivot/dial/Camera3D.position.z += event.relative.y * 0.1
			update_label()
	if event is InputEventKey:
		if event.keycode == KEY_SPACE and event.pressed:
			capture_image()
