extends RigidBody3D
var moving

func _ready():
	## when created, lock the X and Z axes
	set_axis_lock(PhysicsServer3D.BODY_AXIS_LINEAR_X, true)
	set_axis_lock(PhysicsServer3D.BODY_AXIS_LINEAR_Z, true)
	set_axis_lock(PhysicsServer3D.BODY_AXIS_ANGULAR_X, true)
	set_axis_lock(PhysicsServer3D.BODY_AXIS_ANGULAR_Z, true)
	moving = false

func _process(delta):
	if moving:
		pass

func _on_body_entered(body):
	print("Baaaa")
	if body.is_in_group("Player"):
		## if it touches the player, unlock the axes.
		set_axis_lock(PhysicsServer3D.BODY_AXIS_LINEAR_X, false)
		set_axis_lock(PhysicsServer3D.BODY_AXIS_LINEAR_Z, false)
		set_axis_lock(PhysicsServer3D.BODY_AXIS_ANGULAR_X, false)
		set_axis_lock(PhysicsServer3D.BODY_AXIS_ANGULAR_Z, false)
		moving = true
		linear_velocity *= 1.2
