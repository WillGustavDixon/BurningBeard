extends Control

@onready var slotScene = preload("res://Scenes/slot_icon.tscn")
@onready var gridContainer := $Background/MarginContainer/VBoxContainer/GridContainer
@onready var itemScene = preload("res://Scenes/item.tscn")
@onready var itemInfoScene = preload("res://Scenes/item_info.tscn")
@onready var colCount = gridContainer.columns

var gridArray := []
var slotCount := 30
var heldItem = null
var curSlot = null
var itemInfo = null
var canPlace = false
var itemAnchor : Vector2


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(slotCount): 
		createSlot()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if curSlot:
		#print(curSlot.ID, ", ", curSlot.isHovering,  ", ", curSlot.get_global_rect().has_point((get_global_mouse_position())))
		pass
	if heldItem: ## if an item is being held, allow rotation or placement
		if Input.is_action_just_pressed("mouseScrollDown"):
			rotateItem(1)
		if Input.is_action_just_pressed("mouseScrollUp"):
			rotateItem(-1)
		
		if Input.is_action_just_pressed("mouseLeftClick"):
			placeItem()
	else: ##  if not
		if is_instance_valid(itemInfo): ## if the item info window exists
			if Input.is_action_just_pressed("mouseRightClick") || \
			 Input.is_action_just_pressed("mouseLeftClick")     || \
			not curSlot.storedItem.itemIconPath || \
			not curSlot.storedItem.itemIconPath.get_global_rect().has_point((get_global_mouse_position())):
				itemInfo.queue_free() 
			## when lmb/rmb is pressed or the mouse isn't over the item, delete the window
		
		else: ## otherwise, allow picking up and item info viewing
			if Input.is_action_just_pressed("mouseLeftClick"):
				pickUpItem()
			
			if Input.is_action_just_pressed("mouseRightClick"):
				createItemInfo()

# instantiates a new slot in the inventory scene, ideally on startup
func createSlot(): 
	var newSlot = slotScene.instantiate() 
	newSlot.ID = gridArray.size() ## IDs go in order of creation horizontally 
	gridContainer.add_child(newSlot) 
	gridArray.push_back(newSlot) ## puts it at the end of the grid array
	newSlot.slotEntered.connect(slotMouseEntered) ## connects the signals with
	newSlot.slotExited.connect(slotMouseExited) ## corresponding functions here
	
# runs when a slot detects its being moused over
func slotMouseEntered(slot):
	itemAnchor = Vector2(10000, 10000)
	curSlot = slot
	if heldItem:
		checkSlot(curSlot)
		setGrids.call_deferred(curSlot)
	
# runs when a slot detects there is no mouse on it anymore
func slotMouseExited(slot): 
	clearGrid() ## godot doesn't like the slot var but its necessary i swear

# runs when a spawner button is pressed, gets the ID from the button
func itemSpawnerPressed(id):
	var newItem = itemScene.instantiate()
	add_child(newItem)
	newItem.loadItem(id)
	newItem.selected = true
	heldItem = newItem
	
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
		
# clears all the colour changes from the grid
func clearGrid():
	for grid in gridArray:
		grid.setColour(grid.slotStates.idle)
		
# rotates the item in a specific direction, then makes sure the grid reflects changes
func rotateItem(dir):
	heldItem.rotateItem(dir)
	clearGrid()
	if curSlot:
		slotMouseEntered(curSlot)
		
# checks if the item is placeable, and if so places it in its desired position on the grid
func placeItem():
	if not canPlace || not curSlot:
		return
	var gridPlacePos = curSlot.ID + itemAnchor.x * colCount + itemAnchor.y
	heldItem.snapToPos(gridArray[gridPlacePos].global_position)
	
	heldItem.get_parent().remove_child(heldItem)
	gridContainer.add_child(heldItem)
	heldItem.global_position = get_global_mouse_position()
	
	heldItem.gridAnchor = curSlot
	for slot in heldItem.itemGridSizes:
		var checkingCol = curSlot.ID + slot[0] + slot[1] * colCount
		gridArray[checkingCol].curState = gridArray[checkingCol].slotStates.occupied
		gridArray[checkingCol].storedItem = heldItem
	heldItem = null
	clearGrid()
	
# lets an item be picked up if moused over
func pickUpItem():
	if not curSlot || \
	not curSlot.get_global_rect().has_point((get_global_mouse_position())) || \
	not curSlot.storedItem:
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
