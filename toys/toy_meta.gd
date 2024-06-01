extends Resource
class_name ToyMeta

@export var name : String = "Toy Name"
@export var icon : Texture2D 
@export var memory_level : int = 1
@export var menu : PackedScene
@export var objects : Array[PackedScene] = []
@export var objects_have_pickup_physics : bool = true
@export var pass_objects : bool = false
@export var menu_receiver_function : String = "receiver"
@export var spawn_at_camera : bool = true
@export var spawn_at_position : Vector3 = Vector3(0, 3, 0)
