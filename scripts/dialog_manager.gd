extends Node

signal message_finished

@onready var dialog_box_scene = preload("res://entities/math_question_box.tscn")
var message_lines : Array[String] = []
var current_line = 0

var dialog_box
var dialog_box_position := Vector2.ZERO

var is_message_active := false
var can_advance_message := false
var balloons_by_owner := {}
var math_state_by_owner := {}
var previous_math_question_by_owner := {}
var balloons_enabled := true

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
			message_finished.emit()
			return
		show_text()

func show_balloon(target: Node2D, text: String, owner_id := ""):
	if not balloons_enabled or not is_instance_valid(target):
		return null

	if owner_id != "":
		remove_balloon(owner_id)
	
	var box = dialog_box_scene.instantiate()
	box.target = target

	var balloon_parent := get_tree().current_scene
	if balloon_parent == null:
		balloon_parent = target.get_parent()
	if balloon_parent == null:
		box.free()
		return null

	if owner_id != "":
		balloons_by_owner[owner_id] = box

	_attach_balloon.call_deferred(balloon_parent, target, box, text, owner_id)
	
	return box

func _attach_balloon(balloon_parent, target, balloon, text: String, owner_id: String) -> void:
	if not is_instance_valid(balloon_parent) or not is_instance_valid(target) or not is_instance_valid(balloon):
		_clear_balloon_reference(owner_id, balloon)
		_free_detached_balloon(balloon)
		return

	if balloon.get_meta("cancelled", false):
		_clear_balloon_reference(owner_id, balloon)
		_free_detached_balloon(balloon)
		return

	balloon_parent.add_child(balloon)
	balloon.display_text(text)
	target.tree_exiting.connect(_on_balloon_owner_tree_exiting.bind(owner_id, balloon), CONNECT_ONE_SHOT)
	if owner_id != "":
		balloon.tree_exited.connect(_on_balloon_tree_exited.bind(owner_id, balloon), CONNECT_ONE_SHOT)

func remove_balloon(owner_id: String) -> void:
	if owner_id.is_empty():
		return

	var balloon = balloons_by_owner.get(owner_id)
	balloons_by_owner.erase(owner_id)
	if is_instance_valid(balloon):
		if balloon.is_inside_tree():
			balloon.queue_free()
		else:
			balloon.set_meta("cancelled", true)

func _on_balloon_owner_tree_exiting(owner_id: String, balloon) -> void:
	_clear_balloon_reference(owner_id, balloon)
	if is_instance_valid(balloon) and balloon.is_inside_tree():
		balloon.queue_free()

func _on_balloon_tree_exited(owner_id: String, balloon) -> void:
	_clear_balloon_reference(owner_id, balloon)

func _clear_balloon_reference(owner_id: String, balloon) -> void:
	if owner_id != "" and balloons_by_owner.get(owner_id) == balloon:
		balloons_by_owner.erase(owner_id)

func _free_detached_balloon(balloon) -> void:
	if is_instance_valid(balloon) and not balloon.is_inside_tree():
		balloon.free()

func save_math_state(owner_id: String, data: Dictionary):
	math_state_by_owner[owner_id] = data.duplicate(true)
	previous_math_question_by_owner.erase(owner_id)

func get_math_state(owner_id: String) -> Dictionary:
	var data = math_state_by_owner.get(owner_id, {})
	return data.duplicate(true)

func reset_math_state_for_scene(scene_path: String) -> void:
	if scene_path.is_empty():
		return

	var owner_prefix := "%s:" % scene_path
	for owner_id in math_state_by_owner.keys():
		var owner_key := str(owner_id)
		if not owner_key.begins_with(owner_prefix):
			continue

		var saved_state = math_state_by_owner.get(owner_id, {})
		previous_math_question_by_owner[owner_id] = str(saved_state.get("question", ""))
		math_state_by_owner.erase(owner_id)

func get_previous_math_question(owner_id: String) -> String:
	return str(previous_math_question_by_owner.get(owner_id, ""))
