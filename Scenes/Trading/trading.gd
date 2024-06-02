extends Control

@onready var slotScene = preload("res://Scenes/Inventory/Slot/slot_icon.tscn")
@onready var gridScene = preload("res://Scenes/Inventory/inventory_grid.tscn")
@onready var itemScene = preload("res://Scenes/Inventory/Item/item.tscn")
@onready var itemInfoScene = preload("res://Scenes/Inventory/Item/item_info.tscn")

@onready var playerGridAnchorPath = $Background/PlayerGridAnchor
@onready var npcGridAnchorPath = $Background/NPCGridAnchor
@onready var playerGoldText = $Background/Text/PlayerGold
@onready var npcGoldText = $Background/Text/NPCGold
@onready var playerTradesText = $Background/Text/PlayerTrades
@onready var npcTradesText = $Background/Text/NPCTrades
@onready var playerTotalText = $Background/Text/PlayerTotal
@onready var npcTotalText = $Background/Text/NPCTotal

var root 
var invScene
var itemHider

var playerGrid
var playerColCount : int
var playerSlotCount
var playerGridArray := []
var playerInv := []
var playerInvEmpty
var playerGold : int
var playerTrades := []
var playerTradesStr := ""
var playerVal : int

var npc
var npcGrid
var npcColCount : int
var npcSlotCount
var npcGridArray := []
var npcInv := []
var npcInvEmpty
var npcGold : int
var npcTrades := []
var npcTradesStr := ""
var npcVal : int

var trading
var heldItem = null
var curSlot = null
var itemInfo = null
var canPlace = false
var itemAnchor : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	trading = false
	root = get_tree().get_nodes_in_group("Root")[0]
	invScene = root.find_child("UIInventory", true)
	itemHider = root.find_child("ItemHider", false)
	playerGrid = gridScene.instantiate()
	playerGrid.add_to_group("PlayerGrid")
	playerGridAnchorPath.add_child(playerGrid)
	
	playerGold = invScene.gold
	playerColCount = invScene.colCount
	playerSlotCount = invScene.slotCount
	drawGrid(playerGrid, playerGridArray, playerColCount, playerSlotCount)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if trading:
		if curSlot:
			pass
		if heldItem: ## if an item is being held, allow rotation or placement
			if Input.is_action_just_pressed("mouseScrollDown"):
				rotateItem(heldItem, 1)
			if Input.is_action_just_pressed("mouseScrollUp"):
				rotateItem(heldItem, -1)
			
			if Input.is_action_just_pressed("mouseLeftClick") && \
			curSlot.get_parent() == playerGrid:
				placeItem(true, playerGrid, playerGridArray, heldItem.itemSrc)
		else: ##  if not
			if is_instance_valid(itemInfo): ## if the item info window exists
				if Input.is_action_just_pressed("mouseRightClick") || \
				Input.is_action_just_pressed("mouseLeftClick")     || \
				(curSlot.storedItem != itemInfo.itemReading):
					itemInfo.queue_free()
				## when lmb/rmb is pressed or the mouse isn't over the item, delete the window
			
			else: ## otherwise, allow picking up and item info viewing
				if Input.is_action_just_pressed("mouseLeftClick") && \
				curSlot && curSlot.get_parent() == playerGrid:
					pickUpItem()
				
				if Input.is_action_just_pressed("mouseRightClick"):
					createItemInfo()
					
				if Input.is_action_just_pressed("Mark"):
					markItem(curSlot)
					
				if Input.is_action_just_pressed("Trade"):
					tradeItems()
		checkMarked()
		playerGoldText.text = "Gold: " + str(playerGold)
		npcGoldText.text = "Gold: " + str(npcGold)
		playerTradesText.text = playerTradesStr
		npcTradesText.text = npcTradesStr
		playerTotalText.text = "Total: " + str(playerVal)
		npcTotalText.text = "Total: " + str(npcVal)

func tradeOpened():
	trading = true
	playerInv = invScene.inventory
	playerInvEmpty = invScene.invEmpty
	playerGold = invScene.gold
	
	if !playerInvEmpty:
		for item in playerInv:
			heldItem = item
			curSlot = heldItem.primeSlot
			canPlace = true
			itemAnchor = Vector2.ONE
			setSlots(curSlot, heldItem.itemGridSizes, playerGrid, playerGridArray)
			placeItem(false, playerGrid, playerGridArray)
		clearGrid(playerGridArray)
	
	if !npcInvEmpty:
		for item in npcInv:
			item.primeSlot = npcGridArray[item.primeSlotID]
			heldItem = item
			curSlot = heldItem.primeSlot
			canPlace = true
			itemAnchor = Vector2.ONE
			setSlots(curSlot, heldItem.itemGridSizes, npcGrid, npcGridArray)
			placeItem(false, npcGrid, npcGridArray)
		clearGrid(npcGridArray)

