extends Control

const GAME_SCENE_PATH := "res://scene/tropic.tscn"
const PREVIEW_SCENE := preload("res://scene/tropic.tscn")
const MENU_FONT := preload("res://sprites/fonts/RevMiniPixel.ttf")

@onready var preview_viewport: SubViewport = $PreviewContainer/PreviewViewport
@onready var title_center: CenterContainer = $UiLayer/MainUi/TitleCenter
@onready var title_math: Label = $UiLayer/MainUi/TitleCenter/TitleContainer/TitleMath
@onready var title_jump: Label = $UiLayer/MainUi/TitleCenter/TitleContainer/TitleJump
@onready var buttons_center: CenterContainer = $UiLayer/MainUi/MenuButtonsCenter
@onready var start_button: Button = $UiLayer/MainUi/MenuButtonsCenter/MenuButtons/StartButton
@onready var controls_button: Button = $UiLayer/MainUi/MenuButtonsCenter/MenuButtons/ControlsButton
@onready var controls_center: CenterContainer = $UiLayer/MainUi/ControlsCenter
@onready var controls_panel: PanelContainer = $UiLayer/MainUi/ControlsCenter/ControlsPanel
@onready var controls_title: Label = $UiLayer/MainUi/ControlsCenter/ControlsPanel/PanelMargin/PanelContent/HeaderCenter/HeaderPanel/HeaderMargin/ControlsTitle
@onready var left_keys_value: Label = $UiLayer/MainUi/ControlsCenter/ControlsPanel/PanelMargin/PanelContent/ControlsGrid/LeftKeysValue
@onready var right_keys_value: Label = $UiLayer/MainUi/ControlsCenter/ControlsPanel/PanelMargin/PanelContent/ControlsGrid/RightKeysValue
@onready var jump_keys_value: Label = $UiLayer/MainUi/ControlsCenter/ControlsPanel/PanelMargin/PanelContent/ControlsGrid/JumpKeysValue
@onready var attack_keys_value: Label = $UiLayer/MainUi/ControlsCenter/ControlsPanel/PanelMargin/PanelContent/ControlsGrid/AttackKeysValue
@onready var back_keys_value: Label = $UiLayer/MainUi/ControlsCenter/ControlsPanel/PanelMargin/PanelContent/ControlsGrid/BackKeysValue
@onready var controls_hint: Label = $UiLayer/MainUi/ControlsCenter/ControlsPanel/PanelMargin/PanelContent/ControlsHint

func _ready() -> void:
	_setup_ui()
	_populate_controls()
	_show_main_menu()
	start_button.pressed.connect(_on_start_button_pressed)
	controls_button.pressed.connect(_on_controls_button_pressed)
	_build_static_preview()
	start_button.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if not controls_center.visible:
		return

	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		_show_main_menu()
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("ui_cancel"):
		_show_main_menu()
		get_viewport().set_input_as_handled()

func _build_static_preview() -> void:
	DialogManager.balloons_enabled = false
	var preview_scene: Node2D = PREVIEW_SCENE.instantiate()
	preview_viewport.add_child(preview_scene)
	await get_tree().process_frame
	await get_tree().process_frame

	var preview_camera := preview_scene.get_node_or_null("Camera") as Camera2D
	if preview_camera != null:
		preview_camera.position_smoothing_enabled = false

	for water_path in ["Parallax/2 - Waters/AnimatedSprite2D", "Parallax/2 - Waters/AnimatedSprite2D2"]:
		var water := preview_scene.get_node_or_null(water_path) as AnimatedSprite2D
		if water == null:
			continue

		water.stop()
	preview_scene.process_mode = Node.PROCESS_MODE_DISABLED
	preview_viewport.render_target_update_mode = SubViewport.UPDATE_DISABLED
	DialogManager.balloons_enabled = true

