extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$BossPlatform.frame = 0

func _on_spawn_enemy(quantity: int, enemy: PackedScene) -> void:
	$AnimationPlayer.play("open")
	await $AnimationPlayer.animation_finished
	for n in range(quantity):
		var foe = enemy.instantiate()
		foe.global_position = global_position - Vector2(0, 50)
		var container = get_tree().current_scene.get_node_or_null("Enemies")
		if not container:
			return
		container.add_child(foe)
		$SpawnTimer.start()
		await $SpawnTimer.timeout
	$AnimationPlayer.play("close")
