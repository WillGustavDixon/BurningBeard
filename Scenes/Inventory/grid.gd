extends GridContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func draw(arr, cols, slots, parent):
	columns = cols
	for i in range(slots):
		parent.createSlot(self, arr)
