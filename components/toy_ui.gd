extends Control
class_name ToyUI
##
signal connected_to_playnode()
signal objects_set(objects)
signal objects_changed(objects)
##
var play_node_connected : bool = false
var play_node : Play = null
##
var toy_objects : Array

func _ready():
	play_node_connected = false
	play_node = null

func set_play_node(node : Play):
	play_node = node
	play_node_connected = true
	emit_signal("connected_to_playnode")

func get_play_node() -> Play:
	return play_node

func is_play_connected() -> bool:
	return play_node_connected

func add_multiple_toy_objects(objects : Array):
	for object in objects:
		add_toy_object(object)

func remove_multiple_toy_objects(objects : Array):
	for object in objects:
		remove_toy_object(object)

func add_toy_object(object : Node3D):
	var changed : bool = false
	if !toy_objects.has(object):
		toy_objects.append(object)
		changed = true
	if changed:
		emit_signal("objects_changed", toy_objects)

func remove_toy_object(object : Node3D):
	var changed : bool = false
	if toy_objects.has(object):
		toy_objects.erase(object)
		changed = true
	if changed:
		emit_signal("objects_changed", toy_objects)

func set_toy_objects(objects : Array):
	toy_objects = objects
	emit_signal("objects_set", toy_objects)

func get_toy_objects() -> Array:
	return toy_objects

func has_toy_objects() -> bool:
	return toy_objects.size() > 0
