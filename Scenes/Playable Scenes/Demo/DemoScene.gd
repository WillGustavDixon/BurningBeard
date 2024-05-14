extends Node

@onready var invScene = $InventoryScene
@onready var inv = invScene.get_child(0)
@onready var pauseScene = $PauseOverlay
#@onready var tradeScene = $TradingScene
@onready var fader = $Fader
@onready var cart = $MainScene/Cart

@export var invOpen : bool
@export var pausing : bool

func _ready():
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	invScene.visible = false
	pauseScene.visible = false
	fader.hold()
	invOpen = false
	pausing = false
	cart.hasDied.connect(onDeath)
	cart.hasRespawned.connect(onRespawned)
	fader.get_child(0).animation_finished.connect(animPlayed)
	
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
			
	if Input.is_action_just_pressed("Save") && invOpen:
		print("Saving!")
		inv.saveInv()
	if Input.is_action_just_pressed("Load") && invOpen:
		print("Loading!")
		DataHandling.loadInvData(DataHandling.invPath)
		inv.clearInv()
		inv.loadInv.call_deferred() # call is deferred so that the inventory has time to refresh

func openInv(id, src : Node = null):
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	invScene.visible = true
	invOpen = true
	if id != "00":
		inv.heldItem = inv.createItem(id, src)

func closeInv():
	invScene.visible = false
	inv.invClosed()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	invOpen = false

func openTrade(src : Node = null):
	pass#tradeScene.visible = true
	#tradeScene

func closeTrade():
	pass

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

func onDeath():
	fader.fadeOut()
	
func onRespawned():
	fader.hold()
	
func animPlayed(animName):
	match animName:
		"fadeOut":
			cart.thawCam()
			cart.respawn()
		"hold":
			fader.fadeIn()
		"fadeIn":
			fader.visible = false
