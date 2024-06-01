extends Node

@onready var invScene = $InventoryScene
@onready var inv = invScene.get_child(0)
@onready var pauseScene = $PauseOverlay
@onready var tradeScene = $TradingScene
@onready var trade = tradeScene.get_child(0)
@onready var driveHUD = $DrivingHUD
@onready var shopHUD = $ShopHUD
@onready var fader = $Fader
@onready var cart = $MainScene/Cart
@onready var itemHider = $ItemHider

@export var invOpen : bool
@export var tradeOpen : bool
@export var shopOpen : bool
@export var pausing : bool
@export var curMode := modes.drive
enum modes {drive, shop}


func _ready():
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	invScene.visible = false
	tradeScene.visible = false
	pauseScene.visible = false
	shopHUD.visible = false
	driveHUD.visible = true
	itemHider.visible = false
	fader.hold()
	invOpen = false
	tradeOpen = false
	pausing = false
	
	cart.hasDied.connect(onDeath)
	cart.hasRespawned.connect(onRespawned)
	fader.get_child(0).animation_finished.connect(animPlayed)
	
func _process(delta):
	match curMode:
		modes.drive:
			if Input.is_action_just_pressed("Inventory") && !pausing && !tradeOpen: 
				if !invOpen:
					openInv("00")
				else:
					closeInv()
			
			if Input.is_action_just_pressed("Pause"):
				if tradeOpen:
					closeTrade()
				elif invOpen:
					closeInv()
				else:
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
		
		modes.shop:
			pass

func openInv(id, src : Node = null):
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	inv.invOpened()
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

func openTrade(npc):
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	tradeScene.visible = true
	tradeOpen = true
	trade.getNPCGrid(npc)
	trade.tradeOpened.call_deferred()

func closeTrade():
	tradeScene.visible = false
	trade.tradeClosed()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	get_tree().paused = false
	tradeOpen = false

func startShop(shop, reqs):
	for req in reqs:
		var count = 0
		for item in inv.inventory:
			if item.ID == req && count < reqs[req]:
				inv.inventory.erase(item)
				count += 1
	
	curMode = modes.shop
	shop.visible = true
	cart.set_process(false)
	shop.shopCam.set_current(true)
	shop.beginService()

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
