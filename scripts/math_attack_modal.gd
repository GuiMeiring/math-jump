extends Control

signal answered(target: Node, is_correct: bool, did_timeout: bool)

@export var total_time := 12.0
@export var option_default_font_color := Color(0, 0, 0, 1)
@export var option_selected_font_color := Color(0.698039, 0.172549, 0.129412, 1)

@onready var modal_root: Control = $ModalRoot
@onready var question_label: Label = $ModalRoot/CenterContainer/DialogContainer/ContentMargin/Content/QuestionLabel
@onready var timer_bar: ProgressBar = $ModalRoot/CenterContainer/DialogContainer/ContentMargin/Content/TimerGroup/TimerBar
@onready var countdown_label: Label = $ModalRoot/CenterContainer/DialogContainer/ContentMargin/Content/TimerGroup/CountdownLabel
@onready var option_buttons: Array[Button] = [
	$ModalRoot/CenterContainer/DialogContainer/ContentMargin/Content/Answers/OptionButton1,
	$ModalRoot/CenterContainer/DialogContainer/ContentMargin/Content/Answers/OptionButton2,
	$ModalRoot/CenterContainer/DialogContainer/ContentMargin/Content/Answers/OptionButton3
]

var target: Node
var correct_answer: int
var remaining_time := 0.0
var is_active := false
var focused_button_index := 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	expand_to_viewport()
	question_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	for index in range(option_buttons.size()):
		option_buttons[index].focus_entered.connect(_on_option_button_selected.bind(index))
		option_buttons[index].mouse_entered.connect(_on_option_button_selected.bind(index))
	hide()
	set_process(false)
	set_process_unhandled_input(true)

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		expand_to_viewport()

func open_modal(question_text: String, answer_options: Array, correct_option: int, enemy_target: Node) -> void:
	target = enemy_target
	correct_answer = correct_option
	remaining_time = total_time
	is_active = true
	focused_button_index = 0
	question_label.text = question_text
	apply_answer_options(answer_options)
	update_timer_ui()
	show()
	get_tree().paused = true
	set_process(true)
	focus_current_button()

func _process(delta: float) -> void:
	if not is_active:
		return

	remaining_time = max(remaining_time - delta, 0.0)
	update_timer_ui()

	if remaining_time <= 0.0:
		finish(false, true)

func apply_answer_options(answer_options: Array) -> void:
	for index in range(option_buttons.size()):
		var button = option_buttons[index]
		if index < answer_options.size():
			button.text = str(answer_options[index])
			button.set_meta("answer_value", answer_options[index])
			button.disabled = false
			button.show()
			continue

		button.text = ""
		button.remove_meta("answer_value")
		button.disabled = true
		button.hide()

	refresh_button_colors()

func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return

	if event is InputEventKey and event.echo:
		return

	if event.is_action_pressed("ui_up"):
		move_focus(-1)
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("ui_down"):
		move_focus(1)
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("ui_accept"):
		press_focused_button()
		get_viewport().set_input_as_handled()

func update_timer_ui() -> void:
	timer_bar.max_value = total_time
	timer_bar.value = remaining_time

	var countdown_value := maxi(int(ceil(remaining_time)), 0)
	countdown_label.visible = remaining_time <= 5.0
	countdown_label.text = str(countdown_value)

func expand_to_viewport() -> void:
	var viewport_size = get_viewport_rect().size
	position = Vector2.ZERO
	size = viewport_size

	if is_instance_valid(modal_root):
		modal_root.position = Vector2.ZERO
		modal_root.size = viewport_size

func move_focus(direction_step: int) -> void:
	var visible_buttons = get_visible_buttons()
	if visible_buttons.is_empty():
		return

	focused_button_index = posmod(focused_button_index + direction_step, visible_buttons.size())
	visible_buttons[focused_button_index].grab_focus()
	refresh_button_colors()

func focus_current_button() -> void:
	var visible_buttons = get_visible_buttons()
	if visible_buttons.is_empty():
		return

	focused_button_index = clampi(focused_button_index, 0, visible_buttons.size() - 1)
	visible_buttons[focused_button_index].grab_focus()
	refresh_button_colors()

func press_focused_button() -> void:
	var visible_buttons = get_visible_buttons()
	if visible_buttons.is_empty():
		return

	focused_button_index = clampi(focused_button_index, 0, visible_buttons.size() - 1)
	visible_buttons[focused_button_index].emit_signal("pressed")

func get_visible_buttons() -> Array[Button]:
	var visible_buttons: Array[Button] = []

	for button in option_buttons:
		if button.visible and not button.disabled:
			visible_buttons.append(button)

	return visible_buttons

func refresh_button_colors() -> void:
	var visible_buttons = get_visible_buttons()

	for button in option_buttons:
		button.add_theme_color_override("font_color", option_default_font_color)
		button.add_theme_color_override("font_hover_color", option_default_font_color)
		button.add_theme_color_override("font_pressed_color", option_default_font_color)
		button.add_theme_color_override("font_focus_color", option_default_font_color)

	if visible_buttons.is_empty():
		return

	focused_button_index = clampi(focused_button_index, 0, visible_buttons.size() - 1)
	var selected_button = visible_buttons[focused_button_index]
	selected_button.add_theme_color_override("font_color", option_selected_font_color)
	selected_button.add_theme_color_override("font_hover_color", option_selected_font_color)
	selected_button.add_theme_color_override("font_pressed_color", option_selected_font_color)
	selected_button.add_theme_color_override("font_focus_color", option_selected_font_color)

func _on_option_button_selected(button_index: int) -> void:
	focused_button_index = button_index
	refresh_button_colors()

func submit_answer(button_index: int) -> void:
	if button_index < 0 or button_index >= option_buttons.size():
		return

	var selected_answer = option_buttons[button_index].get_meta("answer_value", null)
	if selected_answer == null:
		return

	finish(selected_answer == correct_answer, false)

func finish(is_correct: bool, did_timeout: bool) -> void:
	if not is_active:
		return

	is_active = false
	set_process(false)
	get_tree().paused = false
	answered.emit(target, is_correct, did_timeout)
	queue_free()

func _exit_tree() -> void:
	if is_active and get_tree() != null:
		get_tree().paused = false

func _on_option_button_1_pressed() -> void:
	submit_answer(0)

func _on_option_button_2_pressed() -> void:
	submit_answer(1)

func _on_option_button_3_pressed() -> void:
	submit_answer(2)
