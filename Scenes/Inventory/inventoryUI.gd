extends Control

@onready var slotScene = preload("res://Scenes/Inventory/Slot/slot_icon.tscn")
@onready var gridContainer := $Background/MarginContainer/VBoxContainer/GridContainer
@onready var itemScene = preload("res://Scenes/Inventory/Item/item.tscn")
@onready var itemInfoScene = preload("res://Scenes/Inventory/Item/item_info.tscn")

@export var colCount : int
@export var slotCount : int
@export var invEmpty : bool
@export var money : int

var inventory := []
var inventoryData := {}
var gridArray := []
var heldItem = null
var curSlot = null
var itemInfo = null
var canPlace = false
var itemAnchor : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	drawGrid()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if inventory.size() == 0:
		invEmpty = true
	else:
		invEmpty = false
	if curSlot:
		pass
	if heldItem: ## if an item is being held, allow rotation or placement
		if Input.is_action_just_pressed("mouseScrollDown"):
			rotateItem(heldItem, 1)
		if Input.is_action_just_pressed("mouseScrollUp"):
			rotateItem(heldItem, -1)
		
		if Input.is_action_just_pressed("mouseLeftClick"):
			placeItem(true, heldItem.itemSrc)
	else: ##  if not
		if is_instance_valid(itemInfo): ## if the item info window exists
			if Input.is_action_just_pressed("mouseRightClick") || \
			Input.is_action_just_pressed("mouseLeftClick")     || \
			(curSlot.storedItem != itemInfo.itemReading): #|| \
			#not curSlot.storedItem.itemIconPath.get_global_rect().has_point((get_global_mouse_position()))):
				itemInfo.queue_free()
			## when lmb/rmb is pressed or the mouse isn't over the item, delete the window
		
		else: ## otherwise, allow picking up and item info viewing
			if Input.is_action_just_pressed("mouseLeftClick"):
				pickUpItem()
			
			if Input.is_action_just_pressed("mouseRightClick"):
				createItemInfo()

func invClosed():
	if heldItem:
		if heldItem.primeSlot: ##if it has been placed before
			curSlot = heldItem.primeSlot
			placeItem(false)
		else:
			heldItem.queue_free()
			heldItem = null
			clearGrid()
	curSlot = null

func saveInv():
	var saveDict = {
		"Settings": {
			"Columns": colCount,
			"Size": slotCount,
			"Gold": money,
			"Empty": invEmpty
			},
		"Slots": {}
	}
	var slotDict = {}
	for item in inventory:
		var slotKey = str(item.primeSlot.ID)
		var slotVal = [item.ID, item.rotation_degrees]
		slotDict[slotKey] = slotVal
	saveDict["Slots"] = slotDict
	print(saveDict)
	DataHandling.saveInvData(DataHandling.invPath, saveDict)

func loadInv():
	inventoryData = DataHandling.invData
	invEmpty = inventoryData["Settings"]["Empty"]
	money = inventoryData["Settings"]["Gold"]
	if(!invEmpty):
		print(inventoryData)
		for slot in inventoryData["Slots"]:
			var newItem = createItem(inventoryData["Slots"][slot][0])
			for n in range(0, inventoryData["Slots"][slot][1] / 90): # 0 if 0, 1 if 90, 2 if 180, 3 if 270
				rotateItem(newItem, 1)
			newItem.primeSlot = gridArray[int(slot)]
			newItem.selected = false
		for item in inventory:
			heldItem = item
			curSlot = heldItem.primeSlot
			canPlace = true
			itemAnchor = Vector2.ONE
			setGrids(curSlot)
			placeItem(false)
		clearGrid()

func clearInv():
	for item in inventory:
		if is_instance_valid(item) == true:
			item.free()
		item = null
	inventory = []
	clearGrid()
	if heldItem:
		pass#heldItem.free()
	heldItem = null
	for slot in gridContainer.get_children():
		gridContainer.remove_child(slot)
		slot.free()
	gridArray = []
	drawGrid()

# runs when a spawner button is pressed, gets the ID from the button
func createItem(id, src:Node = null) -> Node2D:
	var newItem = itemScene.instantiate()
	add_child(newItem)
	newItem.loadItem(id, src)
	newItem.selected = true
	inventory.push_back(newItem)
	return newItem

# rotates the item in a specific direction, then makes sure the grid reflects changes
func rotateItem(item, dir):
	item.rotateItem(dir)
	clearGrid()
	if curSlot:
		slotMouseEntered(curSlot)

