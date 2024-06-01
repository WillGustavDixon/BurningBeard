extends Camera3D
#FOLLOW PLAYER
@onready var Target: Node3D = get_node("../CameraTarget")   #THE CAMERA WILL FOLLOW THIS NODE
@onready var CameraRayCast: Node3D = get_node("../CameraRayCast")
@onready var Camera: Node3D = get_node("../Camera3D")
@onready var RearCamera: Node3D = get_node("../Rear_View_Camera")
@export var wait_time : float   #How long for the camera to start following the node, can leave it at 0 too
var point_position : Vector3    #The global position of the node we want the camera to follow
var speed := 5    #How fast the camera will reach its destination
var follow := true
 
# Called when the node enters the scene tree for the first time.
func _ready():
	set_as_top_level(true)   #Prevents the camera from being glued to the player (won't follow on its own)
	point_position = Target.global_position
	follow = true

func _process(delta):
	if follow:
		follow_player(delta)
	look_at(get_parent().get_parent().global_position)
 
func follow_player(delta):
	var direction = self.global_position - Target.global_position     #Where we want to move
	var point_current_position = point_position
	var point_last_position = Target.global_position
	#If the camera detects its point has moved, it will follow it after the wait time
	if point_last_position != point_current_position:
		await get_tree().create_timer(wait_time).timeout
		self.transform.origin -= direction * speed * delta
