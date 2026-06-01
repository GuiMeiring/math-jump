extends CharacterBody2D

const MATH_ATTACK_MODAL = preload("res://entities/math_attack_modal.tscn")
const MATH_ATTACK_MODAL_LAYER_NAME := "MathAttackModalLayer"

signal lives_changed(current_lives: int, max_lives: int)

enum PlayerState {
	idle,
	walk,
	jump,
	fall,
	duck,
	attack,
	hurt
}

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var reload_timer: Timer = $ReloadTimer
@onready var hurt_timer: Timer = $HurtTimer
@onready var hit_box: Area2D = $HitBox
@onready var hit_box_collision_shape: CollisionShape2D = $HitBox/CollisionShape2D
@onready var attack_area: Area2D = $Attack
@onready var attack_feedback_container: CenterContainer = $AttackFeedbackLayer/AttackFeedbackContainer
@onready var attack_feedback_label: Label = $AttackFeedbackLayer/AttackFeedbackContainer/AttackFeedbackBox/LabelMargin/AttackFeedbackLabel
@onready var attack_feedback_timer: Timer = $AttackFeedbackLayer/AttackFeedbackTimer
@onready var hearts: Array[AnimatedSprite2D] = [
	$HealthLayer/HeartsContainer/Heart1,
	$HealthLayer/HeartsContainer/Heart2,
	$HealthLayer/HeartsContainer/Heart3
]

@export var max_speed = 100.0
@export var acceleration = 400
@export var deceleration = 400
@export_range(1, 3) var max_lives := 3
@export var attack_fail_message := "Resposta errada!"
@export var attack_timeout_message := "Tempo esgotado!"
@export var attack_feedback_duration := 1.2
@export var hurt_recovery_duration := 0.7
@export var death_reload_delay := 0.9
@export var menu_preview_mode := false
@export var starts_facing_left := false
@export var fall_damage_min_distance := 220.0
@export var fall_damage_two_hearts_min_distance := 320.0
@export var fall_damage_three_hearts_min_distance := 520.0
@export var enemy_contact_cooldown_duration := 1.0
@export var enemy_contact_knockback_x := 140.0
@export var enemy_contact_knockback_y := -120.0
@export var enemy_top_bounce_velocity := -180.0
@export var enemy_top_push_speed := 90.0
@export var defense_push_speed := 85.0
@export var defense_push_duration := 0.12
@export var damage_flash_color := Color(1, 0.35, 0.35, 1)
@export var default_player_color := Color(1, 1, 1, 1)
const DEFAULT_SPRITE_POSITION := Vector2(0, -3.9)
const ATTACK_SPRITE_Y := -11.9
const JUMP_VELOCITY = -300.0
const STANDING_BODY_HEIGHT := 40.0
const STANDING_BODY_Y := 0.0
const DUCK_BODY_HEIGHT := 30.0
const DUCK_BODY_Y := 5.0
const STANDING_HITBOX_HEIGHT := 43.333332
const STANDING_HITBOX_Y := 0.0
const DUCK_HITBOX_HEIGHT := 30.0
const DUCK_HITBOX_Y := 5.0

var direction = 0
var jump_count = 0
@export var max_jump_count = 2
var status: PlayerState
var current_lives := 0
var displayed_lives := 0
var is_dead := false
var has_pending_death := false
var is_damage_recovering := false
var is_tracking_fall := false
var fall_start_y := 0.0
var enemy_contact_cooldown_left := 0.0
var defense_push_time_left := 0.0
var defense_push_direction := 0.0

var enemies_in_range: Array = []
var active_attack_modal
var pending_attack_target: Node = null
var pending_attack_feedback_message := ""

func _ready() -> void:
	current_lives = max_lives
	displayed_lives = max_lives
	has_pending_death = false
	is_damage_recovering = false
	is_tracking_fall = false
	fall_start_y = global_position.y
	enemy_contact_cooldown_left = 0.0
	clear_defense_push()
	lives_changed.connect(_on_lives_changed)
	clear_damage_flash()
	set_default_sprite_position()
	go_to_idle_state()
	set_facing_direction(-1 if starts_facing_left else 1)
	hide_attack_feedback()
	lives_changed.emit(current_lives, max_lives)

