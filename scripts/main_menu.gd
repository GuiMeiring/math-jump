extends Control

const TROPIC_SCENE_PATH := "res://scene/tropic.tscn"
const ICE_SCENE_PATH := "res://scene/ice.tscn"
const PREVIEW_SCENE_PATH := TROPIC_SCENE_PATH
const MENU_FONT := preload("res://sprites/fonts/RevMiniPixel.ttf")

@onready var preview_viewport: SubViewport = $PreviewContainer/PreviewViewport
@onready var title_center: CenterContainer = $UiLayer/MainUi/TitleCenter
@onready var title_math: Label = $UiLayer/MainUi/TitleCenter/TitleContainer/TitleMath
@onready var title_jump: Label = $UiLayer/MainUi/TitleCenter/TitleContainer/TitleJump
@onready var buttons_center: CenterContainer = $UiLayer/MainUi/MenuButtonsCenter
@onready var start_button: Button = $UiLayer/MainUi/MenuButtonsCenter/MenuButtons/StartButton
@onready var map_buttons_center: CenterContainer = $UiLayer/MainUi/MapButtonsCenter
@onready var map_title: Label = $UiLayer/MainUi/MapButtonsCenter/MapButtons/MapTitle
@onready var tropical_button: Button = $UiLayer/MainUi/MapButtonsCenter/MapButtons/TropicalButton
@onready var ice_button: Button = $UiLayer/MainUi/MapButtonsCenter/MapButtons/IceButton
@onready var back_button: Button = $UiLayer/MainUi/MapButtonsCenter/MapButtons/BackButton

var hovered_menu_button: Button = null

func _ready() -> void:
	_setup_ui()
	_setup_focus_navigation()
	_show_main_menu()
	_connect_menu_button_state_signals(start_button)
	_connect_menu_button_state_signals(tropical_button)
	_connect_menu_button_state_signals(ice_button)
	_connect_menu_button_state_signals(back_button)
	start_button.pressed.connect(_on_start_button_pressed)
	tropical_button.pressed.connect(_on_tropical_button_pressed)
	ice_button.pressed.connect(_on_ice_button_pressed)
	back_button.pressed.connect(_show_main_menu)
	_build_static_preview()
	start_button.grab_focus()

func _input(event: InputEvent) -> void:
	if not buttons_center.visible and not map_buttons_center.visible:
		return

	var key_event := event as InputEventKey
	if key_event == null:
		return

	var viewport := get_viewport()
	if viewport != null:
		viewport.set_input_as_handled()

	if key_event.pressed and not key_event.echo:
		if map_buttons_center.visible:
			_handle_map_menu_key_input(key_event)
		else:
			_handle_main_menu_key_input(key_event)

func _handle_main_menu_key_input(key_event: InputEventKey) -> void:
	if key_event.physical_keycode == KEY_TAB or key_event.keycode == KEY_TAB:
		start_button.grab_focus()
		return

	var is_enter := (
		key_event.physical_keycode == KEY_ENTER
		or key_event.physical_keycode == KEY_KP_ENTER
		or key_event.keycode == KEY_ENTER
		or key_event.keycode == KEY_KP_ENTER
	)
	var is_space := key_event.physical_keycode == KEY_SPACE or key_event.keycode == KEY_SPACE
	if is_enter or is_space:
		_on_start_button_pressed()

func _handle_map_menu_key_input(key_event: InputEventKey) -> void:
	if key_event.physical_keycode == KEY_TAB or key_event.keycode == KEY_TAB:
		tropical_button.grab_focus()
		return

	if key_event.physical_keycode == KEY_UP or key_event.keycode == KEY_UP:
		_focus_previous_map_button()
		return

	if key_event.physical_keycode == KEY_DOWN or key_event.keycode == KEY_DOWN:
		_focus_next_map_button()
		return

	var is_enter := (
		key_event.physical_keycode == KEY_ENTER
		or key_event.physical_keycode == KEY_KP_ENTER
		or key_event.keycode == KEY_ENTER
		or key_event.keycode == KEY_KP_ENTER
	)
	var is_space := key_event.physical_keycode == KEY_SPACE or key_event.keycode == KEY_SPACE
	if not is_enter and not is_space:
		return

	var focused_control := get_viewport().gui_get_focus_owner()
	if focused_control == ice_button:
		_on_ice_button_pressed()
	elif focused_control == back_button:
		_show_main_menu()
	else:
		_on_tropical_button_pressed()

