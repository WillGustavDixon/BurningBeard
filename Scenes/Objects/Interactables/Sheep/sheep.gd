extends RigidBody3D
var moving

var sheepPoint: Vector3
var cartPoint: Vector3
var cartNode


func _ready():
	## when created, lock the X and Z axes
	set_axis_lock(PhysicsServer3D.BODY_AXIS_LINEAR_X, true)
	set_axis_lock(PhysicsServer3D.BODY_AXIS_LINEAR_Z, true)
	set_axis_lock(PhysicsServer3D.BODY_AXIS_ANGULAR_X, true)
	set_axis_lock(PhysicsServer3D.BODY_AXIS_ANGULAR_Z, true)
	moving = false
	cartNode = get_tree().get_nodes_in_group("Player")[0]

func _process(delta):
	if moving:
		sheepPoint = global_position
		cartPoint = cartNode.global_position
		if sheepPoint.distance_to(cartPoint) > 500:
			print("Goodbye Sheep")
			queue_free()

func _on_body_entered(body):
	if body.is_in_group("Player"):
		## if it touches the player, unlock the axes.
		set_axis_lock(PhysicsServer3D.BODY_AXIS_LINEAR_X, false)
		set_axis_lock(PhysicsServer3D.BODY_AXIS_LINEAR_Z, false)
		set_axis_lock(PhysicsServer3D.BODY_AXIS_ANGULAR_X, false)
		set_axis_lock(PhysicsServer3D.BODY_AXIS_ANGULAR_Z, false)
		moving = true
		linear_velocity *= 1.2

func _on_cart_cart_position(cartPositionVector):
	cartPoint = cartPositionVector
