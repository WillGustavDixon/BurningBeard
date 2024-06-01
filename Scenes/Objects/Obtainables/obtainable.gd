extends RigidBody3D

@export var id : String
var canPickUp := false

func _process(delta):
	if canPickUp:
		if Input.is_action_just_pressed("Interact"):
			get_owner().openInv(id, self)

func itemReceived():
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("Player"): 
		canPickUp = true
		
func _on_body_exited(body):
	if body.is_in_group("Player"): 
		canPickUp = false

# might need to do something specific based on the item at some point, idk
func doSomething():
	match id:
		_: pass
