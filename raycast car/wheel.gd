extends RayCast3D

@onready var car: RigidBody3D = get_parent().get_parent()

var previous_spring_length: float = 0.0

@export var is_front_wheel: bool

func _ready():
	add_exception(car)

func _physics_process(delta):
	
	if is_colliding():
		var collision_point = get_collision_point()
		
		suspension(delta, collision_point)
		
		acceleration(collision_point)

func acceleration(collision_point):
	if is_front_wheel:
		return
		
	var accel_dir = global_basis.z
	
	var torque = car.accel_input * car.engine_power
	
	var point = Vector3(collision_point.x, collision_point.y + car.wheel_radius, collision_point.z)
	
	car.apply_force(accel_dir * torque, point - car.global_position)

func suspension(delta, collision_point):
		
		#the direction the force will be applied
		var susp_dir = global_basis.y
 
		var raycast_origin = global_position
		var raycast_dest = collision_point
		var distance = raycast_dest.distance_to(raycast_origin)
 
		var spring_length = clamp(distance - car.wheel_radius, 0, car.suspension_rest_dist)
 
		var spring_force = car.spring_strength * (car.suspension_rest_dist - spring_length)
 
		var spring_velocity = (previous_spring_length - spring_length) / delta
 
		var damper_force = car.spring_damper * spring_velocity
 
		var suspension_force = basis.y * (spring_force + damper_force)
 
		previous_spring_length = spring_length
 
		var point = Vector3(collision_point.x, collision_point.y + car.wheel_radius, collision_point.z)
 
		car.apply_force(susp_dir * suspension_force, point - car.global_position)
		
			
			
			
