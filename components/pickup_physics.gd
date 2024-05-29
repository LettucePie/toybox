extends RigidBody3D
class_name PickupPhysics

signal object_grabbed(object)
signal object_released(object)

var grabbing : bool = false
var grab_time : int = 0
var grabbed : bool = false

func _ready():
	_connect_signals()


func _connect_signals():
	if !input_event.is_connected(self._on_input_event):
		input_event.connect(self._on_input_event)


func _on_input_event(camera, event, position, normal, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == 1 and event.pressed:
			if !grabbing and !grabbed:
				print(self, " Grabbing...")
				grabbing = true
				grab_time = Time.get_ticks_msec()
		elif event.button_index == 1 and !event.pressed:
			if grabbing:
				grabbing = false
			if grabbed:
				grabbed = false
				emit_signal("object_released", self)


func _physics_process(delta):
	if (grabbing and !grabbed) and Time.get_ticks_msec() - grab_time > 100:
		print(self, " Grabbed!")
		grabbed = true
		emit_signal("object_grabbed", self)
