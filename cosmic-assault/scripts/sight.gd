extends Area2D

var enemy_laser_scene := preload("res://scenes/enemy_laser.tscn")
var can_shoot = true
@onready var laser_timer = $"../LaserTimer"

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		_on_shoot()

func _on_shoot() -> void:
	if can_shoot:
		call_deferred("_on_shoot_deferred")
		can_shoot = false
		laser_timer.start()

func _on_laser_timer_timeout() -> void:
	can_shoot = true

func _on_shoot_deferred() -> void:
	get_parent()._on_shoot()
