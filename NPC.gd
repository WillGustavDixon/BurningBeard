extends RigidBody3D

var canTalk := false # will use later
var canTrade := false

var npcID
var items := []


func _process(delta):
	if canTrade:
		if Input.is_action_just_pressed("Interact"):
			get_owner().openTrade()

func tradeExited():
	pass

func _on_body_entered(body):
	if body.is_in_group("Player"): 
		canTrade = true
		
func _on_body_exited(body):
	if body.is_in_group("Player"): 
		canTrade = false
