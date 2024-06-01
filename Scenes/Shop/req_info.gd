extends MarginContainer

@onready var bg = $ColorRect
@onready var itemIcon = $InfoRows/ItemIcon 
@onready var itemName = $InfoRows/ItemName  
@onready var itemAmt = $InfoRows/ItemAmt  
@onready var itemOK : RichTextLabel = $InfoRows/ItemOK

var ok

func isOK():
	if ok:
		itemOK.text = ("[center][color=#006600]OK[/color]")
		bg.color = Color("#00FF00", 0.4)
	else:
		itemOK.text = ("[center][color=#880000]REQUIRED[/color]")
		bg.color = Color("#FF0000", 0.4)
