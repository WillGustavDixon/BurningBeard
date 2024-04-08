extends RigidBody3D

@export var suspension_rest_dist: float = 0.5
@export var spring_strength: float = 100
@export var spring_damper: float = 2
@export var wheel_radius: float = 0.33

@export var debug: bool = false
@export var engine_power: float

var accel_input

func _process(delta):
	accel_input = Input.get_axis("Accelerate", "Reverse")
