extends ColorRect

@onready var reqInfoDef = preload("res://Scenes/Shop/req_info.tscn")
@onready var reqInfoSml = preload("res://Scenes/Shop/req_info_sml.tscn")
@onready var hBox = $ItemReqsBG/HBox
@onready var grid = $ItemReqsBG/Grid
@onready var areaText = $ItemReqsBG/AreaText
var reqInfos : Array

func addReqs(reqs, inv):
	var container = grid if reqs.size() > 6 else hBox
	var reqInfo = reqInfoSml if reqs.size() > 6 else reqInfoDef
	for req in reqs:
		var curReq = reqInfo.instantiate()
		container.add_child(curReq)
		var itemData = findItemInfo(req)
		var n = countItems(req, inv)
		curReq.itemName.text = ("[center]" + itemData[0] + "[/center]")
		curReq.itemIcon.texture = load(itemData[1])
		curReq.itemAmt.text = ("[center]" + str(n) + " / " + str(reqs[req]) + "[/center]")
		curReq.ok = (n >= reqs[req])
		curReq.isOK()
		reqInfos.push_back(curReq)
	

func findItemInfo(id) -> Array:
	var n = DataHandling.itemData[id]["Item Name"]
	var i = "res://Assets/Items/" + DataHandling.itemData[id]["Item Name"] + "Icon.png"
	return [n,i]

func countItems(i, inv) -> int:
	var count = 0
	for item in inv:
		if item.ID == i:
			count += 1
	return count
