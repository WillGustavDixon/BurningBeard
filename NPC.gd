extends RigidBody3D

@onready var itemScene = preload("res://Scenes/Inventory/Item/item.tscn")

var canTalk := false # will use later
var canTrade := false

@export var npcID : int
@export var slotsItemIDs : Dictionary
@export var inventory = []
@export var invEmpty : bool
@export var gold : int
@export var gridSlots : int
@export var gridCols : int

func _ready(): ## bit of a fucky way of making his inventory but it works
	for slot in slotsItemIDs:
		var newItem = itemScene.instantiate()
		get_tree().get_nodes_in_group("Root")[0].find_child("ItemHider", false).add_child(newItem)
		newItem.loadItem(slotsItemIDs[slot])
		newItem.primeSlotID = int(slot)
		inventory.push_back(newItem)
	if inventory.size() == 0:
		invEmpty = true
	else : invEmpty = false

func _process(delta):
	if canTrade:
		if Input.is_action_just_pressed("Interact"):
			get_owner().openTrade(self)

func tradeExited():
	if inventory.size() == 0:
		invEmpty = true
	else : invEmpty = false

func _on_body_entered(body):
	if body.is_in_group("Player"): 
		canTrade = true
		
func _on_body_exited(body):
	if body.is_in_group("Player"): 
		canTrade = false