func _focus_previous_map_button() -> void:
	var focused_control := get_viewport().gui_get_focus_owner()
	if focused_control == tropical_button:
		back_button.grab_focus()
	elif focused_control == back_button:
		ice_button.grab_focus()
	else:
		tropical_button.grab_focus()

func _focus_next_map_button() -> void:
	var focused_control := get_viewport().gui_get_focus_owner()
	if focused_control == tropical_button:
		ice_button.grab_focus()
	elif focused_control == ice_button:
		back_button.grab_focus()
	else:
		tropical_button.grab_focus()

func _build_static_preview() -> void:
	var preview_scene_resource := load(PREVIEW_SCENE_PATH) as PackedScene
	if preview_scene_resource == null:
		push_warning("Could not load menu preview scene: %s" % PREVIEW_SCENE_PATH)
		return

	DialogManager.balloons_enabled = false
	var preview_scene := preview_scene_resource.instantiate() as Node2D
	if preview_scene == null:
		push_warning("Menu preview scene root must be a Node2D: %s" % PREVIEW_SCENE_PATH)
		DialogManager.balloons_enabled = true
		return

	_configure_preview_scene(preview_scene)
	_hide_preview_gameplay_ui(preview_scene)
	preview_viewport.add_child(preview_scene)
	await get_tree().process_frame
	await get_tree().process_frame

	var preview_camera := preview_scene.get_node_or_null("Camera") as Camera2D
	if preview_camera != null:
		preview_camera.position_smoothing_enabled = false

	preview_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	DialogManager.balloons_enabled = true

func _configure_preview_scene(preview_scene: Node) -> void:
	var preview_music := preview_scene.get_node_or_null("BackgroundMusic") as AudioStreamPlayer
	if preview_music != null:
		preview_music.autoplay = false

	var preview_player := preview_scene.get_node_or_null("Player")
	if preview_player == null:
		return

	preview_player.set("menu_preview_mode", true)

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
	_style_map_title_label(map_title)
	_style_menu_button(start_button, "Começar", Color(0.47, 0.82, 0.23), Color(0.76, 0.95, 0.36), Color(0.36, 0.69, 0.18))
	_style_menu_button(tropical_button, "Vale Tropical", Color(0.47, 0.82, 0.23), Color(0.76, 0.95, 0.36), Color(0.36, 0.69, 0.18))
	_style_menu_button(ice_button, "Picos de Gelo", Color(0.28, 0.62, 0.93), Color(0.58, 0.86, 1.0), Color(0.18, 0.45, 0.75))
	_style_menu_button(back_button, "Voltar", Color(0.55, 0.55, 0.6), Color(0.75, 0.75, 0.8), Color(0.38, 0.38, 0.44))

func _setup_focus_navigation() -> void:
	start_button.focus_neighbor_top = NodePath(".")
	start_button.focus_neighbor_bottom = NodePath(".")
	start_button.focus_previous = NodePath(".")
	start_button.focus_next = NodePath(".")
	tropical_button.focus_neighbor_top = tropical_button.get_path_to(back_button)
	tropical_button.focus_neighbor_bottom = tropical_button.get_path_to(ice_button)
	tropical_button.focus_previous = tropical_button.get_path_to(back_button)
	tropical_button.focus_next = tropical_button.get_path_to(ice_button)
	ice_button.focus_neighbor_top = ice_button.get_path_to(tropical_button)
	ice_button.focus_neighbor_bottom = ice_button.get_path_to(back_button)
	ice_button.focus_previous = ice_button.get_path_to(tropical_button)
	ice_button.focus_next = ice_button.get_path_to(back_button)
	back_button.focus_neighbor_top = back_button.get_path_to(ice_button)
	back_button.focus_neighbor_bottom = back_button.get_path_to(tropical_button)
	back_button.focus_previous = back_button.get_path_to(ice_button)
	back_button.focus_next = back_button.get_path_to(tropical_button)

