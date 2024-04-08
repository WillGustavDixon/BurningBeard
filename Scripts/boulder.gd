extends RigidBody3D

func _ready():
	## when created, lock the X and Z axes
	set_axis_lock(PhysicsServer3D.BODY_AXIS_LINEAR_X, true)
	set_axis_lock(PhysicsServer3D.BODY_AXIS_LINEAR_Z, true)
	set_axis_lock(PhysicsServer3D.BODY_AXIS_ANGULAR_X, true)
	set_axis_lock(PhysicsServer3D.BODY_AXIS_ANGULAR_Z, true)

func _on_body_entered(body):
	if(body.is_in_group("Player")):
		## if it touches the player, unlock the axes.
		set_axis_lock(PhysicsServer3D.BODY_AXIS_LINEAR_X, false)
		set_axis_lock(PhysicsServer3D.BODY_AXIS_LINEAR_Z, false)
		set_axis_lock(PhysicsServer3D.BODY_AXIS_ANGULAR_X, false)
		set_axis_lock(PhysicsServer3D.BODY_AXIS_ANGULAR_Z, false)
		linear_velocity *= 1.2
