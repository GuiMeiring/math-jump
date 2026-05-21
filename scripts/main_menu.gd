extends Control

const GAME_SCENE_PATH := "res://scene/tropic.tscn"
const PREVIEW_SCENE := preload("res://scene/tropic.tscn")
const MENU_FONT := preload("res://sprites/fonts/RevMiniPixel.ttf")
const CONTROLS_BORDER_COLOR := Color(0.12, 0.2, 0.16)
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
@onready var controls_list: GridContainer = $UiLayer/MainUi/ControlsCenter/ControlsPanel/PanelMargin/ControlsScroll/ControlsList

var controls_back_button_hover_tween: Tween

func _ready() -> void:
	_setup_ui()
	_setup_focus_navigation()
	_populate_controls()
	_show_main_menu()
	_connect_main_menu_button_state_signals(start_button)
	_connect_main_menu_button_state_signals(controls_button)
	start_button.pressed.connect(_on_start_button_pressed)
	controls_button.pressed.connect(_on_controls_button_pressed)
	controls_back_button.pressed.connect(_on_controls_back_button_pressed)
	controls_back_button.mouse_entered.connect(_on_controls_back_button_mouse_entered)
	controls_back_button.mouse_exited.connect(_on_controls_back_button_mouse_exited)
	_build_static_preview()
	start_button.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if buttons_center.visible:
		if _handle_main_menu_navigation_input(event):
			get_viewport().set_input_as_handled()
		return

	if not controls_center.visible:
		return

	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		_show_main_menu()
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("ui_cancel"):
		_show_main_menu()
		get_viewport().set_input_as_handled()

func _handle_main_menu_navigation_input(event: InputEvent) -> bool:
	var key_event := event as InputEventKey
	if key_event == null or not key_event.pressed or key_event.echo:
		return false

	match key_event.physical_keycode:
		KEY_W:
			_move_main_menu_focus(-1)
			return true
		KEY_S:
			_move_main_menu_focus(1)
			return true
		_:
			return false

func _move_main_menu_focus(direction: int) -> void:
	var menu_buttons: Array[Button] = [start_button, controls_button]
	var current_index := 0

	for index in range(menu_buttons.size()):
		if menu_buttons[index].has_focus():
			current_index = index
			break

	var next_index := posmod(current_index + direction, menu_buttons.size())
	menu_buttons[next_index].grab_focus()

func _build_static_preview() -> void:
	DialogManager.balloons_enabled = false
	var preview_scene: Node2D = PREVIEW_SCENE.instantiate()
	_hide_preview_gameplay_ui(preview_scene)
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

func _hide_preview_gameplay_ui(preview_scene: Node) -> void:
	for node_path in ["ControlGuide", "Player/HealthLayer", "Player/AttackFeedbackLayer"]:
		var ui_node := preview_scene.get_node_or_null(node_path)
		if ui_node == null:
			continue

		_hide_canvas_items(ui_node)

func _hide_canvas_items(node: Node) -> void:
	var canvas_item := node as CanvasItem
	if canvas_item != null:
		canvas_item.hide()

	for child in node.get_children():
		_hide_canvas_items(child)

func _setup_ui() -> void:
	_style_title_label(title_math, Color(1.0, 0.81, 0.22), 36)
	_style_title_label(title_jump, Color(0.96, 0.96, 0.96), 34)
	_style_main_button(start_button, "START", Color(0.47, 0.82, 0.23), Color(0.76, 0.95, 0.36), Color(0.36, 0.69, 0.18))
	_style_main_button(controls_button, "CONTROLES", Color(0.26, 0.54, 0.91), Color(0.33, 0.61, 0.96), Color(0.2, 0.43, 0.78))
	_style_controls_header()
	_style_controls_panel()

func _setup_focus_navigation() -> void:
	start_button.focus_neighbor_bottom = start_button.get_path_to(controls_button)
	start_button.focus_next = start_button.get_path_to(controls_button)
	start_button.focus_neighbor_top = start_button.get_path_to(controls_button)
	start_button.focus_previous = start_button.get_path_to(controls_button)

	controls_button.focus_neighbor_top = controls_button.get_path_to(start_button)
	controls_button.focus_previous = controls_button.get_path_to(start_button)
	controls_button.focus_neighbor_bottom = controls_button.get_path_to(start_button)
	controls_button.focus_next = controls_button.get_path_to(start_button)

	controls_back_button.focus_neighbor_left = NodePath(".")
	controls_back_button.focus_neighbor_right = NodePath(".")
	controls_back_button.focus_neighbor_top = NodePath(".")
	controls_back_button.focus_neighbor_bottom = NodePath(".")
	controls_back_button.focus_next = NodePath(".")
	controls_back_button.focus_previous = NodePath(".")

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
	button.pivot_offset = button.custom_minimum_size * 0.5
	button.set_meta("base_color", base_color)
	button.set_meta("hover_color", hover_color)
	button.set_meta("pressed_color", pressed_color)
	button.add_theme_font_override("font", MENU_FONT)
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_color_override("font_color", Color(1, 1, 1))
	button.add_theme_color_override("font_hover_color", Color(1, 1, 1))
	button.add_theme_color_override("font_pressed_color", Color(1, 1, 1))
	button.add_theme_color_override("font_focus_color", Color(1, 1, 1))
	_refresh_main_menu_button_visual(button)
	button.add_theme_stylebox_override("disabled", _make_panel_style(base_color.darkened(0.35), Color(0.12, 0.2, 0.16), 2, 8, 3))
	button.add_theme_constant_override("h_separation", 6)
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT

	if button == start_button:
		button.icon = _make_start_icon()
	else:
		button.icon = _make_controls_icon()

