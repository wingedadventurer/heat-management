extends Node

# root node, for managing levels

export var current_level_index = -1 # start off from first level

# loading all levels...
var Level00 = ResourceLoader.load("res://levels/Level00.tscn")
var Level01 = ResourceLoader.load("res://levels/Level01.tscn")
var Level02 = ResourceLoader.load("res://levels/Level02.tscn")
var Level03 = ResourceLoader.load("res://levels/Level03.tscn")
var Level04 = ResourceLoader.load("res://levels/Level04.tscn")
var Level05 = ResourceLoader.load("res://levels/Level05.tscn")

var levels = Array()
var current_level = null

func _ready():
	# storing levels in an array
	levels.append(Level00)
	levels.append(Level01)
	levels.append(Level02)
	levels.append(Level03)
	levels.append(Level04)
	levels.append(Level05)
	
	load_next_level() # this now accesses next level in array

func _process(delta):
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()

func load_next_level():
	if get_child_count() != 0: get_child(0).queue_free()
	current_level_index += 1
	current_level = levels[current_level_index]
	var new_scene = current_level.instance()
	add_child(new_scene)

func _on_next_level(): 	# method for signal emitted by teleporter
						# that the level is complete
	load_next_level()