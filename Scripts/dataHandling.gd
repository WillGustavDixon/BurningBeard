extends Node

var itemData := {}
var itemSizeData := {}
var invData
@onready var itemPath = "res://Data/ItemData.json"
@onready var invPath = "res://Data/InventoryData.json"

# Called when the node enters the scene tree for the first time.
func _ready():
	loadItemData(itemPath)
	setItemSizeData()
	loadInvData(invPath)

# loads potential item data (as in, every item that can exist, not current inventory)
func loadItemData(path) -> void:
	if not FileAccess.file_exists((path)):
		print("Item data not found")
	var dataFile = FileAccess.open(path, FileAccess.READ)
	itemData = JSON.parse_string(dataFile.get_as_text())
	dataFile.close()
	
# sets the grid size of each item
func setItemSizeData():
	for item in itemData.keys():
		var tempArray := []
		for point in itemData[item]["Grid Size"].split("/"):
			tempArray.push_back(point.split(","))
		itemSizeData[item] = tempArray

func loadInvData(path):
	if not FileAccess.file_exists((path)):
		print("Inventory data not found")
	var dataFile = FileAccess.open(path, FileAccess.READ)
	
	invData = dataFile.get_as_text()
	print(invData)
	dataFile.close()
