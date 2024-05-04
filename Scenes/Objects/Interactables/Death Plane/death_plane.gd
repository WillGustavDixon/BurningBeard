extends Area3D

@export var material : StandardMaterial3D

func _ready():
	$Mesh.material_override = material
