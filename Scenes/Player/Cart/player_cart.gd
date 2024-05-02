extends VehicleBody3D

const MAX_STEER = 0.6
var ENGINE_POWER = 700
const MAX_BRAKE_FORCE = 5.0 

@onready var yaw_node = $CameraPivot/CamYaw
@onready var pitch_node = $CameraPivot/CamYaw/CamPitch
@onready var camera = $CameraPivot/CamYaw/CamPitch/Camera3D
@onready var acceleration = 15

@export var curCheckpointPos : Vector3
@export var curCheckpointRot : Vector3

var yaw : float = 0
var pitch : float = 0
var yaw_sensitivity : float = 0.07
var pitch_sensitivity : float = 0.07
var yaw_acceleration : float = 15
var pitch_acceleration : float = 15
var pitch_max : float = 25
var pitch_min : float = -5
var yaw_max : float = 25
var yaw_min : float = -25

var camera_rotate_max = 0
var camera_rotate_min = 0
var cam_rotation: float = 0

var brake_val =  1.0

func _ready():
	respawn()
	
func _physics_process(delta):
	var VELOCITY: Vector3 = get_linear_velocity()
	
	yaw_node.rotation_degrees.y = lerp(yaw_node.rotation_degrees.y, yaw, yaw_acceleration * delta)
	pitch_node.rotation_degrees.x = lerp(pitch_node.rotation_degrees.x, pitch, pitch_acceleration * delta)
	pitch = clamp(pitch, pitch_min, pitch_max)
	yaw = clamp(yaw, yaw_min, yaw_max)
	yaw_node.rotation_degrees.y = lerp(yaw_node.rotation_degrees.y, yaw, acceleration * delta)
	pitch_node.rotation_degrees.x = lerp(pitch_node.rotation_degrees.x, pitch, acceleration * delta)
	camera.global_rotation_degrees.z = lerp(camera.global_rotation_degrees.z, cam_rotation, acceleration * delta)
	cam_rotation = clamp(cam_rotation, camera_rotate_min, camera_rotate_max)
	if Input.is_action_pressed("Handbrake"):
		brake_val = 10
	else:
		brake_val = 0
	
	if Input.is_action_pressed("Reverse"):
		ENGINE_POWER *= 0.5
	else:
		ENGINE_POWER = 666
		
	if VELOCITY.x > 20 or VELOCITY.x < -20:
		ENGINE_POWER *= 0.01
	else:
		ENGINE_POWER = 666
		
	if VELOCITY.z > 20 or VELOCITY.z < -20:
		ENGINE_POWER *= 0.01
	else:
		ENGINE_POWER = 666
	
	steering = move_toward(steering, Input.get_axis("Right", "Left") * MAX_STEER, delta * 2.5)
	engine_force = Input.get_axis("Reverse", "Accelerate") * ENGINE_POWER
	brake = brake_val * MAX_BRAKE_FORCE
	
func _input(event):
	if event is InputEventMouseMotion:
		yaw += -event.relative.x * yaw_sensitivity
		pitch += -event.relative.y * pitch_sensitivity

# Runs when touching a death plane, puts the player back at the last checkpoint.
func respawn(): 
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	global_rotation = curCheckpointRot
	global_position = curCheckpointPos

func _on_body_entered(body):
	#print("ran")
	if body.is_in_group("DeathPlane"):
		respawn()
