extends Node2D

@onready var itemIconPath = $ItemIcon

var ID
var itemName: String
var value: int
var rarity: int

var itemGridSizes := []
var selected = false
var gridAnchor = null


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if selected: ## if the item has been selected, follow the mouse cursor
		global_position = lerp(global_position, get_global_mouse_position(), 25 * delta)

# loads the item texture & its size data 
func loadItem(itemID):
	ID = itemID
	itemName = DataHandling.itemData[itemID]["Item Name"]
	value = DataHandling.itemData[itemID]["Item Value"]
	rarity = DataHandling.itemData[itemID]["Item Rarity"]
	print(itemName, ", ", value, ", ", rarity)
	var iconPath = "res://Assets/" + DataHandling.itemData[itemID]["Item Name"] + "Icon.png"
	itemIconPath.texture = load(iconPath) ## load item texture from the assets folder
	for grid in DataHandling.inventoryData[itemID]:
		var tempArray := [] 
		for i in grid:  ## this all basically adds the info for how much space this item takes up
			tempArray.push_back(int(i))
		itemGridSizes.push_back(tempArray)
	

# rotates the item in the specified direction (1 for clockwise, -1 for counter-clockwise)
func rotateItem(dir):
	for slot in itemGridSizes:
		var temp = slot[0] ## this switches the coordinate info to match with being rotated
		slot[0] = (-slot[1] * dir)
		slot[1] = (temp * dir)
	rotation_degrees += (90 * dir) 
	if rotation_degrees >= 360:
		rotation_degrees = 0
		
# makes sure the item visually snaps to its desired position in the grid
func snapToPos(destination:Vector2): ## this tweens an item to its desired position when being placed
	var tween = get_tree().create_tween()
	if int(rotation_degrees) % 180 == 0: ## if it's upright or upside down, put it normally
		destination += itemIconPath.size/2
	else: ## otherwise, switch the X/Y coordinate info of the item and add that instead
		var tempXYSwitch = Vector2(itemIconPath.size.y, itemIconPath.size.x);
		destination += tempXYSwitch/2
	tween.tween_property(self, "global_position", destination, 0.15).set_trans(Tween.TRANS_SINE)
	selected = false
