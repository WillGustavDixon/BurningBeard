extends Area3D

@onready var itemReqsScene = preload("res://Scenes/Shop/item_reqs.tscn")
@onready var root = get_tree().get_nodes_in_group("Root")[0]
@onready var shop = find_child("Shop", false)
@export var itemReqs : Dictionary
@export var servingItems : Array
@export var shopID : int # ID just in case 
@export var area : String

var canStartShop := false
var itemReqsWindow

func _process(delta):
	if canStartShop:
		if Input.is_action_just_pressed("Interact"):
			get_owner().startShop(shop, itemReqs)


func _on_body_entered(body):
	if body.is_in_group("Player"): 
		toggleItemReqs()
		# check if all items in itemReqs are in the player's inventory
		canStartShop = true
		for req in itemReqsWindow.reqInfos:
			if !req.ok:
				canStartShop = false
		
func _on_body_exited(body):
	if body.is_in_group("Player"): 
		toggleItemReqs()
		canStartShop = false

func toggleItemReqs():
	if !is_instance_valid(itemReqsWindow):
		itemReqsWindow = itemReqsScene.instantiate()
		add_child(itemReqsWindow)
		itemReqsWindow.areaText.text = "[center]" + area
		itemReqsWindow.addReqs(itemReqs, root.inv.inventory)
	else:
		remove_child(itemReqsWindow)
		itemReqsWindow.queue_free()
