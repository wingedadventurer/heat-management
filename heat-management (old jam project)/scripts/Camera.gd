extends Camera2D

# player instances camera on its own

var zoom2go = Vector2(1, 1)
var zoom_speed_factor = 0.1

func _process(delta):
	# manual easing
	zoom += (zoom2go - zoom) * zoom_speed_factor