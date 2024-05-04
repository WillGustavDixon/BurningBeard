extends ColorRect
	
func fadeOut():
	visible = true
	$Anim.play("fadeOut")

func hold():
	$Anim.play("hold")

func fadeIn():
	$Anim.play("fadeIn")