func _connect_main_menu_button_state_signals(button: Button) -> void:
	button.mouse_entered.connect(_on_main_menu_button_mouse_entered.bind(button))
	button.mouse_exited.connect(_on_main_menu_button_mouse_exited.bind(button))
	button.focus_entered.connect(_on_main_menu_button_focus_entered.bind(button))
	button.focus_exited.connect(_on_main_menu_button_focus_exited.bind(button))

func _refresh_main_menu_button_visual(button: Button) -> void:
	var base_color := button.get_meta("base_color", Color.WHITE) as Color
	var hover_color := button.get_meta("hover_color", Color.WHITE) as Color
	var pressed_color := button.get_meta("pressed_color", Color.WHITE) as Color
	var is_hovered := button.get_global_rect().has_point(button.get_global_mouse_position())
	var background_color := hover_color if is_hovered else base_color

	var normal_style := _make_panel_style(background_color, Color(0.12, 0.2, 0.16), 2, 8, 3)
	var focus_style := _make_panel_style(background_color, Color(0.12, 0.2, 0.16), 2, 8, 3)
	focus_style.shadow_color = Color(0.06, 0.11, 0.09, 0.35)
	focus_style.shadow_size = 5
	focus_style.shadow_offset = Vector2(0, 3)

	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", normal_style.duplicate())
	button.add_theme_stylebox_override("pressed", _make_panel_style(pressed_color, Color(0.12, 0.2, 0.16), 2, 8, 3))
	button.add_theme_stylebox_override("focus", focus_style)

func _style_controls_header() -> void:
	controls_back_button.text = ""
	controls_back_button.custom_minimum_size = Vector2(30, 30)
	controls_back_button.focus_mode = Control.FOCUS_ALL
	controls_back_button.pivot_offset = controls_back_button.custom_minimum_size * 0.5
	controls_back_button.icon = _make_back_icon()
	controls_back_button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls_back_button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	controls_back_button.add_theme_stylebox_override("normal", _make_panel_style(Color(0.24, 0.56, 0.92), CONTROLS_BORDER_COLOR, 2, 6, 6))
	controls_back_button.add_theme_stylebox_override("hover", _make_panel_style(Color(0.31, 0.63, 0.97), CONTROLS_BORDER_COLOR, 2, 6, 6))
	controls_back_button.add_theme_stylebox_override("pressed", _make_panel_style(Color(0.19, 0.48, 0.83), CONTROLS_BORDER_COLOR, 2, 6, 6))
	controls_back_button.add_theme_stylebox_override("focus", _make_panel_style(Color(0.31, 0.63, 0.97), CONTROLS_BORDER_COLOR, 2, 6, 6))

	var header_panel := $UiLayer/MainUi/ControlsCenter/HeaderCenter/HeaderPanel as PanelContainer
	header_panel.custom_minimum_size = Vector2(168, 30)
	header_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.24, 0.56, 0.92), CONTROLS_BORDER_COLOR, 2, 18, 5))

	controls_title.add_theme_font_override("font", MENU_FONT)
	controls_title.add_theme_font_size_override("font_size", 12)
	controls_title.add_theme_color_override("font_color", Color(1, 1, 1))
	controls_title.add_theme_color_override("font_outline_color", Color(0.13, 0.19, 0.36))
	controls_title.add_theme_constant_override("outline_size", 2)
	controls_title.text = "CONTROLES"

func _style_controls_panel() -> void:
	controls_panel.add_theme_stylebox_override("panel", _make_panel_style(Color(0.97, 0.93, 0.84), CONTROLS_BORDER_COLOR, 2, 12, 10))
	controls_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	controls_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	controls_list.columns = 2
	controls_list.add_theme_constant_override("h_separation", 16)
	controls_list.add_theme_constant_override("v_separation", 8)

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
	row.custom_minimum_size = Vector2(126, 24)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 6)

	var keys_container := HBoxContainer.new()
	keys_container.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	keys_container.add_theme_constant_override("separation", 4)

	for index in range(key_labels.size()):
		if index > 0:
			keys_container.add_child(_create_or_label())
		keys_container.add_child(_create_key_badge(key_labels[index]))

	var action_label := Label.new()
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

func _animate_controls_back_button(is_hovered: bool) -> void:
	if controls_back_button_hover_tween != null:
		controls_back_button_hover_tween.kill()

	controls_back_button_hover_tween = create_tween()
	controls_back_button_hover_tween.set_trans(Tween.TRANS_SINE)
	controls_back_button_hover_tween.set_ease(Tween.EASE_OUT)

	var target_modulate := Color(1.08, 1.08, 1.08, 1.0) if is_hovered else Color(1, 1, 1, 1)
	controls_back_button_hover_tween.tween_property(controls_back_button, "modulate", target_modulate, 0.12)

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

func _on_controls_back_button_mouse_entered() -> void:
	_animate_controls_back_button(true)

func _on_controls_back_button_mouse_exited() -> void:
	_animate_controls_back_button(false)

func _on_main_menu_button_mouse_entered(button: Button) -> void:
	_refresh_main_menu_button_visual(button)

func _on_main_menu_button_mouse_exited(button: Button) -> void:
	_refresh_main_menu_button_visual(button)

func _on_main_menu_button_focus_entered(button: Button) -> void:
	_refresh_main_menu_button_visual(button)

func _on_main_menu_button_focus_exited(button: Button) -> void:
	_refresh_main_menu_button_visual(button)
