extends Area2D

@export var speed := 200.0
@export var turn_speed := 6.0
@export var sprite_forward_offset := PI / 2
@export var homing_delay := 0.25

@onready var player := get_tree().current_scene.get_node("Player") as Node2D

var velocity := Vector2.RIGHT
var time_alive := 0.0

func _ready() -> void:
	velocity = Vector2.RIGHT.rotated(rotation + sprite_forward_offset) * speed

func _process(delta: float) -> void:
	time_alive += delta
	global_position += velocity * delta
	rotation = velocity.angle() + sprite_forward_offset
	if time_alive < homing_delay:
		return
	if not is_instance_valid(player):
		return
	var desired_dir := (player.global_position - global_position).normalized()
	var current_dir := velocity.normalized()
	var new_dir := current_dir.slerp(desired_dir, clamp(turn_speed * delta, 0.0, 1.0))
	velocity = new_dir * speed


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body._get_hit()
		queue_free()
