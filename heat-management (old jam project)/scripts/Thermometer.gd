extends Node2D

# node that reads the temperature and, if conditions are met,
# disables (opens) doors

# doors have to be its children

export var required_temperature = 60.0
export var above = true

var temperature = -1

var active = false
var active_old = false

func _process(delta):
	# reading temperature
	var bodies
	bodies = $Area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("heatobject"):
			temperature = body.temperature
			break
	
	# checking condition
	if above: active = temperature >= required_temperature
	else: active = temperature <= required_temperature
	
	# coloring the indicator
	if active:
		$Sprite.modulate = Color(0, 1.5, 0)
	else:
		$Sprite.modulate = Color(1.5, 0, 0)
	
	# making doors non-collidable and slightly transparent when conditions are met
	# the "active_old" here is so that the code gets executed only upon change
	if active_old != active:
		active_old = active
		for door in get_children():
			if door is TileMap:
				door.set_collision_layer_bit(0, 1 - int(active))
				door.set_collision_mask_bit(0, 1 - int(active))
				door.modulate.a = 1.0 - int(active) * 0.8