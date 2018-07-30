extends KinematicBody2D

# bunch of code here! don't get too lost

var scene_heat_particle = ResourceLoader.load("res://instances/HeatParticle.tscn")
var scene_camera = ResourceLoader.load("res://instances/Camera.tscn")

export var heatable = true
export var temperature = 50.0
export var heat_capacity = 25.0

var acceleration_horizontal_def = 250
var jump_velocity_def = 275
var friction_factor_horizontal_floor_default = 0.1
var bounce_factor_horizontal_def = 0.3
var bounce_factor_vertical_def = 0.2

var gravity_acceleration = 800

var jump_delay = 500 # [milliseconds]
var friction_factor_horizontal_air = 0.01

# ignore this (or google "magic number in programming" ;) )
var magic_number_1 = 15
var magic_number_2 = -70

var position_start
var velocity = Vector2()
var jump_delay_current = 0
var jump_velocity
var acceleration_horizontal
var friction_factor_horizontal_floor
var bounce_factor_horizontal
var bounce_factor_vertical
var temperature_range = 0
var will_jump
var node_camera

func _ready():
	acceleration_horizontal = acceleration_horizontal_def
	jump_velocity = jump_velocity_def
	friction_factor_horizontal_floor = friction_factor_horizontal_floor_default
	position_start = position

	# this instances camera node, no need to add your own
	node_camera = scene_camera.instance()
	add_child(node_camera)

func _draw():
	# just for drawing player velocity
	# initially needed it when creating basic movement
	
	draw_line(Vector2(0, 0), velocity, Color(1, 1, 1, 1))

func _process(delta):
	color_by_temperature()
	#godmode() # enable if you want in-game control
	calculate_velocity(delta)
	#update() # enable to draw velocity vector
	apply_velocity(delta)
	transfer_heat()
	calculate_temperature_range()
	modify_parameters_by_temperature()
	
	# [MODIFY CAMERA]
	node_camera.zoom2go = Vector2(1, 1) * exp(velocity.length() * 0.00025)

# <><><><><><><><><><><><><><><><><><><><>

func godmode():
	if Input.is_action_just_pressed("reset"): # R key
		position = position_start
	
	if Input.is_key_pressed(KEY_E): temperature += 1
	if Input.is_key_pressed(KEY_Q): temperature -= 1
	
	# label to draw temparature (currently hidden, unhide manually)
	$Labels/Label.text = str(int(temperature))
	$Labels.modulate = Color(0.8, 0.8, 0.8)

func transfer_heat():
	# so the player node has few "receptors" (collision nodes)
	# they constantly check if there are walls around
	
	for heat_receptor in $HeatReceptors.get_children():
		for heat_body in heat_receptor.get_overlapping_bodies():
			if heat_body.is_in_group("heatobject"): # group where you store all objects with heat
				# here is the "cool" part (pun intended).
				# this is physics of termodynamics applied to gamedev (kind of)
				var difference = temperature - heat_body.temperature
				if difference > 0.1:
					if heatable:
						temperature -= 1 / heat_capacity * heat_body.heat_factor
						spawn_heat_particle(self, heat_body)
						
					heat_body.temperature += 1 / heat_body.heat_capacity * heat_body.heat_factor
					spawn_heat_particle(heat_body, self)
				elif difference < -0.1:
					if heatable:
						temperature += 1 / heat_capacity * heat_body.heat_factor
						spawn_heat_particle(self, heat_body)
					heat_body.temperature -= 1 / heat_body.heat_capacity * heat_body.heat_factor
					spawn_heat_particle(heat_body, self)

func is_grounded():
	# checks if there is ground under player
	# used to see if player can jump
	
	var bodies = $GroundChecker.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("wall"):
			return true
	return false

func calculate_velocity(delta):	
	# self-explanatory...

	# [ADDING HORIZONTAL MOVEMENT]
	var moved = 0
	if Input.is_action_pressed("left"):
		velocity.x -= acceleration_horizontal * delta
		if velocity.x < 0: moved = 1
	if Input.is_action_pressed("right"):
		velocity.x += acceleration_horizontal * delta
		if velocity.x > 0: moved = 1
	
	# [ADDING HORIZONTAL FRICTION]
	if !moved:
		if is_grounded():
			velocity.x *= (1 - friction_factor_horizontal_floor)
		else:
			velocity.x *= (1 - friction_factor_horizontal_air)
	
	# [ADDING GRAVITY]
	if !is_grounded():
		velocity.y += gravity_acceleration * delta
	
	# [ADDING JUMP]
	if jump_delay_current > 0: jump_delay_current -= 1000 * delta
	if can_jump(): calculate_jump()

