extends Node2D

const BG_SPEED = 25
const STAR_NUMBER_BEGGINING = 15
var rng = RandomNumberGenerator.new()
@onready var laser_scene = preload("res://scenes/laser.tscn")
@onready var star_scene = preload("res://scenes/star.tscn")
var meteor_scene = preload("res://scenes/meteor.tscn")

var current_mob = 0
var mobs = [
	[
		{
		"quantity": 30,
		"type": meteor_scene,
		"spawn_delay": 0.5
		}
	],
	[
		{
		"quantity": 20,
		"type": meteor_scene,
		"spawn_delay": 0.5
		}
	]
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
	# spawna aos poucos
	await _spawn_wave_over_time(mobs[current_mob])
	current_mob += 1

	# opcional: esperar morrer tudo pra próxima
	#await _wait_until_empty($Mobs)
	#call_deferred("start_wave")

func _spawn_wave_over_time(wave: Array) -> void:
	var rect := get_viewport_rect()
	for group in wave:
		var qty := int(group.quantity)
		var delay := float(group.get("spawn_delay", 0.2))
		var scene := group.type as PackedScene
		for i in range(qty):
			var mob = scene.instantiate()
			$Mobs.add_child(mob)
			mob.position = Vector2(rng.randf_range(0, rect.size.x), -30)
			await get_tree().create_timer(delay).timeout

func _wait_until_empty(container: Node) -> void:
	while container.get_child_count() > 0:
		await container.child_exiting_tree
