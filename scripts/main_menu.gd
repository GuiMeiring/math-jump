extends Control

const GAME_SCENE_PATH := "res://scene/tropic.tscn"
const PREVIEW_SCENE := preload("res://scene/tropic.tscn")
const MENU_FONT := preload("res://sprites/fonts/RevMiniPixel.ttf")
const CONTROL_ENTRIES := [
	{"action": &"left", "label": "Esquerda"},
	{"action": &"right", "label": "Direita"},
	{"action": &"jump", "label": "Pular"},
	{"action": &"duck", "label": "Abaixar"},
	{"action": &"attack", "label": "Atacar"},
	{"action": &"interact", "label": "Interagir"},
	{"action": &"advance_message", "label": "Avancar"},
	{"keys": ["ESC"], "label": "Voltar"}
]

@onready var preview_viewport: SubViewport = $PreviewContainer/PreviewViewport
@onready var title_center: CenterContainer = $UiLayer/MainUi/TitleCenter
@onready var title_math: Label = $UiLayer/MainUi/TitleCenter/TitleContainer/TitleMath
@onready var title_jump: Label = $UiLayer/MainUi/TitleCenter/TitleContainer/TitleJump
@onready var buttons_center: CenterContainer = $UiLayer/MainUi/MenuButtonsCenter
@onready var start_button: Button = $UiLayer/MainUi/MenuButtonsCenter/MenuButtons/StartButton
@onready var controls_button: Button = $UiLayer/MainUi/MenuButtonsCenter/MenuButtons/ControlsButton
@onready var controls_center: Control = $UiLayer/MainUi/ControlsCenter
@onready var controls_back_button: Button = $UiLayer/MainUi/ControlsCenter/BackButton
@onready var controls_panel: PanelContainer = $UiLayer/MainUi/ControlsCenter/ControlsPanel
@onready var controls_title: Label = $UiLayer/MainUi/ControlsCenter/HeaderCenter/HeaderPanel/HeaderMargin/ControlsTitle
@onready var controls_scroll: ScrollContainer = $UiLayer/MainUi/ControlsCenter/ControlsPanel/PanelMargin/ControlsScroll
@onready var controls_list: VBoxContainer = $UiLayer/MainUi/ControlsCenter/ControlsPanel/PanelMargin/ControlsScroll/ControlsList

func _ready() -> void:
	_setup_ui()
	_populate_controls()
	_show_main_menu()
	start_button.pressed.connect(_on_start_button_pressed)
	controls_button.pressed.connect(_on_controls_button_pressed)
	controls_back_button.pressed.connect(_on_controls_back_button_pressed)
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
	_style_controls_header()
	_style_controls_panel()

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

func _style_controls_header() -> void:
	controls_back_button.text = ""
	controls_back_button.custom_minimum_size = Vector2(30, 30)
	controls_back_button.focus_mode = Control.FOCUS_ALL
	controls_back_button.icon = _make_back_icon()
	controls_back_button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls_back_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls_back_button.add_theme_stylebox_override("normal", _make_panel_style(Color(0.24, 0.56, 0.92), Color(0.12, 0.25, 0.49), 3, 6, 6))
	controls_back_button.add_theme_stylebox_override("hover", _make_panel_style(Color(0.31, 0.63, 0.97), Color(0.12, 0.25, 0.49), 3, 6, 6))
	controls_back_button.add_theme_stylebox_override("pressed", _make_panel_style(Color(0.19, 0.48, 0.83), Color(0.12, 0.25, 0.49), 3, 6, 6))
	controls_back_button.add_theme_stylebox_override("focus", _make_panel_style(Color(0.31, 0.63, 0.97), Color(0.12, 0.25, 0.49), 3, 6, 6))

	var header_panel := $UiLayer/MainUi/ControlsCenter/HeaderCenter/HeaderPanel as PanelContainer
	header_panel.custom_minimum_size = Vector2(168, 30)
	header_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.24, 0.56, 0.92), Color(0.12, 0.25, 0.49), 3, 18, 5))

	controls_title.add_theme_font_override("font", MENU_FONT)
	controls_title.add_theme_font_size_override("font_size", 12)
	controls_title.add_theme_color_override("font_color", Color(1, 1, 1))
	controls_title.add_theme_color_override("font_outline_color", Color(0.13, 0.19, 0.36))
	controls_title.add_theme_constant_override("outline_size", 2)
	controls_title.text = "CONTROLES"

func _style_controls_panel() -> void:
	controls_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.97, 0.93, 0.84), Color(0.35, 0.23, 0.18), 3, 12, 10))
	controls_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	controls_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO

	var v_scroll_bar := controls_scroll.get_v_scroll_bar()
	v_scroll_bar.custom_minimum_size = Vector2(3, 0)
	v_scroll_bar.add_theme_stylebox_override("scroll", _make_scrollbar_style(Color(0.78, 0.75, 0.69), 6))
	v_scroll_bar.add_theme_stylebox_override("grabber", _make_scrollbar_style(Color(0.47, 0.45, 0.42), 6))
	v_scroll_bar.add_theme_stylebox_override("grabber_highlight", _make_scrollbar_style(Color(0.41, 0.39, 0.36), 6))
	v_scroll_bar.add_theme_stylebox_override("grabber_pressed", _make_scrollbar_style(Color(0.35, 0.33, 0.31), 6))

func _populate_controls() -> void:
	for child in controls_list.get_children():
		child.queue_free()

	for entry in CONTROL_ENTRIES:
		controls_list.add_child(_create_control_row(_get_entry_bindings(entry), str(entry["label"])))