func tradeClosed():
	trading = false
	if is_instance_valid(playerGrid):
		for child in playerGrid.get_children():
			if child.is_in_group("Item"):
				playerGrid.remove_child(child)
				itemHider.add_child(child)
			else:
				child.storedItem = null
				child.curState = child.slotStates.idle
	invScene.gold = playerGold
	
	if is_instance_valid(npcGrid):
		for child in npcGrid.get_children():
			if child.is_in_group("Item"):
				npcGrid.remove_child(child)
				itemHider.add_child(child)
			else: child.queue_free()
		npcGrid.queue_free()
		npcGridArray = []
		npc.inventory = npcInv.duplicate()
	npc.gold = npcGold

func getNPCGrid(src):
	if is_instance_valid(npcGrid):
		npcGrid.queue_free()
	npcGrid = gridScene.instantiate()
	npcGrid.add_to_group("NPCGrid")
	npcGridAnchorPath.add_child(npcGrid)
	
	npc = src
	npcGold = src.gold
	npcColCount = src.gridCols
	npcSlotCount = src.gridSlots
	npcInv = src.inventory.duplicate()
	npcInvEmpty = src.invEmpty
	drawGrid(npcGrid, npcGridArray, npcColCount, npcSlotCount)

# runs when a spawner button is pressed, gets the ID from the button
func createItem(id, src:Node = null) -> Node2D:
	var newItem = itemScene.instantiate()
	add_child(newItem)
	newItem.loadItem(id, src)
	newItem.selected = true
	playerInv.push_back(newItem)
	return newItem

# rotates the item in a specific direction, then makes sure the grid reflects changes
func rotateItem(item, dir):
	item.rotateItem(dir)
	clearGrid(playerGridArray)
	if curSlot:
		slotMouseEntered(curSlot)

# checks if the item is placeable, and if so places it in its desired position on the grid
func placeItem(doAnim, grid, gridArray, src:Node = null):
	if not canPlace || not curSlot:
		return
	heldItem.primeSlot = curSlot
	heldItem.get_parent().remove_child(heldItem)
	grid.add_child(heldItem)
	heldItem.global_position = get_global_mouse_position()
	heldItem.gridAnchor = curSlot
	
	for slot in heldItem.itemGridSizes:
		var checkingCol = curSlot.ID + slot[0] + slot[1] * grid.columns
		gridArray[checkingCol].curState = gridArray[checkingCol].slotStates.occupied
		gridArray[checkingCol].storedItem = heldItem
		
	if src != null:
		src.itemReceived()
		heldItem.itemSrc = null
		
	var gridPlacePos = curSlot.ID + itemAnchor.x * grid.columns + itemAnchor.y
	heldItem.place(gridArray[gridPlacePos].global_position, doAnim)
	heldItem = null
	clearGrid(gridArray)

# lets an item be picked up if moused over
func pickUpItem():
	if not curSlot || not curSlot.storedItem || \
	not curSlot.get_global_rect().has_point((get_global_mouse_position())):
		return	## checks if there is a current slot, if its moused over, and if the item is in it
		
	heldItem = curSlot.storedItem
	heldItem.selected = true
	heldItem.get_parent().remove_child(heldItem)
	$Background.add_child(heldItem) ## removes the item as a child of the slot & sets it as a child of the inventory
	heldItem.global_position = get_global_mouse_position()
	
	for slot in heldItem.itemGridSizes:
		var checkingCol = heldItem.gridAnchor.ID + slot[0] + slot[1] * playerColCount
		playerGridArray[checkingCol].curState = playerGridArray[checkingCol].slotStates.free
		playerGridArray[checkingCol].storedItem = null
	checkSlot(curSlot, heldItem, playerGrid, playerGridArray)
	setSlots.call_deferred(curSlot, heldItem.itemGridSizes, playerGrid, playerGridArray)