func _physics_process(delta: float) -> void:
	if menu_preview_mode:
		process_menu_preview(delta)
		move_and_slide()
		return

	var was_on_floor := is_on_floor()

	if enemy_contact_cooldown_left > 0.0:
		enemy_contact_cooldown_left = max(enemy_contact_cooldown_left - delta, 0.0)
	if defense_push_time_left > 0.0:
		defense_push_time_left = max(defense_push_time_left - delta, 0.0)
		if defense_push_time_left == 0.0:
			defense_push_direction = 0.0

	if can_attack() and Input.is_action_just_pressed("attack"):
		try_attack()

	if not is_on_floor() and not should_lock_attack_movement():
		velocity += get_gravity() * delta

	match status:
		PlayerState.idle:
			idle_state(delta)
		PlayerState.walk:
			walk_state(delta)
		PlayerState.jump:
			jump_state(delta)
		PlayerState.fall:
			fall_state(delta)
		PlayerState.duck:
			duck_state(delta)
		PlayerState.attack:
			attack_state(delta)
		PlayerState.hurt:
			hurt_state(delta)

	process_enemy_contact_overlap_push()
	check_lethal_overlaps()

	move_and_slide()
	resolve_enemy_body_collisions()
	process_fall_landing(was_on_floor)

func go_to_idle_state():
	stop_fall_tracking()
	set_default_sprite_position()
	status = PlayerState.idle
	anim.play("idle")

func go_to_walk_state():
	stop_fall_tracking()
	set_default_sprite_position()
	status = PlayerState.walk
	anim.play("walk")

func go_to_jump_state():
	stop_fall_tracking()
	set_default_sprite_position()
	status = PlayerState.jump
	anim.play("jump")
	velocity.y = JUMP_VELOCITY
	jump_count += 1

func go_to_fall_state():
	start_fall_tracking()
	set_default_sprite_position()
	status = PlayerState.fall
	anim.play("fall")

func go_to_duck_state():
	stop_fall_tracking()
	set_default_sprite_position()
	status = PlayerState.duck
	anim.play("duck")
	velocity.x = 0
	set_duck_collision(true)

func exit_from_duck_state():
	clear_defense_push()
	set_duck_collision(false)

func go_to_hurt_state():
	stop_fall_tracking()
	exit_from_duck_state()
	clear_pending_attack()
	set_default_sprite_position()
	status = PlayerState.hurt
	is_damage_recovering = true
	clear_damage_flash()
	anim.play("hurt")
	velocity.x = 0
	hurt_timer.start(hurt_recovery_duration)

func process_menu_preview(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, deceleration * delta)

	if not is_on_floor():
		velocity += get_gravity() * delta
		if velocity.y > 0.0 and status != PlayerState.fall:
			go_to_fall_state()
		return

	jump_count = 0
	if status != PlayerState.idle:
		go_to_idle_state()

func start_damage_recovery() -> void:
	is_damage_recovering = true
	show_damage_flash()
	hurt_timer.start(hurt_recovery_duration)

func show_damage_flash() -> void:
	anim.modulate = damage_flash_color

func clear_damage_flash() -> void:
	anim.modulate = default_player_color

func start_fall_tracking() -> void:
	if is_tracking_fall:
		return

	is_tracking_fall = true
	fall_start_y = global_position.y

func stop_fall_tracking() -> void:
	is_tracking_fall = false

func process_fall_landing(was_on_floor: bool) -> void:
	if not is_tracking_fall:
		return

	if was_on_floor or not is_on_floor():
		return

	var fall_distance: float = max(global_position.y - fall_start_y, 0.0)
	stop_fall_tracking()
	var fall_damage: int = get_fall_damage_amount(fall_distance)
	if fall_damage <= 0:
		return

	take_damage(fall_damage)

func get_fall_damage_amount(fall_distance: float) -> int:
	if fall_damage_min_distance <= 0.0 or fall_distance < fall_damage_min_distance:
		return 0

	if fall_damage_three_hearts_min_distance > 0.0 and fall_distance >= fall_damage_three_hearts_min_distance:
		return 3

	if fall_damage_two_hearts_min_distance > 0.0 and fall_distance >= fall_damage_two_hearts_min_distance:
		return 2

	return 1

func resolve_enemy_body_collisions() -> void:
	for collision_index in get_slide_collision_count():
		var collision: KinematicCollision2D = get_slide_collision(collision_index)
		var enemy: Node2D = collision.get_collider() as Node2D
		if enemy == null or not is_enemy_body(enemy):
			continue

		if collision.get_normal().dot(Vector2.UP) <= 0.7:
			continue

		enemy_contact_cooldown_left = enemy_contact_cooldown_duration
		push_player_off_enemy(enemy)
		return

