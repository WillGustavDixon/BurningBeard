extends VehicleBody3D

signal hasDied()
signal hasRespawned()

const MAX_STEER = 45
var ENGINE_POWER = 666*1.5
const MAX_RPM = 2000
const MAX_BRAKE_FORCE = 5.0 
const FRICTION = 1
const HI_FRICTION = 0.05
const LO_FRICTION = 1.1

@onready var smoke = $ChimneySmoke

@onready var gimball = $CameraPivot
@onready var camTarg = $CameraPivot/CameraTarget
@onready var cam = $CameraPivot/Camera3D
@onready var rearWheels = find_children("Rear_*", "VehicleWheel3D")
@onready var frontWheels = find_children("Front_*", "VehicleWheel3D")

@onready var acceleration = 15

@export var curCheckpointPos : Vector3
@export var curCheckpointRot : Vector3

var yaw : float = 0
var pitch : float = 0
var yaw_sensitivity : float = 0.07
var pitch_sensitivity : float = 0.07
var con_yaw_sensitivity : float = 2
var con_pitch_sensitivity : float = 2
var yaw_acceleration : float = 15
var pitch_acceleration : float = 15
var pitch_max : float = 60
var pitch_min : float = -20
var yaw_max : float = 70
var yaw_min : float = -70

var camera_rotate_max = 0
var camera_rotate_min = 0
var cam_rotation: float = 0

var brake_val =  1.0


func _ready():
	respawn()
	#make sure to set the respawn when moving the cart position
	
func _physics_process(delta):
	if Input.is_action_pressed("Respawn"):
		emit_signal("hasDied")
		
	# Camera parameters
	pitch = clamp(pitch, pitch_min, pitch_max)
	yaw = clamp(yaw, yaw_min, yaw_max)
	gimball.rotation_degrees.y = lerp(gimball.rotation_degrees.y, yaw, acceleration * delta)
	gimball.rotation_degrees.x = lerp(gimball.rotation_degrees.x, pitch, acceleration * delta)
	camTarg.global_rotation_degrees.z = lerp(camTarg.global_rotation_degrees.z, cam_rotation, acceleration * delta)
	cam_rotation = clamp(cam_rotation, camera_rotate_min, camera_rotate_max)
	
	
	var RearLeftWheelRPM = $Rear_Left_Wheel.get_rpm()
	var VELOCITY: Vector3 = get_linear_velocity()

	
	if Input.is_action_pressed("RearViewCamera"):
		$Rear_View_Camera.set_current(true)
	else:
		$CameraPivot/Camera3D.set_current(true)
	
	if Input.is_action_pressed("Handbrake"):
		brake_val = 10
	else:
		brake_val = 0
	
	if Input.is_action_pressed("Reverse"):
		ENGINE_POWER = 333
	else:
		ENGINE_POWER = 666*1.5

	var steerMod = ((-0.75/40) * abs(VELOCITY.length())) + 1
	if steerMod < 0.15: steerMod = 0.15
	
	#Throttle rpm of wheels
	if RearLeftWheelRPM > MAX_RPM:
		RearLeftWheelRPM = MAX_RPM
	
	# Print section
	print(steerMod)
	print(RearLeftWheelRPM)

	if Input.is_action_pressed("Drift"):
		for wheel in frontWheels: 
			wheel.wheel_friction_slip = LO_FRICTION
			brake_val = 0.5
	else:
		if !rearWheels[0].is_in_contact() || !rearWheels[1].is_in_contact(): 
			for wheel in frontWheels: wheel.wheel_friction_slip = HI_FRICTION
		else:
			for wheel in frontWheels: wheel.wheel_friction_slip = FRICTION
			
	#Smoke increase on acceleration
	if Input.is_action_pressed("Accelerate"):
		smoke.amount_ratio = 1
	else:
		smoke.amount_ratio = 0.25
		
	#Controller Camera
	yaw -= Input.get_action_strength("controllerCameraRight") * con_pitch_sensitivity
	yaw += Input.get_action_strength("controllerCameraLeft") * con_yaw_sensitivity
	pitch -= Input.get_action_strength("controllerCameraDown") * con_pitch_sensitivity
	pitch += Input.get_action_strength("controllerCameraUp") * con_pitch_sensitivity
	
	steering = Input.get_axis("Right", "Left") * (MAX_STEER*steerMod) * delta
	engine_force = Input.get_axis("Reverse", "Accelerate") * ENGINE_POWER
	brake = brake_val * MAX_BRAKE_FORCE
	
func _input(event):
	if event is InputEventMouseMotion:
		yaw += -event.relative.x * yaw_sensitivity
		pitch += event.relative.y * pitch_sensitivity

func doDeath():
	freezeCam()
	emit_signal("hasDied")

# Runs when touching a death plane, puts the player back at the last checkpoint.
func respawn(): 
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	global_rotation_degrees = curCheckpointRot
	global_position = curCheckpointPos
	emit_signal("hasRespawned")

func freezeCam():
	cam.follow = false

func thawCam():
	cam.follow = true

func _on_body_entered(body): # THIS RUNS IF TOUCHING SOMETHING WITH PHYSICS
	pass

func _on_area_entered(area): # WHILE THIS RUNS IF TOUCHING AN Area3D NODE
	if area.is_in_group("DeathPlane"):
		doDeath()
	elif area.is_in_group("Checkpoint"):
		curCheckpointPos = area.checkpointPos
		curCheckpointRot = area.checkpointRot
