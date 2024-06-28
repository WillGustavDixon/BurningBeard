extends Camera3D

# FOLLOW PLAYER
@export_category("Follow this node")
@onready var camera_point: Node3D = get_node("../CameraTarget") # THE CAMERA WILL FOLLOW THIS NODE
@export_category("Wait Time")
@export var wait_time : float  # How long for the camera to start following the node, can leave it at 0 too
const base_camera_speed = 20  # How fast the camera will reach its destination
var follow := true

# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_top_level(true)  # Prevents the camera from being glued to the player (won't follow on its own)
	follow = true

func _process(delta):
	if follow:
		follow_player(delta)
	look_at(get_parent().get_parent().global_position)

func follow_player(delta):
	# Update target position with camera_point's current position
	var point_position = camera_point.global_position
	# Target position (replace "target" with your target object)
	var target_position = point_position

	# Calculate direction towards the target
	var direction = target_position - self.global_position

	# Distance between Target and Current Camera
	var camera_difference = point_position.distance_to(self.global_position)
	print("Camera Difference: %d" % camera_difference)

	var camera_speed = base_camera_speed
	if camera_difference > 10:
		camera_speed = 50
	else:
		camera_speed = base_camera_speed
	print("Camera Speed: %d" % camera_speed)

	# Calculate desired change in origin (speed adjustment)
	var desired_change = direction * camera_speed * delta

	# Use lerp for smooth transition
	var smoothed_change = lerp(self.transform.origin, self.transform.origin + desired_change, 0.1)

	# Update origin with smoothing
	self.transform.origin = smoothed_change
