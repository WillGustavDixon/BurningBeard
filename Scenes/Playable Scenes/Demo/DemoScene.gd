extends Node

@onready var invScene = $InventoryScene
@onready var pauseScene = $PauseOverlay

@export var invOpen : bool
@export var pausing : bool

func _ready():
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	invScene.visible = false
	pauseScene.visible = false
	invOpen = false
	pausing = false
	
func _process(delta):
	if Input.is_action_just_pressed("Inventory") && !pausing: 
		if !invOpen:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			invScene.visible = true
			get_tree().paused = true
			invOpen = true
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			invScene.visible = false
			get_tree().paused = false
			invOpen = false
	
	if Input.is_action_just_pressed("Pause") && !invOpen: 
		if !pausing:
			invScene.process_mode = Node.PROCESS_MODE_PAUSABLE
			pauseScene.visible = true
			get_tree().paused = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			pausing = true
		else:
			pauseScene.visible = false
			get_tree().paused = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			invScene.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
			pausing = false
		
