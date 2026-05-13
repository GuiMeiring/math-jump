extends Control

const GAME_SCENE_PATH := "res://scene/tropic.tscn"
const PREVIEW_SCENE := preload("res://scene/tropic.tscn")
const PLAYER_IDLE_TEXTURE := preload("res://sprites/Sprite Pack 7/3 - Gordon/Idle (48 x 48).png")
const SKELETON_WALK_TEXTURE := preload("res://sprites/Sprite Pack 6/3 - Skeleton/Limping_Movement (32 x 32).png")
const HEART_TEXTURE := preload("res://sprites/Mini FX, Items & UI/Common Pick-ups/Heart_Spin (16 x 16).png")
const MENU_FONT := preload("res://sprites/fonts/RevMiniPixel.ttf")

@onready var preview_root: Node2D = $PreviewRoot
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
@onready var hud_decor: Node2D = $UiLayer/MainUi/HudDecor

func _ready() -> void:
	_build_static_preview()
	_setup_ui()
	_populate_controls()
	_show_main_menu()
	start_button.pressed.connect(_on_start_button_pressed)
	controls_button.pressed.connect(_on_controls_button_pressed)
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
	var preview_scene: Node2D = PREVIEW_SCENE.instantiate()

	for node_name in ["Camera", "Player", "Skeleton", "Skeleton2", "warning_sign"]:
		var node := preview_scene.get_node_or_null(node_name)
		if node != null:
			node.free()

	preview_root.add_child(preview_scene)

	for water_path in ["Parallax/2 - Waters/AnimatedSprite2D", "Parallax/2 - Waters/AnimatedSprite2D2"]:
		var water := preview_scene.get_node_or_null(water_path) as AnimatedSprite2D
		if water == null:
			continue

		water.stop()
		water.frame = 0

	_add_preview_player()
	_add_preview_skeleton()
	_add_preview_hearts()

func _add_preview_player() -> void:
	var player_sprite := Sprite2D.new()
	player_sprite.texture = _make_atlas_texture(PLAYER_IDLE_TEXTURE, Rect2(48, 0, 48, 48))
	player_sprite.position = Vector2(98, 160)
	player_sprite.scale = Vector2(1.45, 1.45)
	player_sprite.z_index = 4
	preview_root.add_child(player_sprite)

func _add_preview_skeleton() -> void:
	var skeleton_sprite := Sprite2D.new()
	skeleton_sprite.texture = _make_atlas_texture(SKELETON_WALK_TEXTURE, Rect2(64, 0, 32, 32))
	skeleton_sprite.position = Vector2(332, 163)
	skeleton_sprite.scale = Vector2(-1.5, 1.5)
	skeleton_sprite.z_index = 4
	preview_root.add_child(skeleton_sprite)

func _add_preview_hearts() -> void:
	for heart_index in range(3):
		var heart_sprite := Sprite2D.new()
		heart_sprite.texture = _make_atlas_texture(HEART_TEXTURE, Rect2(0, 0, 16, 16))
		heart_sprite.position = Vector2(24 + heart_index * 22, 18)
		heart_sprite.scale = Vector2(1.45, 1.45)
		hud_decor.add_child(heart_sprite)

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
	button.custom_minimum_size = Vector2(172, 38)
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_override("font", MENU_FONT)
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", Color(1, 1, 1))
	button.add_theme_color_override("font_hover_color", Color(1, 1, 1))
	button.add_theme_color_override("font_pressed_color", Color(1, 1, 1))
	button.add_theme_color_override("font_focus_color", Color(1, 1, 1))
	button.add_theme_stylebox_override("normal", _make_panel_style(base_color, Color(0.12, 0.2, 0.16), 6, 12, 6))
	button.add_theme_stylebox_override("hover", _make_panel_style(hover_color, Color(0.12, 0.2, 0.16), 6, 12, 6))
	button.add_theme_stylebox_override("pressed", _make_panel_style(pressed_color, Color(0.12, 0.2, 0.16), 6, 12, 6))
	button.add_theme_stylebox_override("focus", _make_panel_style(hover_color, Color(0.12, 0.2, 0.16), 6, 12, 6))
	button.add_theme_stylebox_override("disabled", _make_panel_style(base_color.darkened(0.35), Color(0.12, 0.2, 0.16), 6, 12, 6))

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
	hud_decor.show()
	start_button.grab_focus()

func _show_controls_menu() -> void:
	title_center.hide()
	buttons_center.hide()
	controls_center.show()
	hud_decor.hide()

func _make_atlas_texture(texture: Texture2D, region: Rect2) -> AtlasTexture:
	var atlas_texture := AtlasTexture.new()
	atlas_texture.atlas = texture
	atlas_texture.region = region
	return atlas_texture

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