func _get_entry_bindings(entry: Dictionary) -> PackedStringArray:
	if entry.has("keys"):
		var labels := PackedStringArray()
		for key_label in entry["keys"]:
			labels.append(str(key_label))
		return labels

	return _get_action_binding_labels(entry.get("action", &"") as StringName)

func _get_action_binding_labels(action_name: StringName) -> PackedStringArray:
	if action_name.is_empty() or not InputMap.has_action(action_name):
		return PackedStringArray(["-"])

	var labels := PackedStringArray()

	for event in InputMap.action_get_events(action_name):
		var key_event := event as InputEventKey
		if key_event == null:
			continue

		var key_label := _keycode_to_label(key_event.physical_keycode)
		if not labels.has(key_label):
			labels.append(key_label)

	if labels.is_empty():
		return PackedStringArray(["-"])

	return labels

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
			return String.chr(0x2190)
		KEY_RIGHT:
			return String.chr(0x2192)
		KEY_UP:
			return String.chr(0x2191)
		KEY_DOWN:
			return String.chr(0x2193)
		KEY_SPACE:
			return "Espaco"
		KEY_ESCAPE:
			return "ESC"
		_:
			return str(keycode)

func _create_control_row(key_labels: PackedStringArray, action_text: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 24)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 6)

	var keys_container := HBoxContainer.new()
	keys_container.custom_minimum_size = Vector2(112, 0)
	keys_container.add_theme_constant_override("separation", 4)

	for index in range(key_labels.size()):
		if index > 0:
			keys_container.add_child(_create_or_label())
		keys_container.add_child(_create_key_badge(key_labels[index]))

	var action_label := Label.new()
	action_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	action_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	action_label.add_theme_font_override("font", MENU_FONT)
	action_label.add_theme_font_size_override("font_size", 8)
	action_label.add_theme_color_override("font_color", Color(0.19, 0.16, 0.23))
	action_label.text = action_text

	row.add_child(keys_container)
	row.add_child(action_label)
	return row

func _create_key_badge(key_text: String) -> PanelContainer:
	var key_panel := PanelContainer.new()
	var is_arrow_key := (
		key_text == String.chr(0x2190)
		or key_text == String.chr(0x2191)
		or key_text == String.chr(0x2192)
		or key_text == String.chr(0x2193)
	)
	var is_small_key := key_text.length() <= 1 or is_arrow_key
	var badge_width := 0.0
	var badge_height := 22.0

	if is_small_key:
		badge_width = 22.0
	else:
		badge_width = maxf(54.0, 12.0 + float(key_text.length()) * 5.0)

	key_panel.custom_minimum_size = Vector2(badge_width, badge_height)
	key_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	key_panel.add_theme_stylebox_override(
		"panel",
		_make_badge_style(
			Color(0.34, 0.58, 0.93),
			Color(0.12, 0.25, 0.49),
			2,
			4,
			3,
			6
		)
	)

	var key_label := Label.new()
	key_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	key_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	key_label.add_theme_font_override("font", MENU_FONT)
	key_label.add_theme_font_size_override("font_size", 9 if is_arrow_key else 7)
	key_label.add_theme_color_override("font_color", Color(1, 1, 1))
	key_label.add_theme_color_override("font_outline_color", Color(0.13, 0.19, 0.36))
	key_label.add_theme_constant_override("outline_size", 1)
	key_label.text = key_text
	key_panel.add_child(key_label)

	return key_panel

func _create_or_label() -> Label:
	var or_label := Label.new()
	or_label.custom_minimum_size = Vector2(14, 0)
	or_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	or_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	or_label.add_theme_font_override("font", MENU_FONT)
	or_label.add_theme_font_size_override("font_size", 6)
	or_label.add_theme_color_override("font_color", Color(0.19, 0.16, 0.23))
	or_label.text = "ou"
	return or_label

func _show_main_menu() -> void:
	title_center.show()
	buttons_center.show()
	controls_center.hide()
	start_button.grab_focus()

func _show_controls_menu() -> void:
	title_center.hide()
	buttons_center.hide()
	controls_center.show()
	controls_scroll.scroll_vertical = 0
	controls_back_button.grab_focus()

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

func _make_back_icon() -> Texture2D:
	var image := Image.create(12, 12, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var icon_color := Color(1, 1, 1, 1)

	for x in range(3, 10):
		image.set_pixel(x, 5, icon_color)
		image.set_pixel(x, 6, icon_color)

	image.set_pixel(2, 5, icon_color)
	image.set_pixel(2, 6, icon_color)
	image.set_pixel(3, 4, icon_color)
	image.set_pixel(3, 7, icon_color)
	image.set_pixel(4, 3, icon_color)
	image.set_pixel(4, 8, icon_color)
	image.set_pixel(5, 2, icon_color)
	image.set_pixel(5, 9, icon_color)

	return ImageTexture.create_from_image(image)

func _make_scrollbar_style(background_color: Color, corner_radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background_color
	style.corner_radius_top_left = corner_radius
	style.corner_radius_top_right = corner_radius
	style.corner_radius_bottom_right = corner_radius
	style.corner_radius_bottom_left = corner_radius
	return style

func _make_badge_style(
	background_color: Color,
	border_color: Color,
	border_width: int,
	horizontal_margin: int,
	vertical_margin: int,
	corner_radius: int
) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background_color
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.border_color = border_color
	style.corner_radius_top_left = corner_radius
	style.corner_radius_top_right = corner_radius
	style.corner_radius_bottom_right = corner_radius
	style.corner_radius_bottom_left = corner_radius
	style.content_margin_left = horizontal_margin
	style.content_margin_right = horizontal_margin
	style.content_margin_top = vertical_margin
	style.content_margin_bottom = vertical_margin
	return style

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

func _on_controls_back_button_pressed() -> void:
	_show_main_menu()
