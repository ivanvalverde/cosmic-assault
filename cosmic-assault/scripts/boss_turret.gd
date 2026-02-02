extends Node2D

var can_attack = false
var laser_scene = preload("res://scenes/turret_laser.tscn")
var explosion_scene := preload("res://scenes/explosion.tscn")
var health = 10
@export var rotation_speed := 2.0 # rad/s
@onready var shader_mat: ShaderMaterial = $Turret/BossTurret.material
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Turret/CollisionPolygon2D.set_deferred("disabled", true)
	$AnimationPlayer.play("open_cannon")
	await $AnimationPlayer.animation_finished
	$Turret.visible = true
	$AnimationPlayer.play("rise_turret")
	await $AnimationPlayer.animation_finished
	$Turret/CollisionPolygon2D.set_deferred("disabled", false)
	can_attack = true
	$Turret/ShootTimer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not can_attack:
		return

	var player = get_tree().current_scene.get_node_or_null("Player")
	if player == null:
		return
	var turret = get_node_or_null("Turret")
	if turret:
		var target_angle: float = (player.global_position - $Turret.global_position).angle() - PI / 2
		# diferença angular normalizada (-PI .. PI)
		var diff: float = wrapf(target_angle - $Turret.rotation, -PI, PI)
		# quanto pode girar neste frame
		var max_step: float = rotation_speed * delta
		# gira no máximo max_step
		$Turret.rotation += clamp(diff, -max_step, max_step)


func _shoot() -> void:
	var laser = laser_scene.instantiate()
	laser.global_position = $Turret/TurretAim.global_position
	laser.scale = Vector2(0.7, 0.7)
	laser.global_rotation = $Turret.global_rotation
	get_tree().current_scene.get_node("Lasers").add_child(laser)


func _on_shoot_timer_timeout() -> void:
	var player = get_tree().current_scene.get_node_or_null("Player")
	if  player:
		_shoot()


func _on_turret_area_entered(area: Area2D) -> void:
	call_deferred("_on_area_entered_deferred", area)

func _check_if_alive() -> void:
	if health <= 0:
		$Turret.hide()
		$Turret/CollisionPolygon2D.set_deferred("disabled", true)
		var explosion = explosion_scene.instantiate()
		explosion.scale = Vector2(2, 2)
		add_child(explosion)
		explosion.play()
		await explosion.animation_finished
		explosion.queue_free()
		$Turret.queue_free()

func _flash_hit():
	shader_mat.set_shader_parameter("flash_pct", 1.0)

	var tween = create_tween()
	tween.tween_property(
		shader_mat,
		"shader_parameter/flash_pct",
		0.0,
		0.15
	)
	
func _on_area_entered_deferred(area: Area2D) -> void:
	var particles := $Turret/GPUParticles2D
	if area.is_in_group("Projectiles"):
		_flash_hit()
		health -= area._deal_damage()
		particles.global_position = area.global_position
		particles.restart()
		particles.emitting = true
		area.queue_free()
		_check_if_alive()
