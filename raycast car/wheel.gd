extends RayCast3D

@onready var car: RigidBody3D = get_parent().get_parent()

var previous_spring_length: float = 0.0

@export var is_front_wheel: bool

var slip_detect: Vector3 = get_collision_normal()

func _ready():
	add_exception(car)

func _physics_process(delta):

	if is_colliding():
		var collision_point = get_collision_point()
	
		suspension(delta, collision_point)
		acceleration(collision_point)
		
		apply_z_force(collision_point)
		apply_x_force(delta, collision_point)
		

func apply_x_force(delta, collision_point):
	var dir: Vector3 = global_basis.x
	var tire_world_vel: Vector3 = get_point_velocity(global_position)
	var lateral_vel: float = dir.dot(tire_world_vel)
	var slip_detect: Vector3 = get_collision_normal()
	var grip: float
	
	if is_front_wheel:
		grip = car.front_tire_grip
	
	grip = car.rear_tire_grip
	
	if slip_detect.y < 0.75:
		grip = 0
	
	var desired_vel_change: float = -lateral_vel * grip
	var x_force = desired_vel_change + delta
	
	
	car.apply_force(dir * x_force, collision_point - car.global_position)

func get_point_velocity(point: Vector3) -> Vector3:
	return car.linear_velocity + car.angular_velocity.cross(point - car.global_position)
	
	
func apply_z_force(collision_point):
	var dir: Vector3 = global_basis.z
	var tire_world_vel: Vector3 = get_point_velocity(global_position)
	var z_force = dir.dot(tire_world_vel) * car.mass / 10
	
	car.apply_force(-dir * z_force, collision_point - car.global_position)

func acceleration(collision_point):
	if is_front_wheel:
		return
	
	var accel_dir = -global_basis.z
	
	var torque = car.accel_input * car.engine_power
	
	var point = Vector3(collision_point.x, collision_point.y + car.wheel_radius, collision_point.z)
	
	if slip_detect.y < 0.75:
		torque *= -1
	
	car.apply_force(-accel_dir * torque, point - car.global_position)


func suspension(delta, collision_point):
	# the direction the force will be applied
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

