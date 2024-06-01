extends Node3D

@onready var shopCam = $Camera

var items : Array

# Called when the node enters the scene tree for the first time.
func _ready():
	items = get_parent().servingItems.duplicate()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func beginService():
	for item in items:
		continue
		var curItem = item.instantiate()
