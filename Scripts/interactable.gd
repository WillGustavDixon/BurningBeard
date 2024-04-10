extends RigidBody3D

# VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV

# DON'T EDIT ME DIRECTLY - DUPLICATE BEFORE EDITING!!!!!!

# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

func _ready():
	## when created, do something (like setting position/rotation, locking axes, etc.)
	pass ## delete me after function body added

func _process(delta):
	## if need be, do something every frame
	pass ## delete me after

# called when colliding with another object (that has a CollisionObject3D attached)
func _on_body_entered(body):
	## this checks if it's touching the player
	## can always be modified to check if touching something else.
	if(body.is_in_group("Player")): 
		## do something
		pass ## delete 
