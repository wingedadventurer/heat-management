extends StaticBody2D
tool # used to show colors in the editor

# similar to player, just without movement code and few other things
# wall has only one huge receptor

export var heatable = true
export var temperature = 50.0
export var heat_capacity = 20.0
export var heat_factor = 1.0

var temperature_range

func _ready():
	add_to_group("heatobject")

func _process(delta):
	color_by_temperature()
	transfer_heat()
	calculate_temperature_range()

func transfer_heat():
	for heat_body in $HeatTransfer.get_overlapping_bodies():
		if heat_body.is_in_group("heatobject"):
			var difference = temperature - heat_body.temperature
			if difference > 0.1:
				if heatable:
					temperature -= 1 / heat_capacity * heat_body.heat_factor
				heat_body.temperature += 1 / heat_body.heat_capacity * heat_body.heat_factor
			elif difference < -0.1:
				if heatable:
					temperature += 1 / heat_capacity * heat_body.heat_factor
				heat_body.temperature -= 1 / heat_body.heat_capacity * heat_body.heat_factor

func calculate_temperature_range():
	if temperature < -50:
		temperature_range = -3
	elif -50.0 <= temperature and temperature < -25.0:
		temperature_range = -2
	elif -25.0 <= temperature and temperature < 0.0:
		temperature_range = -1
	elif 0.0 <= temperature and temperature < 100.0:
		temperature_range = 0
	elif 100.0 <= temperature and temperature < 125.0:
		temperature_range = 1
	elif 125.0 <= temperature and temperature < 150.0:
		temperature_range = 2
	elif 150.0 <= temperature:
		temperature_range = 3

func color_by_temperature():
	if temperature_range == -3 or temperature_range == -2:
		modulate = Color(0, 0.25, 1)
	elif temperature_range == -1:
		modulate = Color(0, 0.5 + temperature * 0.01, 1)
	elif temperature_range == 0:
		modulate = Color(clamp(1 + (temperature - 50) * 0.02, 0, 1), 1 - abs(temperature - 50) * 0.01, clamp(1 - (temperature - 50) * 0.02, 0, 1))
	elif temperature_range == 1:
		modulate = Color(1, 0.5 - (temperature - 100) * 0.01, 0)
	elif temperature_range == 2 or temperature_range == 3:
		modulate = Color(1, 0.25, 0)