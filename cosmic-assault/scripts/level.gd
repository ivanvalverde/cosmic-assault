extends Node2D

const BG_SPEED = 25
const STAR_NUMBER_BEGGINING = 15
var rng = RandomNumberGenerator.new()
@onready var laser_scene = preload("res://scenes/laser.tscn")
@onready var star_scene = preload("res://scenes/star.tscn")
var meteor_scene = preload("res://scenes/meteor.tscn")
var enemy_scene = preload("res://scenes/enemy.tscn")
var explosion_scene = preload("res://scenes/explosion.tscn")

var current_mob = 0
var current_mob_index = 0
var mob_kill_count = 0
var mobs = [
	#[
		#{
		#"quantity": 2,
		#"type": enemy_scene,
		#"spawn_delay": 3,
		#},
		#{
		#"quantity": 30,
		#"type": meteor_scene,
		#"spawn_delay": 0.5,
		#"delay_after_mob": 2
		#}
	#],
	#[
		#{
		#"quantity": 10,
		#"type": enemy_scene,
		#"spawn_delay": 3,
		#"delay_after_mob": 2
		#}
	#]
]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var rect := get_viewport_rect()
	for i in STAR_NUMBER_BEGGINING:
		var star = star_scene.instantiate()
		$Stars.add_child(star)
		star.position = Vector2(rng.randf_range(0, rect.size.x), rng.randf_range(0, rect.size.y))
	start_wave()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$ParallaxBackground.scroll_offset.y += BG_SPEED * delta

func _on_player_shoot_laser(pos: Vector2) -> void:
	var laser = laser_scene.instantiate()
	laser.position = Vector2(pos.x, pos.y - 30.0)
	$Lasers.add_child(laser)


func _on_stars_timer_timeout() -> void:
	var star = star_scene.instantiate()
	$Stars.add_child(star)
	star.position = Vector2(rng.randf_range(0, 540), -30.0)
	$StarsTimer.start()
	
func start_wave() -> void:
	if current_mob >= mobs.size():
		return
	await _spawn_wave_over_time(mobs[current_mob])

func _spawn_wave_over_time(wave: Array) -> void:
	var rect := get_viewport_rect()
	var offset_x = 40
	for group in wave:
		var qty := int(group.quantity)
		var delay := float(group.get("spawn_delay", 0.2))
		var scene := group.type as PackedScene
		for i in range(qty):
			var mob = scene.instantiate()
			$Mobs.add_child(mob)
			mob.position = Vector2(rng.randf_range(offset_x, rect.size.x - offset_x), -30)
			await get_tree().create_timer(delay).timeout
		if wave.size() > current_mob_index + 1:
			current_mob_index = current_mob_index + 1


func _on_player_explode(pos: Variant) -> void:
	var explosion = explosion_scene.instantiate()
	explosion.global_position = pos
	add_child(explosion)
	explosion.play()
	await explosion.animation_finished
	explosion.queue_free()


func _on_between_mob_timer_timeout() -> void:
	call_deferred("start_wave")


func _on_mobs_child_exiting_tree(node: Node) -> void:
	_check_if_is_part_of_mob(node)
	var total_mob_quantity = 0
	for mob in mobs[current_mob]:
		total_mob_quantity += mob["quantity"]
	await get_tree().process_frame
	if $Mobs.get_child_count() == 0 and total_mob_quantity == mob_kill_count:
		current_mob += 1
		current_mob_index = 0
		$BetweenMobTimer.wait_time = mobs[current_mob][current_mob_index]["delay_after_mob"]
		$BetweenMobTimer.start()

func _check_if_is_part_of_mob(node: Node) -> void:
	if "is_mob" in node:
		if node.is_mob:
			mob_kill_count += 1;
	else:
		mob_kill_count += 1;
