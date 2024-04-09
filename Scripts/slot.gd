extends TextureRect

signal slotEntered(slot)
signal slotExited(slot)

@onready var filter = $StatusFilter

var ID ## each slot's unique ID
var isHovering := false ## if the mouse is hovering over this slot
enum slotStates {idle, free, occupied}
var curState := slotStates.idle
var storedItem = null


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if get_global_rect().has_point((get_global_mouse_position())):
		if not isHovering: ## if the mouse is over this node but bool is false
			isHovering = true  
			emit_signal("slotEntered", self) ## send a signal saying its moused over
	else:
		if isHovering: ## if the mouse is not over this node but bool is true
			isHovering = false
			emit_signal("slotExited", self) ## send a signal saying its not

# sets the colour of the slot based on its state
func setColour(state = slotStates.idle) -> void:
	match state: ## match is basically the switch statement in java, C#, etc.
		slotStates.idle:
			filter.color = Color(Color.WHITE, 0.0) ## when not being touched, filter is invisible
		slotStates.free:
			filter.color = Color(Color.GREEN, 0.2) ## if able to be placed on, turn green
		slotStates.occupied:
			filter.color = Color(Color.RED, 0.2) ## if unable to be placed on, turn red

func hasItem(item) -> bool:
	if storedItem == item:
		return true
	return false
