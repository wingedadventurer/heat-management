extends Node2D

var node_to_chase = null
var chase_started = false
var new_modulate = Color(1, 1, 1, 1)

func _ready():
	$Timer.connect("timeout", self, "_on_timer_timeout")
	$Timer.wait_time = 0.5
	$Timer.start()

func _draw():
	draw_rect(Rect2(Vector2(-1, -1), Vector2(2, 2)), new_modulate)

func _process(delta):
	if chase_started == false and node_to_chase != null:
		chase_started = true
		$Tween.interpolate_property(self, "position", position, node_to_chase.global_position + Vector2(16, 16), 0.5, Tween.TRANS_EXPO, Tween.EASE_OUT)
		$Tween.start()
	update()

func _on_timer_timeout():
	queue_free()