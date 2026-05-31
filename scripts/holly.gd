extends CharacterBody2D

@export var max_fall_speed := 400.0
@export var can_interact_multiple_times := true
@export var require_all_enemies_defeated := false
@export var remaining_enemies_dialog_lines: Array[String] = [
	"Oh nao, Diego!",
	"Ainda existem inimigos no caminho.",
	"O equilibrio ainda nao foi restaurado.",
]
@export var dialog_position_offset := Vector2.ZERO
@export var dialog_lines: Array[String] = [
	"Ola, aventureiro!",
	"E muito bom ve-lo por aqui",
	"Espero que esteja preparado...",
	"Sua jornada esta apenas...",
	"...COMECANDO!",
]

@onready var interaction_indicator: Sprite2D = $InteractionIndicator
@onready var interaction_area: Area2D = $InteractionArea
@onready var dialog_anchor: Marker2D = $DialogAnchor

var has_interacted := false

func _ready() -> void:
	interaction_indicator.visible = false

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		velocity.y = min(velocity.y, max_fall_speed)
	else:
		velocity.y = 0.0

	move_and_slide()

func can_interact() -> bool:
	if has_interacted and not can_interact_multiple_times:
		return false

	return interaction_area.get_overlapping_bodies().size() > 0

func _process(_delta: float) -> void:
	interaction_indicator.visible = can_interact() and not DialogManager.is_message_active

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_interact() and not DialogManager.is_message_active:
		var has_pending_enemies := require_all_enemies_defeated and has_remaining_enemies()
		var current_dialog_lines := get_current_dialog_lines(has_pending_enemies)
		if not has_pending_enemies:
			has_interacted = true
		DialogManager.start_message(dialog_anchor.global_position + dialog_position_offset, current_dialog_lines)

func get_current_dialog_lines(has_pending_enemies: bool) -> Array[String]:
	if has_pending_enemies:
		return remaining_enemies_dialog_lines

	return dialog_lines

func has_remaining_enemies() -> bool:
	var current_scene := get_tree().current_scene
	if current_scene == null:
		return false

	return has_attackable_enemy_in_node(current_scene)

func has_attackable_enemy_in_node(node: Node) -> bool:
	if node.has_method("is_attackable") and node.is_attackable():
		return true

	for child in node.get_children():
		if has_attackable_enemy_in_node(child):
			return true

	return false
