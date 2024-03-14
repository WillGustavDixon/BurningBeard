extends Node

var itemData := {}
var inventoryData := {}
@onready var dataPath = "res://Data/ItemData.json"

# Called when the node enters the scene tree for the first time.
func _ready():
	loadData(dataPath)
	setItemSizeData()


# loads potential item data (as in, every item that can exist, not current inventory)
func loadData(path) -> void:
	if not FileAccess.file_exists((path)):
		print("Item data not found")
	var dataFile = FileAccess.open(path, FileAccess.READ)
	itemData = JSON.parse_string(dataFile.get_as_text())
	dataFile.close()
	##print(itemData)
	
# sets the grid size of each item
func setItemSizeData():
	for item in itemData.keys():
		var tempArray := []
		for point in itemData[item]["Grid Size"].split("/"):
			tempArray.push_back(point.split(","))
		inventoryData[item] = tempArray
	##print(inventoryData)
