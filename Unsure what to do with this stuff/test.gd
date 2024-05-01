extends RayCast3D

@onready var car: RigidBody3D = get_parent().get_parent()

var slide_detect: bool = true
var slip_power = 100
var velocity: Vector3 = Vector3.ZERO

func slip_force():
	if slide_detect:
		var grip = 0
		car.apply_force(velocity * slip_power)


