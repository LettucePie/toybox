extends Resource
class_name ToyMeta

## The Display Name of the Toy
@export var name : String = "Toy Name"
## The Display Icon of the Toy
@export var icon : Texture2D 
## The Memory rating of this toy, with higher memory toys using a higher value.
@export var memory_level : int = 1
## The PackedScene (aka tscn) containing the Control Node ui used for expanding
## functionality to the Toy.[br][br]Root Nodes of all Toy Menus must extend
## [ToyUI]
@export var menu : PackedScene
## Individual Object PackedScenes that will spawn immediately upon loading the
## Toy, such as a marble, and some pins. Object positions will maintain their
## arrangement even if repositioned by [member ToyMeta.spawn_at_camera].
@export var objects : Array[PackedScene] = []
## If true, iterates through all Objects and connects their 
## [signal PickupPhysics.object_grabbed] and 
## [signal PickupPhysics.object_released] signals to the PlayUI if they extend
## [PickupPhysics].[br][br]Setting to false skips that check. 
@export var objects_have_pickup_physics : bool = true
## Adds the Camera Dolly Position to the position of each indiviual Toy Object.
@export var spawn_at_camera : bool = true
## Adds this position to the position of each individual Toy Object, but only
## if [member ToyMeta.spawn_at_camera] is false.
@export var spawn_at_position : Vector3 = Vector3(0, 3, 0)
