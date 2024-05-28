extends Button

func exitInv():
	Input.action_press("Inventory")
	Input.action_release("Inventory")

func saveInv():
	Input.action_press("Save")
	Input.action_release("Save")

func loadInv():
	Input.action_press("Load")
	Input.action_release("Load")

func exitTrade():
	Input.action_press("Pause")
	Input.action_release("Pause")
	
func trade():
	Input.action_press("Trade")
	Input.action_release("Trade")