func is_enemy_body(node: Node) -> bool:
	return node.has_method("is_attackable")

func can_apply_enemy_contact_push() -> bool:
	return not is_dead and status != PlayerState.hurt and status != PlayerState.attack and not is_damage_recovering and enemy_contact_cooldown_left <= 0.0

func try_apply_enemy_contact_push(enemy: Node2D = null) -> bool:
	if not can_apply_enemy_contact_push():
		return false

	enemy_contact_cooldown_left = enemy_contact_cooldown_duration
	apply_enemy_contact_knockback(enemy)
	return true

func apply_enemy_contact_knockback(enemy: Node2D = null) -> void:
	var push_direction: float = -get_facing_direction()
	if enemy != null:
		push_direction = sign(global_position.x - enemy.global_position.x)
		if push_direction == 0.0:
			push_direction = -get_facing_direction()

	velocity.x = push_direction * enemy_contact_knockback_x
	velocity.y = enemy_contact_knockback_y
	set_default_sprite_position()
	if velocity.y < 0.0:
		status = PlayerState.jump
		anim.play("jump")
	else:
		status = PlayerState.fall
		anim.play("fall")

func process_enemy_contact_overlap_push() -> void:
	if not can_apply_enemy_contact_push():
		return

	for area in hit_box.get_overlapping_areas():
		if area.is_in_group("enemies"):
			try_apply_enemy_contact_push(area.get_parent() as Node2D)
			return

func push_player_off_enemy(enemy: Node2D) -> void:
	var push_direction: float = sign(global_position.x - enemy.global_position.x)
	if push_direction == 0.0:
		push_direction = 1.0 if anim.flip_h else -1.0

	velocity.y = enemy_top_bounce_velocity
	velocity.x = push_direction * enemy_top_push_speed
	set_default_sprite_position()
	status = PlayerState.jump
	anim.play("jump")

func go_to_attack_state() -> void:
	update_attack_sprite_position()
	status = PlayerState.attack
	anim.play("attack")
	velocity.x = 0

func idle_state(delta):
	move(delta)
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return

	if velocity.x != 0:
		go_to_walk_state()
		return

	if Input.is_action_pressed("duck"):
		go_to_duck_state()
		return

func walk_state(delta):
	move(delta)
	if Input.is_action_pressed("duck"):
		go_to_duck_state()
		return

	if velocity.x == 0:
		go_to_idle_state()
		return

	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return

	if !is_on_floor():
		jump_count += 1
		go_to_fall_state()
		return

func jump_state(delta):
	move(delta)

	if Input.is_action_just_pressed("jump") && can_jump():
		go_to_jump_state()
		return

	if velocity.y > 0:
		go_to_fall_state()
		return

func fall_state(delta):
	move(delta)

	if Input.is_action_just_pressed("jump") && can_jump():
		go_to_jump_state()
		return

	if is_on_floor():
		jump_count = 0
		if Input.is_action_pressed("duck"):
			go_to_duck_state()
			return

		if velocity.x == 0:
			go_to_idle_state()
		else:
			go_to_walk_state()
		return

func duck_state(_delta):
	if defense_push_time_left > 0.0:
		velocity.x = defense_push_direction * defense_push_speed
	else:
		velocity.x = 0
	update_direction()
	if Input.is_action_just_released("duck"):
		exit_from_duck_state()
		go_to_idle_state()
		return

func attack_state(_delta):
	if should_lock_attack_movement():
		velocity = Vector2.ZERO
		return

	velocity.x = 0

func hurt_state(_delta):
	pass

func move(delta):
	update_direction()

	if direction:
		velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)

func set_default_sprite_position() -> void:
	anim.position = DEFAULT_SPRITE_POSITION

func update_attack_sprite_position() -> void:
	anim.position = Vector2(DEFAULT_SPRITE_POSITION.x, ATTACK_SPRITE_Y)

func update_direction():
	direction = Input.get_axis("left", "right")

	set_facing_direction(direction)

func set_facing_direction(facing_direction: float) -> void:
	if facing_direction < 0:
		anim.flip_h = true
		attack_area.scale.x = -1

	elif facing_direction > 0:
		anim.flip_h = false
		attack_area.scale.x = 1

func can_jump() -> bool:
	return jump_count < max_jump_count

func can_attack() -> bool:
	return not is_dead and status != PlayerState.hurt and status != PlayerState.attack and not is_ducking() and not is_enemy_contact_push_active() and not is_instance_valid(active_attack_modal)

