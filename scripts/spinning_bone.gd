extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var speed = 30
var direction = 1

func _process(delta: float) -> void:
	position.x += speed * delta * direction

func set_direction(skeleton_direction):
	direction = skeleton_direction
	if direction < 0:
		anim.flip_h = true
	else:
		anim.flip_h = false

func get_direction() -> int:
	return direction

func _on_self_destruc_timer_timeout() -> void:
	queue_free()

func _on_area_entered(_area: Area2D) -> void:
	queue_free()

func _on_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("player"):
		return
	
	queue_free()
