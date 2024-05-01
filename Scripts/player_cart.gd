extends VehicleBody3D

const MAX_STEER = 0.6
const ENGINE_POWER = 500

@onready var yaw_node = $CameraPivot/CamYaw
@onready var pitch_node = $CameraPivot/CamYaw/CamPitch
@onready var camera = $CameraPivot/CamYaw/CamPitch/Camera3D
@onready var acceleration = 15

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

var camera_rotate_max = 15
var camera_rotate_min = -15
var cam_rotation: float = 0

func _ready():
	respawn.connect(onRespawn)
	
func _physics_process(delta):
	yaw_node.rotation_degrees.y = lerp(yaw_node.rotation_degrees.y, yaw, yaw_acceleration * delta)
	pitch_node.rotation_degrees.x = lerp(pitch_node.rotation_degrees.x, pitch, pitch_acceleration * delta)
	pitch = clamp(pitch, pitch_min, pitch_max)
	yaw = clamp(yaw, yaw_min, yaw_max)
	yaw_node.rotation_degrees.y = lerp(yaw_node.rotation_degrees.y, yaw, acceleration * delta)
	pitch_node.rotation_degrees.x = lerp(pitch_node.rotation_degrees.x, pitch, acceleration * delta)
	camera.global_rotation_degrees.z = lerp(camera.global_rotation_degrees.z, cam_rotation, acceleration * delta)
	cam_rotation = clamp(cam_rotation, camera_rotate_min, camera_rotate_max)
	steering = move_toward(steering, Input.get_axis("Right", "Left") * MAX_STEER, delta * 2.5)
	engine_force = Input.get_axis("Reverse", "Accelerate") * ENGINE_POWER

func _input(event):
	if event is InputEventMouseMotion:
		yaw += -event.relative.x * yaw_sensitivity
		pitch += -event.relative.y * pitch_sensitivity





















































signal respawn()
@export var curCheckpointPos : Vector3
@export var curCheckpointRot : Vector3

func onRespawn():
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	global_rotation = curCheckpointRot
	global_position = curCheckpointPos

func _on_body_entered(body):
	if body.is_in_group("DeathPlane"):
		emit_signal("respawn")
