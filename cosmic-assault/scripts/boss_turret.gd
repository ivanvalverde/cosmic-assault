extends Node2D

var can_attack = false
@export var rotation_speed := 3.0 # rad/s
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("open_cannon")
	await $AnimationPlayer.animation_finished
	$Turret.visible = true
	$AnimationPlayer.play("rise_turret")
	await $AnimationPlayer.animation_finished
	can_attack = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if can_attack:
		var player = get_tree().current_scene.get_node("Player")
		if not player:
			return

		var dir = player.global_position - $Turret/BossTurret.global_position
		var target_angle = dir.angle() - 90

		$Turret/BossTurret.rotation = lerp_angle(
			$Turret/BossTurret.rotation,
			target_angle,
			rotation_speed * delta
		)

func look_at_player():
	var player = get_tree().get_first_node_in_group("player")
	if player:
		$Turret/BossTurret.look_at(player.global_position)
