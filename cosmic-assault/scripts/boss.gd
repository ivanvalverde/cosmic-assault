extends Node2D

var meteor_scene = preload("res://scenes/enemy.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$BossPlatform._on_spawn_enemy(3, meteor_scene)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
