extends Node3D

@onready var rigbod = $Rigidbody3D 

var movementLocked : bool
var pos; var rot

# Called when the node enters the scene tree for the first time.
func _ready():
	movementLocked = true
	pos = global_position
	rot = global_rotation

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print(rigbod.get_colliding_bodies())
	if(movementLocked):
		global_position = pos
		global_rotation = rot

func OnCollideWithPlayer():
	movementLocked = false
