extends ColorRect

@onready var titlePath = $ItemInfoBG/ItemName
@onready var valuePath = $ItemInfoBG/MarginContainer/InfoRows/ItemValue
@onready var rarityPath = $ItemInfoBG/MarginContainer/InfoRows/ItemRarity
@onready var bg = $ItemInfoBG

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = get_global_mouse_position()


# function to edit text
func editText(item):
	titlePath.text = item.itemName
	valuePath.text = "Value: %s" % item.value 
	## it doesn't like just inserting a float so we have to use a format string
	rarityPath.text = findRarity(item.rarity)
	bg.color = findRarityColour(item.rarity)

# Interprets the integer value of an item's rarity and returns a string value
func findRarity(rarity) -> String: 
	match rarity:
		1: return "Common"
		2: return "Uncommon"
		3: return "Rare"
		4: return "Exotic"
		5: return "Legendary"
		_: return "ERROR"

# Interprets the integer value of an item's rarity and returns a colour 
func findRarityColour(rarity) -> Color: 
	match rarity:
		1: return Color(0.5,0.5,0.5,0.9) ## common (grey)
		2: return Color(0,1,0,0.9) ## uncommon (green)
		3: return Color(0,0.5,1,0.9) ## rare (blue)
		4: return Color(1,0,0,0.9) ## exotic (red)
		5: return Color(1,0.5,0,0.9) ## legendary (yellow/orangeish)
		_: return Color(1,0,1,0.9) ## N/A (magenta)
