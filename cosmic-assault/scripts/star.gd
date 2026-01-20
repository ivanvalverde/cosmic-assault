extends Node2D

var star_speed
var rng = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var star_scale = rng.randf_range(0.4, 0.6)
	var animation_speed = rng.randf_range(1.4, 2.0)
	star_speed = rng.randi_range(50, 300)
	scale = Vector2(star_scale, star_scale)
	$AnimatedSprite2D.sprite_frames.set_animation_speed("default", animation_speed)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += Vector2(0, star_speed * delta)


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if position.y > 0:
		queue_free()
