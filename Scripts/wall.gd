extends RigidBody3D
var beenHit
func _ready():
	freeze_mode = FREEZE_MODE_KINEMATIC
	freeze = true
	beenHit = false

# called when colliding with another object (that has a CollisionObject3D attached)
func _on_body_entered(body):
	if(body.is_in_group("Destroyer") && !beenHit): 
		freeze = false
		beenHit = true
		set_axis_velocity(body.linear_velocity*1.5)
