extends Control

signal answered(target: Node, is_correct: bool, did_timeout: bool)

@export var total_time := 12.0

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

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	question_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	hide()
	set_process(false)

func open_modal(question_text: String, answer_options: Array, correct_option: int, enemy_target: Node) -> void:
	target = enemy_target
	correct_answer = correct_option
	remaining_time = total_time
	is_active = true
	question_label.text = question_text
	apply_answer_options(answer_options)
	update_timer_ui()
	show()
	get_tree().paused = true
	set_process(true)

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
			button.disabled = false
			button.show()
			continue

		button.text = ""
		button.disabled = true
		button.hide()

func update_timer_ui() -> void:
	timer_bar.max_value = total_time
	timer_bar.value = remaining_time

	var countdown_value := maxi(int(ceil(remaining_time)), 0)
	countdown_label.visible = remaining_time <= 5.0
	countdown_label.text = str(countdown_value)

func submit_answer(button_index: int) -> void:
	if button_index < 0 or button_index >= option_buttons.size():
		return

	var selected_answer = int(option_buttons[button_index].text)
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
