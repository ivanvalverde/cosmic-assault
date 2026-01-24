extends CharacterBody2D


const SPEED = 300.0
signal shoot_laser(pos)
signal explode(pos)
var can_shoot = true
var explosion_scene := preload("res://scenes/explosion.tscn")


func _physics_process(_delta: float) -> void:
	# Add the gravity.
	var direction = Input.get_vector("move_left", "move_right","move_up", "move_down")
	velocity = direction * SPEED
	move_and_slide()
	
	if Input.is_action_just_pressed("shoot"):
		if can_shoot:
			shoot_laser.emit(position)
			can_shoot = false
			$LaserTimer.start()


func _on_laser_timer_timeout() -> void:
	can_shoot = true

func _get_hit() -> void:
	explode.emit(global_position)
	queue_free()
