extends Area2D

@export var laser_speed = 500
@export var laser_damage = 1
@export var laser_direction = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.y += laser_direction * laser_speed * delta


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _deal_damage() -> int:
	return laser_damage


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body._get_hit()
		queue_free()
