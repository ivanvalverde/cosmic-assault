extends Area2D

@export var sprite_forward_offset := PI / 2
@export var speed := 200.0
var velocity := Vector2.RIGHT
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	velocity = Vector2.RIGHT.rotated(rotation + sprite_forward_offset) * speed
	global_position += velocity * delta


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body._get_hit()
		queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
