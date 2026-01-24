extends Area2D

var explosion_scene := preload("res://scenes/explosion.tscn")
var enemy_laser_scene := preload("res://scenes/enemy_laser.tscn")

@export var horizontal_speed := 150.0
@export var vertical_speed := 80.0
@export var health := 3

@onready var shader_mat: ShaderMaterial = $Sprite2D.material
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var viewRect = get_viewport_rect()
	var offset = 30
	position.y += vertical_speed * delta
	position.x += horizontal_speed * delta
	if position.x < viewRect.position.x + offset or position.x > viewRect.end.x - offset:
		horizontal_speed *= -1
	


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	$WaitToBeQueuedTimer.start()


func _on_wait_to_be_queued_timer_timeout() -> void:
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	call_deferred("_on_area_entered_deferred", area)

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
	var particles := $GPUParticles2D
	if area.is_in_group("Projectiles"):
		_flash_hit()
		health -= area._deal_damage()
		particles.global_position = area.global_position
		particles.restart()
		particles.emitting = true
		area.queue_free()
		_check_if_alive()


func _on_body_entered(body: Node2D) -> void:
	health -= 1
	_check_if_alive()
	_flash_hit()
	var explosion = explosion_scene.instantiate()
	explosion.global_position = body.global_position
	body.queue_free()
	get_parent().get_parent().add_child(explosion)
	explosion.play()
	await explosion.animation_finished
	explosion.queue_free()

func _check_if_alive() -> void:
	if health <= 0:
		$Sprite2D.hide()
		$CollisionPolygon2D.set_deferred("disabled", true)
		var explosion = explosion_scene.instantiate()
		explosion.scale = Vector2(7.0, 7.0)
		add_child(explosion)
		explosion.play()
		await explosion.animation_finished
		explosion.queue_free()
		queue_free()
		
func _on_shoot() -> void:
	var laser1 = enemy_laser_scene.instantiate()
	var laser2 = enemy_laser_scene.instantiate()
	$LaserMarkers/Marker2D.add_child(laser1)
	$LaserMarkers/Marker2D2.add_child(laser2)
