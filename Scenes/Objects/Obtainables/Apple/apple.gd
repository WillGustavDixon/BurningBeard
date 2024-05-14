extends RigidBody3D

var canPickUp := false

func _process(delta):
	if canPickUp:
		if Input.is_action_just_pressed("Interact"):
			get_owner().openInv("01", self)

func itemReceived():
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("Player"): 
		canPickUp = true
		
func _on_body_exited(body):
	if body.is_in_group("Player"): 
		canPickUp = false
