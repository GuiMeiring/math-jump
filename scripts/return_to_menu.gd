extends CanvasLayer

const MAIN_MENU_PATH := "res://scene/main_menu.tscn"
const CANCEL_BASE_COLOR := Color(0.28, 0.62, 0.93)
const CANCEL_HOVER_COLOR := Color(0.58, 0.86, 1.0)
const CONFIRM_BASE_COLOR := Color(0.82, 0.25, 0.25)
const CONFIRM_HOVER_COLOR := Color(1.0, 0.45, 0.4)
const BUTTON_BORDER_COLOR := Color(0.12, 0.2, 0.16)

@onready var menu_button: Button = $ScreenAnchor/MenuButton
@onready var confirmation: Control = $ScreenAnchor/Confirmation
@onready var cancel_button: Button = $ScreenAnchor/Confirmation/CenterContainer/DialogContainer/ContentMargin/Content/Buttons/CancelButton
@onready var confirm_button: Button = $ScreenAnchor/Confirmation/CenterContainer/DialogContainer/ContentMargin/Content/Buttons/ConfirmButton

var confirmation_open := false
var hovered_confirmation_button: Button = null

func _ready() -> void:
	menu_button.pressed.connect(_on_menu_button_pressed)
	cancel_button.pressed.connect(_close_confirmation)
	confirm_button.pressed.connect(_return_to_main_menu)
	_connect_confirmation_button_signals(cancel_button)
	_connect_confirmation_button_signals(confirm_button)
	confirmation.hide()

func _unhandled_input(event: InputEvent) -> void:
	if not confirmation_open:
		return

	if event.is_action_pressed("ui_cancel"):
		_close_confirmation()
		get_viewport().set_input_as_handled()

func _on_menu_button_pressed() -> void:
	if get_tree().paused:
		return

	confirmation_open = true
	confirmation.show()
	get_tree().paused = true
	cancel_button.grab_focus()

func _close_confirmation() -> void:
	if not confirmation_open:
		return

	confirmation_open = false
	confirmation.hide()
	get_tree().paused = false
	menu_button.grab_focus()

func _return_to_main_menu() -> void:
	confirmation_open = false
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_PATH)

func _connect_confirmation_button_signals(button: Button) -> void:
	button.mouse_entered.connect(_on_confirmation_button_mouse_entered.bind(button))
	button.mouse_exited.connect(_on_confirmation_button_mouse_exited.bind(button))
	button.focus_entered.connect(_refresh_confirmation_button.bind(button))
	button.focus_exited.connect(_refresh_confirmation_button.bind(button))
	_refresh_confirmation_button(button)

func _on_confirmation_button_mouse_entered(button: Button) -> void:
	hovered_confirmation_button = button
	_refresh_confirmation_button(button)

func _on_confirmation_button_mouse_exited(button: Button) -> void:
	if hovered_confirmation_button == button:
		hovered_confirmation_button = null
	_refresh_confirmation_button(button)

func _refresh_confirmation_button(button: Button) -> void:
	var base_color := CONFIRM_BASE_COLOR if button == confirm_button else CANCEL_BASE_COLOR
	var hover_color := CONFIRM_HOVER_COLOR if button == confirm_button else CANCEL_HOVER_COLOR
	var focus_style := StyleBoxFlat.new()
	focus_style.bg_color = hover_color if hovered_confirmation_button == button else base_color
	focus_style.border_width_left = 2
	focus_style.border_width_top = 2
	focus_style.border_width_right = 2
	focus_style.border_width_bottom = 2
	focus_style.border_color = BUTTON_BORDER_COLOR
	focus_style.corner_radius_top_left = 10
	focus_style.corner_radius_top_right = 10
	focus_style.corner_radius_bottom_right = 10
	focus_style.corner_radius_bottom_left = 10
	focus_style.content_margin_left = 8
	focus_style.content_margin_top = 3
	focus_style.content_margin_right = 8
	focus_style.content_margin_bottom = 3
	focus_style.shadow_color = Color(0.06, 0.11, 0.09, 0.35)
	focus_style.shadow_size = 5
	focus_style.shadow_offset = Vector2(0, 3)
	button.add_theme_stylebox_override("focus", focus_style)

func _exit_tree() -> void:
	if confirmation_open and get_tree() != null:
		get_tree().paused = false
