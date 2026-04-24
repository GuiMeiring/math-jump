extends Node2D

@onready var textture: Sprite2D = $textture
@onready var area_sign: Area2D = $area_sign

const lines: Array[String] = [
	"Olá, aventureiro!",
	"É muito bom vê-lo por aqui",
	"Espero que esteja preparado...",
	"Sua jornada está apenas...",
	"...COMEÇANDO!",
]

func _unhandled_input(event):
	if area_sign.get_overlapping_bodies().size() > 0:
		textture.show()
		if event.is_action_pressed("interact") && !DialogManager.is_message_active:
			textture.hide()
			print("Aqui")
			DialogManager.start_message(global_position, lines)
		else:
			textture.hide()
			if DialogManager.dialog_box != null:
				DialogManager.dialog_box.queue_free()
				DialogManager.is_message_active = false