func _setup_ui() -> void:
	_style_title_label(title_math, Color(1.0, 0.81, 0.22), 36)
	_style_title_label(title_jump, Color(0.96, 0.96, 0.96), 34)
	_style_main_button(start_button, "START", Color(0.47, 0.82, 0.23), Color(0.56, 0.88, 0.29), Color(0.36, 0.69, 0.18))
	_style_main_button(controls_button, "CONTROLES", Color(0.26, 0.54, 0.91), Color(0.33, 0.61, 0.96), Color(0.2, 0.43, 0.78))
	_style_controls_panel()
	_style_controls_text()

func _style_title_label(label: Label, font_color: Color, font_size: int) -> void:
	label.add_theme_font_override("font", MENU_FONT)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", font_color)
	label.add_theme_color_override("font_outline_color", Color(0.22, 0.14, 0.16))
	label.add_theme_constant_override("outline_size", 6)

func _style_main_button(button: Button, button_text: String, base_color: Color, hover_color: Color, pressed_color: Color) -> void:
	button.text = button_text
	button.custom_minimum_size = Vector2(144, 27)
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_override("font", MENU_FONT)
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_color_override("font_color", Color(1, 1, 1))
	button.add_theme_color_override("font_hover_color", Color(1, 1, 1))
	button.add_theme_color_override("font_pressed_color", Color(1, 1, 1))
	button.add_theme_color_override("font_focus_color", Color(1, 1, 1))
	button.add_theme_stylebox_override("normal", _make_panel_style(base_color, Color(0.12, 0.2, 0.16), 2, 8, 3))
	button.add_theme_stylebox_override("hover", _make_panel_style(hover_color, Color(0.12, 0.2, 0.16), 2, 8, 3))
	button.add_theme_stylebox_override("pressed", _make_panel_style(pressed_color, Color(0.12, 0.2, 0.16), 2, 8, 3))
	button.add_theme_stylebox_override("focus", _make_panel_style(hover_color, Color(0.12, 0.2, 0.16), 2, 8, 3))
	button.add_theme_stylebox_override("disabled", _make_panel_style(base_color.darkened(0.35), Color(0.12, 0.2, 0.16), 2, 8, 3))
	button.add_theme_constant_override("h_separation", 6)
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT

	if button == start_button:
		button.icon = _make_start_icon()
	else:
		button.icon = _make_controls_icon()

func _style_controls_panel() -> void:
	controls_panel.custom_minimum_size = Vector2(326, 154)
	controls_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.97, 0.93, 0.84), Color(0.35, 0.23, 0.18), 3, 12, 10))

	var header_panel := $UiLayer/MainUi/ControlsCenter/ControlsPanel/PanelMargin/PanelContent/HeaderCenter/HeaderPanel as PanelContainer
	header_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.24, 0.44, 0.84), Color(0.13, 0.25, 0.5), 3, 14, 5))

	controls_title.add_theme_font_override("font", MENU_FONT)
	controls_title.add_theme_font_size_override("font_size", 15)
	controls_title.add_theme_color_override("font_color", Color(1, 1, 1))
	controls_title.add_theme_color_override("font_outline_color", Color(0.13, 0.19, 0.36))
	controls_title.add_theme_constant_override("outline_size", 3)
	controls_title.text = "TECLAS"

func _style_controls_text() -> void:
	var grid_labels := [
		left_keys_value,
		right_keys_value,
		jump_keys_value,
		attack_keys_value,
		back_keys_value
	]

	for label in grid_labels:
		label.add_theme_font_override("font", MENU_FONT)
		label.add_theme_font_size_override("font_size", 13)
		label.add_theme_color_override("font_color", Color(0.18, 0.39, 0.76))

	var action_labels := [
		$UiLayer/MainUi/ControlsCenter/ControlsPanel/PanelMargin/PanelContent/ControlsGrid/LeftActionLabel,
		$UiLayer/MainUi/ControlsCenter/ControlsPanel/PanelMargin/PanelContent/ControlsGrid/RightActionLabel,
		$UiLayer/MainUi/ControlsCenter/ControlsPanel/PanelMargin/PanelContent/ControlsGrid/JumpActionLabel,
		$UiLayer/MainUi/ControlsCenter/ControlsPanel/PanelMargin/PanelContent/ControlsGrid/AttackActionLabel,
		$UiLayer/MainUi/ControlsCenter/ControlsPanel/PanelMargin/PanelContent/ControlsGrid/BackActionLabel
	]

	for label in action_labels:
		label.add_theme_font_override("font", MENU_FONT)
		label.add_theme_font_size_override("font_size", 13)
		label.add_theme_color_override("font_color", Color(0.19, 0.16, 0.23))

	controls_hint.add_theme_font_override("font", MENU_FONT)
	controls_hint.add_theme_font_size_override("font_size", 11)
	controls_hint.add_theme_color_override("font_color", Color(0.24, 0.25, 0.34))
	controls_hint.text = "Pressione ESC para voltar"

