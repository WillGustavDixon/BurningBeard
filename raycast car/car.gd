extends RigidBody3D

@export var suspension_rest_dist: float = 0.5
@export var spring_strength: float = 10
@export var spring_damper: float = 1
@export var wheel_radius: float = 0.33

@export var debug: bool = false
@export var engine_power: float

var accel_input

@export var steering_angle: float = 30.0
@export var front_tire_grip: float = 2.0
@export var rear_tire_grip: float = 2.0

var steering_input

func _process(delta):
	accel_input = Input.get_axis("Reverse", "Accelerate")
	
	steering_input = Input.get_axis("Right", "Left")
	var steering_rotation = steering_input * steering_angle
	
	var fl_wheel = $Wheels/FL_Wheel
	var fr_wheel = $Wheels/FR_Wheel
	
	if steering_rotation != 0:
		var angle = clamp(fl_wheel.rotation.y + steering_rotation, -steering_angle, steering_angle)
		var new_rotation = angle * delta
		
		fl_wheel.rotation.y = lerp(fl_wheel.rotation.y, new_rotation, 0.3)
		fr_wheel.rotation.y = lerp(fr_wheel.rotation.y, new_rotation, 0.3)
	else:
		fl_wheel.rotation.y = lerp(fl_wheel.rotation.y, 0.0, 0.2)
		fr_wheel.rotation.y = lerp(fr_wheel.rotation.y, 0.0, 0.2)
		
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
	yaw_node.rotation_degrees.y = lerp(yaw_node.rotation_degrees.y, yaw, yaw_acceleration * delta)
	pitch_node.rotation_degrees.x = lerp(pitch_node.rotation_degrees.x, pitch, pitch_acceleration * delta)
	pitch = clamp(pitch, pitch_min, pitch_max)
	yaw = clamp(yaw, yaw_min, yaw_max)
	
func _input(event):
	if event is InputEventMouseMotion:
		yaw += -event.relative.x * yaw_sensitivity
		pitch += -event.relative.y * pitch_sensitivity
