extends Node2D

@onready var textture: Sprite2D = $textture
@onready var area_sign: Area2D = $area_sign

@export var dialog_position_offset := Vector2.ZERO

const lines: Array[String] = [
	"Olá, aventureiro!",
	"É muito bom vê-lo por aqui",
	"Espero que esteja preparado...",
	"Sua jornada está apenas...",
	"...COMEÇANDO!",
]

func can_interact() -> bool:
	return area_sign.get_overlapping_bodies().size() > 0

func _process(_delta: float) -> void:
	textture.visible = can_interact() and not DialogManager.is_message_active

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_interact() and not DialogManager.is_message_active:
		DialogManager.start_message(textture.global_position + dialog_position_offset, lines)
