extends Area2D

var can_shoot := true
var player_in_sight := false

@onready var laser_timer: Timer = $"../LaserTimer"

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_in_sight = true
		_try_shoot()

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_in_sight = false

func _try_shoot() -> void:
	if can_shoot and player_in_sight:
		can_shoot = false
		call_deferred("_on_shoot_deferred")
		laser_timer.start()

func _on_laser_timer_timeout() -> void:
	can_shoot = true
	_try_shoot()

func _on_shoot_deferred() -> void:
	get_parent()._on_shoot()
