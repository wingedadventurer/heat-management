extends Area2D

# just checks if player is here and signals level end to main node

signal next_level

func _ready():
	connect("next_level", get_tree().root.get_node("Main"), "_on_next_level")

func _process(delta):
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body is KinematicBody2D:
			emit_signal("next_level")
			break