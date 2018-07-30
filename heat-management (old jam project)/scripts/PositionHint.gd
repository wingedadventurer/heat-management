extends Area2D

# shows itself when player is in the area and hides otherwise
# used for showing hints in game

# note that collision area must be added after instancing

var alpha2go = 0.0
var alpha_speed_factor = 0.2

func _ready():
	modulate.a = 0.0

func _process(delta):
	alpha2go = 0.0
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body is KinematicBody2D:
			alpha2go = 1.0
			break
	
	# manual easing
	modulate.a += (alpha2go - modulate.a) * alpha_speed_factor