func is_enemy_contact_push_active() -> bool:
	return enemy_contact_cooldown_left > 0.0

func should_lock_attack_movement() -> bool:
	return status == PlayerState.attack and is_instance_valid(pending_attack_target)

func is_ducking() -> bool:
	return status == PlayerState.duck

func get_facing_direction() -> int:
	return -1 if anim.flip_h else 1

func is_defending_against(area: Area2D) -> bool:
	if not is_ducking():
		return false

	if not area.has_method("get_direction"):
		return false

	var projectile_direction = sign(area.get_direction())
	if projectile_direction == 0:
		return false

	return get_facing_direction() == -projectile_direction

func apply_defense_push() -> void:
	defense_push_direction = -get_facing_direction()
	defense_push_time_left = defense_push_duration
	velocity.x = defense_push_direction * defense_push_speed

func clear_defense_push() -> void:
	defense_push_time_left = 0.0
	defense_push_direction = 0.0

func set_duck_collision(is_ducking_state: bool):
	collision_shape.shape.radius = 12
	collision_shape.shape.height = DUCK_BODY_HEIGHT if is_ducking_state else STANDING_BODY_HEIGHT
	collision_shape.position.y = DUCK_BODY_Y if is_ducking_state else STANDING_BODY_Y
	hit_box_collision_shape.shape.size.y = DUCK_HITBOX_HEIGHT if is_ducking_state else STANDING_HITBOX_HEIGHT
	hit_box_collision_shape.position.y = DUCK_HITBOX_Y if is_ducking_state else STANDING_HITBOX_Y

func check_lethal_overlaps():
	if status == PlayerState.hurt or is_damage_recovering:
		return

	for area in hit_box.get_overlapping_areas():
		if area.is_in_group("lethalArea") and not is_defending_against(area):
			hit_lethal_area()
			return

func _on_hit_box_area_entered(area: Area2D) -> void:
	if menu_preview_mode:
		return

	if status == PlayerState.hurt or is_damage_recovering:
		return

	if area.is_in_group("enemies"):
		if status == PlayerState.attack:
			return
		try_apply_enemy_contact_push(area.get_parent() as Node2D)
	elif area.is_in_group("lethalArea"):
		if is_defending_against(area):
			apply_defense_push()
		else:
			hit_lethal_area()

func hit_lethal_area():
	take_damage()

func take_damage(amount: int = 1) -> void:
	if menu_preview_mode:
		return

	if is_dead or status == PlayerState.hurt or is_damage_recovering:
		return

	if amount <= 0:
		return

	current_lives = max(current_lives - amount, 0)
	has_pending_death = current_lives <= 0
	lives_changed.emit(current_lives, max_lives)

	if has_pending_death:
		go_to_hurt_state()
		return

	start_damage_recovery()

func die() -> void:
	is_dead = true
	has_pending_death = false
	is_damage_recovering = false
	stop_fall_tracking()
	clear_defense_push()
	clear_damage_flash()
	exit_from_duck_state()
	clear_pending_attack()
	set_default_sprite_position()
	status = PlayerState.hurt
	anim.play("hurt")
	velocity = Vector2.ZERO
	reload_timer.start(death_reload_delay)

func _on_reload_timer_timeout() -> void:
	get_tree().reload_current_scene()

func try_attack():
	if not can_attack():
		return

	var target_enemy = get_attack_target()
	if target_enemy == null:
		pending_attack_feedback_message = ""
		go_to_attack_state()
		return

	if not target_enemy.has_method("get_math_prompt_data"):
		return

	var math_prompt: Dictionary = target_enemy.get_math_prompt_data()
	if math_prompt.is_empty():
		pending_attack_feedback_message = ""
		go_to_attack_state()
		return

	open_attack_modal(target_enemy, math_prompt)

func get_attack_target():
	var valid_enemies: Array = []

	for enemy in enemies_in_range:
		if not is_instance_valid(enemy):
			continue

		if enemy.has_method("is_attackable") and not enemy.is_attackable():
			continue

		valid_enemies.append(enemy)

	enemies_in_range = valid_enemies
	if enemies_in_range.is_empty():
		return null

	var closest_enemy = enemies_in_range[0]
	var closest_distance = global_position.distance_squared_to(closest_enemy.global_position)

	for enemy in enemies_in_range:
		var current_distance = global_position.distance_squared_to(enemy.global_position)
		if current_distance < closest_distance:
			closest_enemy = enemy
			closest_distance = current_distance

	return closest_enemy

