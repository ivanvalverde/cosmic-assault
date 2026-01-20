extends Area2D

var rng = RandomNumberGenerator.new()
var velocity := Vector2.ZERO
var health := 0
var explosion_scene := preload("res://scenes/explosion.tscn")
var meteor_scene := preload("res://scenes/meteor.tscn")

@onready var shader_mat: ShaderMaterial = $Sprite2D.material

enum MeteorType {
	EMPTY,
	BIG1,
	BIG2,
	BIG3,
	MED1,
	SMALL1,
	TINY1
}

enum MeteorColor {
	EMPTY,
	BROWN,
	GREY
}

const METEOR_HEALTH := {
	"1": 4,
	"2": 4,
	"3": 4,
	"4": 3,
	"5": 2,
	"6": 1
}

# Chaves externas são MeteorType enquanto as internas são MeteorColor
const METEOR_TEXTURES := {
	"1": {
		"1": preload("res://assets/kenney/Meteors/meteorBrown_big1.png"),
		"2": preload("res://assets/kenney/Meteors/meteorGrey_big1.png"),
	},
	"2": {
		"1": preload("res://assets/kenney/Meteors/meteorBrown_big2.png"),
		"2": preload("res://assets/kenney/Meteors/meteorGrey_big2.png"),
	},
	"3": {
		"1": preload("res://assets/kenney/Meteors/meteorBrown_big3.png"),
		"2": preload("res://assets/kenney/Meteors/meteorGrey_big3.png"),
	},
	"4": {
		"1": preload("res://assets/kenney/Meteors/meteorBrown_med1.png"),
		"2": preload("res://assets/kenney/Meteors/meteorGrey_med1.png"),
	},
	"5": {
		"1": preload("res://assets/kenney/Meteors/meteorBrown_small1.png"),
		"2": preload("res://assets/kenney/Meteors/meteorGrey_small1.png"),
	},
	"6": {
		"1": preload("res://assets/kenney/Meteors/meteorBrown_tiny1.png"),
		"2": preload("res://assets/kenney/Meteors/meteorGrey_tiny1.png"),
	},
}

@export var meteor_type: MeteorType = MeteorType.EMPTY
@export var meteor_color: MeteorColor = MeteorColor.EMPTY

const COLLISION_NODE_NAME := {
	"1": "CollisionBig1",
	"2": "CollisionBig2",
	"3": "CollisionBig3",
	"4": "CollisionMed1",
	"5": "CollisionSmall1",
	"6": "CollisionTiny1",
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if $Sprite2D.material != null:
		$Sprite2D.material = $Sprite2D.material.duplicate()
		shader_mat = $Sprite2D.material as ShaderMaterial
	_generate_meteor_texture()
	health = METEOR_HEALTH[str(meteor_type)]
	var dir := Vector2(rng.randf_range(-0.5, 0.5), rng.randf_range(0.8, 1.2)).normalized()
	var speed := rng.randf_range(100, 300)
	velocity = dir * speed


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotation += rng.randf_range(0.5, 2) * delta
	position += velocity * delta

func _generate_meteor_texture():
	if meteor_type == MeteorType.EMPTY or meteor_color == MeteorColor.EMPTY:
		var typeValues = MeteorType.values()
		var colorValues = MeteorColor.values()
		meteor_type = typeValues[rng.randi_range(1, typeValues.size() - 1)]
		meteor_color = colorValues[rng.randi_range(1, colorValues.size() - 1)]
		
	_apply_collision(meteor_type)
	$Sprite2D.texture = METEOR_TEXTURES[str(meteor_type)][str(meteor_color)]

func _apply_collision(t) -> void:
	for child in get_children():
		if child is CollisionPolygon2D:
			child.disabled = true
			child.hide()
	var node_name = COLLISION_NODE_NAME.get(str(t), "")
	if node_name == "":
		return
	var col := get_node_or_null(node_name) as CollisionPolygon2D
	if col:
		col.disabled = false
		col.show()


func _on_area_entered(area: Area2D) -> void:
	call_deferred("_on_area_entered_deferred", area)

func _on_area_entered_deferred(area: Area2D) -> void:
	var particles := $GPUParticles2D
	if area.is_in_group("Projectiles"):
		_flash_hit()
		health -= area._deal_damage()
		particles.global_position = area.global_position
		particles.restart()
		particles.emitting = true
		area.queue_free()
		if health <= 0:
			$Sprite2D.hide()
			for child in get_children():
				if child is CollisionPolygon2D:
					child.set_deferred("disabled", true)
			var explosion = explosion_scene.instantiate()
			_getting_explosion_scale(meteor_type, explosion)
			_generating_child_meteors(meteor_type, meteor_color)
			add_child(explosion)
			explosion.play()
			await explosion.animation_finished
			explosion.queue_free()
			queue_free()

func _getting_explosion_scale(type: int, explosion: AnimatedSprite2D) -> void:
	if type in [1,2,3]:
		explosion.scale = Vector2(7, 7)
	elif type == 6:
		explosion.scale = Vector2(3, 3)
	elif type == 6:
		explosion.scale = Vector2(1, 1)

func _generating_child_meteors(type, color):
	var meteors_number = 0
	var new_type = 0
	if type in [1,2,3]:
		new_type = 5
		meteors_number = 3
	if type == 4:
		new_type = 6
		meteors_number = 2
	for i in range(meteors_number):
		var meteor = meteor_scene.instantiate()
		meteor.meteor_color = color
		meteor.meteor_type = new_type
		meteor.global_position = global_position
		get_parent().add_child(meteor)
	

func _flash_hit():
	shader_mat.set_shader_parameter("flash_pct", 1.0)

	var tween = create_tween()
	tween.tween_property(
		shader_mat,
		"shader_parameter/flash_pct",
		0.0,
		0.15
	)


func _on_body_entered(body: Node2D) -> void:
	health -= 1
	_flash_hit()
	var explosion = explosion_scene.instantiate()
	explosion.global_position = body.global_position
	body.queue_free()
	get_parent().get_parent().add_child(explosion)
	explosion.play()
	await explosion.animation_finished
	explosion.queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	$WaitToBeQueuedTimer.start()


func _on_wait_to_be_queued_timer_timeout() -> void:
	queue_free()
