extends Node

var itemData := {}
var itemSizeData := {}
var invData := {}

@onready var itemPath = "res://Data/ItemData.json"
@onready var invPath = "res://Data/InventoryData.json"

# Called when the node enters the scene tree for the first time.
func _ready():
	loadItemData(itemPath)
	loadInvData(invPath)

func saveInvData(path, data):
	if not FileAccess.file_exists((path)):
		print("Inventory data not found. Creating new file.")
	var dataFile = FileAccess.open(path, FileAccess.WRITE)
	var json = JSON.stringify(data)
	dataFile.store_line(json)
	dataFile.close()

func loadInvData(path):
	var dataFile = null
	if not FileAccess.file_exists((path)):
		print("Inventory data not found. Creating new file.")
		dataFile = FileAccess.open(path, FileAccess.WRITE)
		var data = {"Settings":{"Columns":6,"Size":30,"Gold": 0,"Empty": true},"Slots":{}}
		var json = JSON.stringify(data)
		dataFile.store_line(json)
		dataFile.close()
	print("Inventory data found.")
	dataFile = FileAccess.open(path, FileAccess.READ)
	invData = JSON.parse_string(dataFile.get_as_text())
	dataFile.close()

# loads potential item data (as in, every item that can exist, not current inventory)
func loadItemData(path) -> void:
	if not FileAccess.file_exists((path)):
		print("Item data not found")
	var dataFile = FileAccess.open(path, FileAccess.READ)
	itemData = JSON.parse_string(dataFile.get_as_text())
	dataFile.close()
	setItemSizeData()
	
# sets the grid size of each item
func setItemSizeData():
	for item in itemData.keys():
		var tempArray := []
		for point in itemData[item]["Grid Size"].split("/"):
			tempArray.push_back(point.split(","))
		itemSizeData[item] = tempArray