func _populate_controls() -> void:
	left_keys_value.text = _format_action_bindings("left")
	right_keys_value.text = _format_action_bindings("right")
	jump_keys_value.text = _format_action_bindings("jump")
	attack_keys_value.text = _format_action_bindings("attack")
	back_keys_value.text = "ESC"

func _format_action_bindings(action_name: StringName) -> String:
	var labels := PackedStringArray()

	for event in InputMap.action_get_events(action_name):
		var key_event := event as InputEventKey
		if key_event == null:
			continue

		var key_label := _keycode_to_label(key_event.physical_keycode)
		if not labels.has(key_label):
			labels.append(key_label)

	if labels.is_empty():
		return "-"

	return " ou ".join(labels)

func _keycode_to_label(keycode: Key) -> String:
	match keycode:
		KEY_A:
			return "A"
		KEY_D:
			return "D"
		KEY_W:
			return "W"
		KEY_S:
			return "S"
		KEY_I:
			return "I"
		KEY_J:
			return "J"
		KEY_O:
			return "O"
		KEY_LEFT:
			return "←"
		KEY_RIGHT:
			return "→"
		KEY_UP:
			return "↑"
		KEY_DOWN:
			return "↓"
		KEY_SPACE:
			return "Espaco"
		KEY_ESCAPE:
			return "ESC"
		_:
			return str(keycode)

func _show_main_menu() -> void:
	title_center.show()
	buttons_center.show()
	controls_center.hide()
	start_button.grab_focus()

func _show_controls_menu() -> void:
	title_center.hide()
	buttons_center.hide()
	controls_center.show()

func _make_start_icon() -> Texture2D:
	var image := Image.create(12, 12, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var icon_color := Color(1, 1, 1, 1)

	for y in range(2, 10):
		for x in range(2, 10):
			if x <= 2 + (y - 2):
				image.set_pixel(x, y, icon_color)

	return ImageTexture.create_from_image(image)

func _make_controls_icon() -> Texture2D:
	var image := Image.create(12, 12, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var icon_color := Color(1, 1, 1, 1)

	for x in range(1, 11):
		image.set_pixel(x, 1, icon_color)
		image.set_pixel(x, 10, icon_color)

	for y in range(1, 11):
		image.set_pixel(1, y, icon_color)
		image.set_pixel(10, y, icon_color)

	for x in range(3, 5):
		for y in range(3, 5):
			image.set_pixel(x, y, icon_color)

	for x in range(6, 8):
		for y in range(3, 5):
			image.set_pixel(x, y, icon_color)

	for x in range(3, 9):
		image.set_pixel(x, 7, icon_color)
		image.set_pixel(x, 8, icon_color)

	return ImageTexture.create_from_image(image)

func _make_panel_style(
	background_color: Color,
	border_color: Color,
	border_width: int,
	horizontal_margin: int,
	vertical_margin: int
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background_color
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.border_color = border_color
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_right = 10
	style.corner_radius_bottom_left = 10
	style.content_margin_left = horizontal_margin
	style.content_margin_right = horizontal_margin
	style.content_margin_top = vertical_margin
	style.content_margin_bottom = vertical_margin
	return style

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE_PATH)

func _on_controls_button_pressed() -> void:
	_show_controls_menu()