func _style_title_label(label: Label, font_color: Color, font_size: int) -> void:
	label.add_theme_font_override("font", MENU_FONT)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", font_color)
	label.add_theme_color_override("font_outline_color", Color(0.22, 0.14, 0.16))
	label.add_theme_constant_override("outline_size", 6)

func _style_map_title_label(label: Label) -> void:
	label.add_theme_font_override("font", MENU_FONT)
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color(1.0, 0.96, 0.86))
	label.add_theme_color_override("font_outline_color", Color(0.12, 0.16, 0.18))
	label.add_theme_constant_override("outline_size", 3)

func _style_menu_button(button: Button, button_text: String, base_color: Color, hover_color: Color, pressed_color: Color) -> void:
	button.text = button_text
	button.custom_minimum_size = Vector2(128, 24)
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_filter = Control.MOUSE_FILTER_STOP
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
	_refresh_menu_button_visual(button)
	button.add_theme_stylebox_override("disabled", _make_panel_style(base_color.darkened(0.35), Color(0.12, 0.2, 0.16), 2, 8, 3))
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER

func _connect_menu_button_state_signals(button: Button) -> void:
	button.mouse_entered.connect(_on_menu_button_mouse_entered.bind(button))
	button.mouse_exited.connect(_on_menu_button_mouse_exited.bind(button))
	button.focus_entered.connect(_on_menu_button_focus_entered.bind(button))
	button.focus_exited.connect(_on_menu_button_focus_exited.bind(button))

func _refresh_menu_button_visual(button: Button) -> void:
	var base_color := button.get_meta("base_color", Color.WHITE) as Color
	var hover_color := button.get_meta("hover_color", Color.WHITE) as Color
	var pressed_color := button.get_meta("pressed_color", Color.WHITE) as Color
	var background_color := hover_color if hovered_menu_button == button else base_color

	var normal_style := _make_panel_style(background_color, Color(0.12, 0.2, 0.16), 2, 8, 3)
	var focus_style := _make_panel_style(background_color, Color(0.12, 0.2, 0.16), 2, 8, 3)
	focus_style.shadow_color = Color(0.06, 0.11, 0.09, 0.35)
	focus_style.shadow_size = 5
	focus_style.shadow_offset = Vector2(0, 3)

	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", normal_style.duplicate())
	button.add_theme_stylebox_override("pressed", _make_panel_style(pressed_color, Color(0.12, 0.2, 0.16), 2, 8, 3))
	button.add_theme_stylebox_override("focus", focus_style)

func _show_main_menu() -> void:
	title_center.show()
	buttons_center.show()
	map_buttons_center.hide()
	start_button.grab_focus()

func _show_map_menu() -> void:
	buttons_center.hide()
	map_buttons_center.show()
	tropical_button.grab_focus()

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
	_show_map_menu()

func _on_tropical_button_pressed() -> void:
	get_tree().change_scene_to_file(TROPIC_SCENE_PATH)

func _on_ice_button_pressed() -> void:
	get_tree().change_scene_to_file(ICE_SCENE_PATH)

func _on_menu_button_mouse_entered(button: Button) -> void:
	hovered_menu_button = button
	_refresh_menu_button_visual(button)

func _on_menu_button_mouse_exited(button: Button) -> void:
	if hovered_menu_button == button:
		hovered_menu_button = null
	_refresh_menu_button_visual(button)

func _on_menu_button_focus_entered(button: Button) -> void:
	_refresh_menu_button_visual(button)

func _on_menu_button_focus_exited(button: Button) -> void:
	_refresh_menu_button_visual(button)
