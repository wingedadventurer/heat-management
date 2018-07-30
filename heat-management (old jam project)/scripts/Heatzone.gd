extends Area2D

# invisible node that modifies player's heat, without collisions

export var temperature = 50
export var heat_factor = 1.0

func _process(delta):
	transfer_heat()

func transfer_heat():
	for heat_body in get_overlapping_bodies():
		if heat_body is KinematicBody2D:
			var difference = temperature - heat_body.temperature
			if difference > 0.1:
				heat_body.temperature += heat_factor / heat_body.heat_capacity
			elif difference < -0.1:
				heat_body.temperature -= heat_factor / heat_body.heat_capacity