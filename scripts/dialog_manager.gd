extends Node

@onready var dialog_box_scene = preload("res://entities/math_question_box.tscn")
var message_lines : Array[String] = []
var current_line = 0

var dialog_box
var dialog_box_position := Vector2.ZERO

var is_message_active := false
var can_advance_message := false
var balloons_by_owner := {}
var math_state_by_owner := {}

func start_message(position: Vector2, lines: Array[String]):
	if is_message_active:
		return
		
	message_lines = lines
	dialog_box_position = position
	show_text()
	is_message_active = true

func show_text():
	dialog_box = dialog_box_scene.instantiate()
	dialog_box.text_deiplay_finished.connect(_on_all_text_displayed)
	get_tree().root.add_child(dialog_box)
	dialog_box.global_position = dialog_box_position
	dialog_box.display_text(message_lines[current_line])
	can_advance_message = false
	
func _on_all_text_displayed():
	can_advance_message = true

func _unhandled_input(event):
	if (event.is_action_pressed("advance_message")  && is_message_active && can_advance_message):
		dialog_box.queue_free()
		current_line += 1
		if current_line >= message_lines.size():
			is_message_active = false
			current_line = 0
			return
		show_text()

func show_balloon(target: Node2D, text: String, owner_id := ""):
	if owner_id != "":
		var previous_balloon = balloons_by_owner.get(owner_id)
		if is_instance_valid(previous_balloon):
			previous_balloon.queue_free()
		balloons_by_owner.erase(owner_id)
	
	var box = dialog_box_scene.instantiate()
	get_tree().root.call_deferred("add_child", box)
	
	box.display_text(text)
	box.target = target
	
	if owner_id != "":
		balloons_by_owner[owner_id] = box
	
	return box

func save_math_state(owner_id: String, data: Dictionary):
	math_state_by_owner[owner_id] = data.duplicate(true)

func get_math_state(owner_id: String) -> Dictionary:
	var data = math_state_by_owner.get(owner_id, {})
	return data.duplicate(true)
