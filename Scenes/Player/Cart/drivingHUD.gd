extends Control

@onready var compass = $CompassBG/Compass

var compassWidth

# Called when the node enters the scene tree for the first time.
func _ready():
	compassWidth = compass.texture.atlas.get_width() - compass.texture.region.size.x 


func rotateCompass(rot):
	var compassRot = wrapf(rad_to_deg(-rot) * compassWidth/360.0, 0, compassWidth)
	compass.texture.region.position.x = compassRot
