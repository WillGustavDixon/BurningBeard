extends RigidBody3D

@export var disappears : bool

var beenHit

func _ready():
	freeze_mode = FREEZE_MODE_KINEMATIC
	freeze = true
	beenHit = false

# called when colliding with another object (that has a CollisionObject3D attached)
func _on_body_entered(body):
	if body.is_in_group("Destroyer") && !beenHit: # if touching a destroyer object for the first time
		if disappears: 
			queue_free() # delete me
		else:
			freeze = false # makes the object able to be moved.
			beenHit = true
			set_axis_velocity(body.linear_velocity*1.5)
