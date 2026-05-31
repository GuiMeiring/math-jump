extends CharacterBody2D

@export var max_fall_speed := 400.0
@export var can_interact_multiple_times := true
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
		has_interacted = true
		DialogManager.start_message(dialog_anchor.global_position + dialog_position_offset, dialog_lines)
