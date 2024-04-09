extends VehicleBody3D

const MAX_STEER = 0.8
const ENGINE_POWER = 700

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

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	
func _physics_process(delta):
	steering = move_toward(steering, Input.get_axis("Right", "Left") * MAX_STEER, delta * 2.5)
	engine_force = Input.get_axis("Back", "Forward") * ENGINE_POWER
	yaw_node.rotation_degrees.y = lerp(yaw_node.rotation_degrees.y, yaw, yaw_acceleration * delta)
	pitch_node.rotation_degrees.x = lerp(pitch_node.rotation_degrees.x, pitch, pitch_acceleration * delta)
	pitch = clamp(pitch, pitch_min, pitch_max)
	yaw = clamp(yaw, yaw_min, yaw_max)
	
func _input(event):
	if event is InputEventMouseMotion:
		yaw += -event.relative.x * yaw_sensitivity
		pitch += -event.relative.y * pitch_sensitivity