func open_attack_modal(target_enemy: Node, math_prompt: Dictionary) -> void:
	active_attack_modal = MATH_ATTACK_MODAL.instantiate()
	var modal_layer := create_attack_modal_layer()
	modal_layer.add_child(active_attack_modal)
	active_attack_modal.tree_exited.connect(modal_layer.queue_free)
	active_attack_modal.answered.connect(_on_math_attack_modal_answered)
	active_attack_modal.open_modal(
		math_prompt.get("question", ""),
		math_prompt.get("options", []),
		int(math_prompt.get("answer", 0)),
		target_enemy
	)

func create_attack_modal_layer() -> CanvasLayer:
	var modal_layer := CanvasLayer.new()
	modal_layer.name = MATH_ATTACK_MODAL_LAYER_NAME
	modal_layer.layer = 100
	modal_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().root.add_child(modal_layer)
	return modal_layer

func _on_math_attack_modal_answered(target_enemy: Node, is_correct: bool, did_timeout: bool) -> void:
	active_attack_modal = null

	if did_timeout:
		show_attack_feedback(attack_timeout_message)
		take_damage()
		return

	if is_correct:
		if not is_instance_valid(target_enemy) or not target_enemy.has_method("take_damage"):
			return

		pending_attack_target = target_enemy
		pending_attack_feedback_message = ""
		go_to_attack_state()
		return

	show_attack_feedback(attack_fail_message)
	take_damage()

func clear_pending_attack() -> void:
	pending_attack_target = null
	pending_attack_feedback_message = ""

func resolve_finished_attack() -> void:
	var target_enemy = pending_attack_target

	clear_pending_attack()

	if is_instance_valid(target_enemy) and target_enemy.has_method("take_damage"):
		target_enemy.take_damage()

func resume_state_after_attack() -> void:
	if status != PlayerState.attack:
		return

	if not is_on_floor():
		if velocity.y < 0:
			set_default_sprite_position()
			status = PlayerState.jump
			anim.play("jump")
		else:
			set_default_sprite_position()
			status = PlayerState.fall
			anim.play("fall")
		return

	if direction == 0:
		go_to_idle_state()
		return

	go_to_walk_state()

func show_attack_feedback(message: String) -> void:
	attack_feedback_label.text = message
	attack_feedback_container.show()
	attack_feedback_timer.start(attack_feedback_duration)

func hide_attack_feedback() -> void:
	attack_feedback_container.hide()

func _on_attack_area_entered(area: Area2D) -> void:
	if not area.is_in_group("enemies"):
		return

	var enemy = area.get_parent()
	if enemy not in enemies_in_range:
		enemies_in_range.append(enemy)

func _on_attack_area_exited(area: Area2D) -> void:
	var enemy = area.get_parent()
	if enemy in enemies_in_range:
		enemies_in_range.erase(enemy)

func _on_attack_feedback_timer_timeout() -> void:
	hide_attack_feedback()

func _on_hurt_timer_timeout() -> void:
	if is_dead:
		return

	if has_pending_death:
		die()
		return

	is_damage_recovering = false
	clear_damage_flash()

	if status != PlayerState.hurt:
		return

	if not is_on_floor():
		set_default_sprite_position()
		if velocity.y < 0:
			status = PlayerState.jump
			anim.play("jump")
		else:
			go_to_fall_state()
		return

	if Input.is_action_pressed("duck"):
		go_to_duck_state()
		return

	update_direction()
	if direction == 0:
		go_to_idle_state()
		return

	go_to_walk_state()

func _on_lives_changed(updated_lives: int, _total_lives: int) -> void:
	if updated_lives < displayed_lives:
		for heart_index in range(updated_lives, displayed_lives):
			animate_lost_heart(heart_index)
	else:
		for heart_index in range(displayed_lives, updated_lives):
			show_heart(heart_index)

	displayed_lives = updated_lives

func show_heart(heart_index: int) -> void:
	if heart_index < 0 or heart_index >= hearts.size():
		return

	var heart = hearts[heart_index]
	heart.show()
	heart.stop()
	heart.frame = 0

func animate_lost_heart(heart_index: int) -> void:
	if heart_index < 0 or heart_index >= hearts.size():
		return

	var heart = hearts[heart_index]
	heart.show()
	heart.frame = 0
	heart.play("spin")
	await heart.animation_finished
	heart.stop()
	heart.hide()
	heart.frame = 0

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation != "attack" or status != PlayerState.attack:
		return

	resolve_finished_attack()
	resume_state_after_attack()