func createItemInfo():
	## checks if there is a current slot, if its moused over, and if the item is in it
	if curSlot && curSlot.get_global_rect().has_point((get_global_mouse_position())) && curSlot.storedItem:
		itemInfo = itemInfoScene.instantiate()
		add_child(itemInfo)
		itemInfo.editText(curSlot.storedItem)

func drawGrid(grid, arr, cols, slots):
	grid.draw(arr, cols, slots, self)

func createSlot(grid, gridArray):
	var newSlot = slotScene.instantiate()
	newSlot.ID = gridArray.size() ## IDs go in order of creation horizontally
	grid.add_child(newSlot)
	gridArray.push_back(newSlot) ## puts it at the end of the grid array
	newSlot.slotEntered.connect(slotMouseEntered) ## connects the signals with
	newSlot.slotExited.connect(slotMouseExited) ## corresponding functions here

# clears all the colour changes from the grid
func clearGrid(gridArray):
	for slot in gridArray:
		if slot.curState != slot.slotStates.marked:
			slot.setColour(slot.slotStates.idle)

# runs when a slot detects its being moused over
func slotMouseEntered(slot):
	itemAnchor = Vector2.ONE
	curSlot = slot
	var grid = curSlot.get_parent()
	var gridArr = playerGridArray if playerGridArray.has(curSlot) else npcGridArray
	if heldItem:
		checkSlot(curSlot, heldItem, grid, gridArr)
		setSlots.call_deferred(curSlot, heldItem.itemGridSizes, grid, gridArr)
	
# runs when a slot detects there is no mouse on it anymore
func slotMouseExited(slot):
	var gridArray = []
	if playerGridArray.find(slot) != -1:
		gridArray = playerGridArray
	else: gridArray = npcGridArray
	clearGrid(gridArray) ## godot doesn't like the slot var but its necessary i swear

# checks the slot currently on to see if an item can be placed there
func checkSlot(slot, item, grid, gridArray):
	for g in item.itemGridSizes:
		var checkingCol = slot.ID + g[0] + g[1] * grid.columns
		var lineLenCheck = slot.ID % grid.columns + g[0]
		if lineLenCheck < 0 || lineLenCheck >= grid.columns:
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
func setSlots(slot, itemSlots, g, gridArray, marking = false):
	for grid in itemSlots:
		var checkingCol = slot.ID + grid[0] + grid[1] * g.columns
		var lineLenCheck = slot.ID % g.columns + grid[0]
		if checkingCol < 0 || checkingCol >= gridArray.size():
			continue
		if lineLenCheck < 0 || lineLenCheck >= g.columns:
			continue
		if !marking:	
			if canPlace:
				gridArray[checkingCol].setColour(gridArray[checkingCol].slotStates.free)
				if grid[0] < itemAnchor.y: itemAnchor.y = grid[0]
				if grid[1] < itemAnchor.x: itemAnchor.x = grid[1]
			else:
				gridArray[checkingCol].setColour(gridArray[checkingCol].slotStates.occupied)
		else:
			gridArray[checkingCol].setColour(gridArray[checkingCol].slotStates.marked)

## input a slot and an item, return all the slots that the item would take up
func getSlots(slot, item, g, gridArray) -> Array:
	var slots = []
	for grid in item.itemGridSizes:
		var checkingCol = slot.ID + grid[0] + grid[1] * g.columns
		var lineLenCheck = slot.ID % g.columns + grid[0]
		if checkingCol < 0 || checkingCol >= gridArray.size():
			continue
		if lineLenCheck < 0 || lineLenCheck >= g.columns:
			continue
		if gridArray[checkingCol].curState == gridArray[checkingCol].slotStates.occupied:
			continue
		slots.push_back(checkingCol)
	return slots

func markItem(slot):
	if !slot || !slot.storedItem || \
	!slot.get_global_rect().has_point((get_global_mouse_position())):
		return
	var markedItem = slot.storedItem
	if playerInv.has(markedItem):
		if !markedItem.marked && playerTrades.size() < 5:
			markedItem.marked = true
			playerTrades.push_back(markedItem)
			playerVal += markedItem.value
		else:
			markedItem.marked = false
			playerTrades.erase(markedItem)
			playerVal -= markedItem.value
	else: 
		if !markedItem.marked && npcTrades.size() < 5:
			markedItem.marked = true
			npcTrades.push_back(markedItem)
			npcVal += markedItem.value
		else:
			markedItem.marked = false
			npcTrades.erase(markedItem)
			npcVal -= markedItem.value
	getTradeStrs()