# checks if the item is placeable, and if so places it in its desired position on the grid
func placeItem(doAnim, src:Node = null):
	if not canPlace || not curSlot:
		return
	
	heldItem.primeSlot = curSlot
	heldItem.get_parent().remove_child(heldItem)
	gridContainer.add_child(heldItem)
	heldItem.global_position = get_global_mouse_position()
	heldItem.gridAnchor = curSlot
	
	for slot in heldItem.itemGridSizes:
		var checkingCol = curSlot.ID + slot[0] + slot[1] * colCount
		gridArray[checkingCol].curState = gridArray[checkingCol].slotStates.occupied
		gridArray[checkingCol].storedItem = heldItem
		
	if src != null:
		src.itemReceived()
		heldItem.itemSrc = null
		
	var gridPlacePos = curSlot.ID + itemAnchor.x * colCount + itemAnchor.y
	heldItem.place(gridArray[gridPlacePos].global_position, doAnim)
	heldItem = null
	clearGrid()

# lets an item be picked up if moused over
func pickUpItem():
	if not curSlot || not curSlot.storedItem || \
	not curSlot.get_global_rect().has_point((get_global_mouse_position())):
		return	## checks if there is a current slot, if its moused over, and if the item is in it
		
	heldItem = curSlot.storedItem
	heldItem.selected = true
	heldItem.get_parent().remove_child(heldItem)
	add_child(heldItem) ## removes the item as a child of the slot & sets it as a child of the inventory
	heldItem.global_position = get_global_mouse_position()
	
	for slot in heldItem.itemGridSizes:
		var checkingCol = heldItem.gridAnchor.ID + slot[0] + slot[1] * colCount
		gridArray[checkingCol].curState = gridArray[checkingCol].slotStates.free
		gridArray[checkingCol].storedItem = null
	checkSlot(curSlot)
	setGrids.call_deferred(curSlot)

func createItemInfo():
	## checks if there is a current slot, if its moused over, and if the item is in it
	if curSlot && curSlot.get_global_rect().has_point((get_global_mouse_position())) && curSlot.storedItem:
		itemInfo = itemInfoScene.instantiate()
		add_child(itemInfo)
		itemInfo.editText(curSlot.storedItem)

# instantiates a new slot in the inventory scene, ideally on startup
func createSlot():
	var newSlot = slotScene.instantiate()
	newSlot.ID = gridArray.size() ## IDs go in order of creation horizontally
	gridContainer.add_child(newSlot)
	gridArray.push_back(newSlot) ## puts it at the end of the grid array
	newSlot.slotEntered.connect(slotMouseEntered) ## connects the signals with
	newSlot.slotExited.connect(slotMouseExited) ## corresponding functions here

func drawGrid():
	slotCount = DataHandling.invData["Settings"]["Size"]
	colCount = DataHandling.invData["Settings"]["Columns"]
	gridContainer.columns = colCount
	invEmpty = DataHandling.invData["Settings"]["Empty"]
	for i in range(slotCount):
		createSlot()

# clears all the colour changes from the grid
func clearGrid():
	for grid in gridArray:
		grid.setColour(grid.slotStates.idle)

# runs when a slot detects its being moused over
func slotMouseEntered(slot):
	itemAnchor = Vector2.ONE
	curSlot = slot
	if heldItem:
		checkSlot(curSlot)
		setGrids.call_deferred(curSlot)
	
# runs when a slot detects there is no mouse on it anymore
func slotMouseExited(slot):
	clearGrid() ## godot doesn't like the slot var but its necessary i swear

# checks the slot currently on to see if an item can be placed there
func checkSlot(slot):
	for grid in heldItem.itemGridSizes:
		var checkingCol = slot.ID + grid[0] + grid[1] * colCount
		var lineLenCheck = slot.ID % colCount + grid[0]
		if lineLenCheck < 0 || lineLenCheck >= colCount:
			canPlace = false
			return
		if checkingCol < 0 || checkingCol >= gridArray.size():
			canPlace = false
			return
		if gridArray[checkingCol].curState == gridArray[checkingCol].slotStates.occupied:
			canPlace = false
			return
		canPlace = true
	
# sets the colour of the slots below where the item is being held over
func setGrids(slot):
	for grid in heldItem.itemGridSizes:
		var checkingCol = slot.ID + grid[0] + grid[1] * colCount
		var lineLenCheck = slot.ID % colCount + grid[0]
		if checkingCol < 0 || checkingCol >= gridArray.size():
			continue
		if lineLenCheck < 0 || lineLenCheck >= colCount:
			continue
		if canPlace:
			gridArray[checkingCol].setColour(gridArray[checkingCol].slotStates.free)
			if grid[0] < itemAnchor.y: itemAnchor.y = grid[0]
			if grid[1] < itemAnchor.x: itemAnchor.x = grid[1]
		else:
			gridArray[checkingCol].setColour(gridArray[checkingCol].slotStates.occupied)