func apply_velocity(delta):
	# self-explanatory...
	
	# [HORIZONTAL]
	var collision
	collision = move_and_collide(Vector2(velocity.x, 0) * delta)
	if collision != null:
		velocity.x *= -bounce_factor_horizontal
		move_and_collide(Vector2(velocity.x, 0) * delta)
	
	# [VERTICAL]
	collision = move_and_collide(Vector2(0, velocity.y) * delta)
	if collision != null:
		# collided, but need to check for jump before bouncing
		# (note: this might not be working properly because the player
		# still bounced instead of jumps sometimes...
		# ignore me, i'm just talking to myself here...
		
		if can_jump():
			calculate_jump()
		else:
			if velocity.y != -jump_velocity:
				velocity.y *= -bounce_factor_vertical
				if magic_number_2 < velocity.y and velocity.y < 0:
					velocity.y = 0
					position.y = round(position.y)

func can_jump():
	# self-explanatory...
	
	if is_grounded() and jump_delay_current <= 0 and Input.is_action_pressed("jump"):
		return true
	return false

func calculate_jump():
	jump_delay_current = jump_delay
	velocity.y = -jump_velocity

func calculate_temperature_range():
	# just defining temperature ranges for easier coding
	
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
	# changing player's color based on temperature
	
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

func modify_parameters_by_temperature():
	# this took quite some time and it's still not perfect.
	# takes a bit of calculation, but it can be pretty fun to play with
	
	if temperature_range == -3 or temperature_range == -2:
		jump_velocity = 0 # 0 blocks (cannot jump)
		acceleration_horizontal = 0 # immovable
		friction_factor_horizontal_floor = 0.0 # super slippery
		bounce_factor_horizontal = 0.1 # slight horizontal bouncing
		bounce_factor_vertical = 0 # no vertical bouncing
		
	elif temperature_range == -1:
		jump_velocity = jump_velocity_def - 50 + (temperature) * 9  # 0-1 blocks
		acceleration_horizontal = acceleration_horizontal_def - 100 + (temperature) * 6
		friction_factor_horizontal_floor = friction_factor_horizontal_floor_default - 0.075 + (temperature) * 0.001
		bounce_factor_horizontal = bounce_factor_horizontal_def - 0.1 + (temperature) * 0.004
		bounce_factor_vertical = bounce_factor_vertical_def - 0.1 + (temperature) * 0.004
		
	elif temperature_range == 0:
		jump_velocity = jump_velocity_def + (temperature - 50) # 1-2 blocks
		acceleration_horizontal = acceleration_horizontal_def + (temperature - 50) * 2
		friction_factor_horizontal_floor = friction_factor_horizontal_floor_default + (temperature - 50) * 0.0015
		bounce_factor_horizontal = bounce_factor_horizontal_def + (temperature - 50) * 0.002
		bounce_factor_vertical = bounce_factor_vertical_def + (temperature - 50) * 0.002
		
	elif temperature_range == 1:
		jump_velocity = jump_velocity_def + 50 + (temperature - 100) * 6 # 2-3 blocks
		acceleration_horizontal = acceleration_horizontal_def + 100 + (temperature - 100) * 26
		friction_factor_horizontal_floor = friction_factor_horizontal_floor_default + 0.075 + (temperature - 100) * 0.001
		bounce_factor_horizontal = bounce_factor_horizontal_def + 0.1 + (temperature - 100) * 0.008
		bounce_factor_vertical = bounce_factor_vertical_def + 0.1 + (temperature - 100) * 0.004
		
	elif temperature_range == 2 or temperature_range == 3:
		jump_velocity = jump_velocity_def + 50 + 150 # 3 blocks
		acceleration_horizontal = acceleration_horizontal_def + 100 + 650
		friction_factor_horizontal_floor = 0.2
		bounce_factor_horizontal = bounce_factor_horizontal_def + 0.1 + 0.2
		bounce_factor_vertical = bounce_factor_vertical_def + 0.1 + 0.1

func spawn_heat_particle(var source, var target):
	var particle = scene_heat_particle.instance()
	get_tree().get_root().add_child(particle)
	particle.position = source.global_position
	particle.new_modulate = source.modulate
	particle.node_to_chase = target