func getTradeStrs():
	playerTradesStr = ""
	for item in playerTrades:
		playerTradesStr += item.itemName + "\n\n"
	npcTradesStr = ""
	for item in npcTrades:
		npcTradesStr += item.itemName + "\n\n"

func checkMarked():
	for item in playerInv:
		if item.marked && item != heldItem:
			setSlots(item.primeSlot, item.itemGridSizes, \
			playerGrid, playerGridArray, true)
	for item in npcInv:
		if item.marked:
			setSlots(item.primeSlot, item.itemGridSizes, \
			npcGrid, npcGridArray, true)

func tradeItems():
	# check if items can fit in opposite inventory + add up their values
	var nOccupied = []
	var canTrade = true
	var found = false
	
	for item in playerTrades:
		found = false
		for s in npcGridArray:
			if s.curState == s.slotStates.occupied: nOccupied.push_back(s)
			if nOccupied.has(s): continue # skip this slot
			var slots = getSlots(s, item, npcGrid, npcGridArray)
			if slots.size() == item.itemGridSizes.size():
				found = true
				for slot in slots:
					nOccupied.push_back(npcGridArray[slot])
				break
		if !found: canTrade = false; break
	if !canTrade: return
	
	var pOccupied = []
		
	for item in npcTrades:
		found = false
		for s in playerGridArray:
			if s.curState == s.slotStates.occupied: pOccupied.push_back(s)
			if pOccupied.has(s): continue
			var slots = getSlots(s, item, playerGrid, playerGridArray)
			if slots.size() == item.itemGridSizes.size():
				found = true
				for slot in slots:
					pOccupied.push_back(playerGridArray[slot])
				break
		if !found: canTrade = false; break
	if !canTrade: return
	
	# check value of all goods in both inventories
	# whichever has the highest value keeps money
	# the lower value one gives enough money to offset the item cost
	
	if playerVal > npcVal:
		if npcGold < playerVal:
			print("NPC is too poor")
			return
		else: npcGold -= playerVal; playerGold += playerVal;
	elif playerVal < npcVal:
		if playerGold < npcVal:
			print("Player is too poor")
			return
		else: playerGold -= npcVal; npcGold += npcVal;
	
	# remove the trading items from each inventory and put them in the opposite inventory
	# remove them from their grids and add them to the other grid
	for item in playerTrades:
		item.marked = false
		for slot in playerGridArray:
			if slot.storedItem == item:
				slot.storedItem = null
				slot.curState = slot.slotStates.idle
		playerInv.erase(item)
		npcInv.push_back(item)
		playerGrid.remove_child(item)
		itemHider.add_child(item)
		
	
	for item in npcTrades:
		item.marked = false
		for slot in npcGridArray:
			if slot.storedItem == item:
				slot.storedItem = null
				slot.curState = slot.slotStates.idle
		npcInv.erase(item)
		playerInv.push_back(item)
		npcGrid.remove_child(item)
		itemHider.add_child(item)
	
	clearGrid(playerGridArray)
	clearGrid(npcGridArray)
	
	for item in playerTrades:
		heldItem = item
		var slot = null
		for s in npcGridArray:
			checkSlot(s, heldItem, npcGrid, npcGridArray)
			if canPlace:
				slot = s
				break
		heldItem.primeSlotID = slot.ID
		heldItem.primeSlot = slot
		curSlot = heldItem.primeSlot
		canPlace = true
		itemAnchor = Vector2.ONE
		setSlots(curSlot, heldItem.itemGridSizes, npcGrid, npcGridArray)
		placeItem(false, npcGrid, npcGridArray)
	playerTrades.clear()
	
	for item in npcTrades:
		heldItem = item
		var slot = null
		for s in playerGridArray:
			checkSlot(s, heldItem, playerGrid, playerGridArray)
			if canPlace:
				slot = s
				break
		heldItem.primeSlotID = slot.ID
		heldItem.primeSlot = slot
		curSlot = heldItem.primeSlot
		canPlace = true
		itemAnchor = Vector2.ONE
		setSlots(curSlot, heldItem.itemGridSizes, playerGrid, playerGridArray)
		placeItem(false, playerGrid, playerGridArray)
	npcTrades.clear()
	clearGrid(playerGridArray)
	clearGrid(npcGridArray)
	playerTradesStr = ""
	npcTradesStr = ""
	playerVal = 0
	npcVal = 0
