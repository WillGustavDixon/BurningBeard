extends VehicleBody3D

const MAX_STEER = 0.8
const ENGINE_POWER = 300

@onready var camera_pivot = $CameraPivot
@onready var camera_3d = $CameraPivot/Camera3D


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _physics_process(delta):
	steering = move_toward(steering, Input.get_axis("Right", "Left") * MAX_STEER, delta * 2.5)
	engine_force = Input.get_axis("Back", "Forward") * ENGINE_POWER
