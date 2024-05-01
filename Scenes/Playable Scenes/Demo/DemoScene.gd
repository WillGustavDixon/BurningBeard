extends Node

@onready var invScene = $InventoryScene
@onready var inv = invScene.get_child(0)
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
			openInv("00")
		else:
			closeInv()
	
	if Input.is_action_just_pressed("Pause") && !invOpen: 
		if !pausing:
			pause()
		else:
			unpause()

func openInv(id, src : Node = null):
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	inv.updateInv()
	invScene.visible = true
	invOpen = true
	if id != "00":
		inv.createItem(id, src)

func closeInv():
	invScene.visible = false
	inv.invClosed()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	invOpen = false

func pause():
	invScene.process_mode = Node.PROCESS_MODE_PAUSABLE
	pauseScene.visible = true
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pausing = true

func unpause():
	pauseScene.visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	invScene.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	pausing = false
