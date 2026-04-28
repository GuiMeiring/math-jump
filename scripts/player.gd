extends CharacterBody2D

const MATH_ATTACK_MODAL = preload("res://entities/math_attack_modal.tscn")

enum PlayerState {
	idle,
	walk,
	jump,
	fall,
	duck,
	hurt
}

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var reload_timer: Timer = $ReloadTimer
@onready var hit_box: Area2D = $HitBox
@onready var hit_box_collision_shape: CollisionShape2D = $HitBox/CollisionShape2D
@onready var attack_area: Area2D = $Attack
@onready var attack_feedback_container: CenterContainer = $AttackFeedbackLayer/AttackFeedbackContainer
@onready var attack_feedback_label: Label = $AttackFeedbackLayer/AttackFeedbackContainer/AttackFeedbackBox/LabelMargin/AttackFeedbackLabel
@onready var attack_feedback_timer: Timer = $AttackFeedbackLayer/AttackFeedbackTimer

@export var max_speed = 100.0
@export var acceleration = 400
@export var deceleration = 400
@export var no_enemy_attack_message := "Nenhum inimigo encontrado!"
@export var attack_success_message := "Resposta correta!"
@export var attack_fail_message := "Resposta errada!"
@export var attack_timeout_message := "Tempo esgotado!"
@export var attack_feedback_duration := 1.2
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

var enemies_in_range: Array = []
var active_attack_modal
var is_attacking = false
var attack_offset_x = 20

func _ready() -> void:
	go_to_idle_state()
	hide_attack_feedback()

func _physics_process(delta: float) -> void:
	if can_attack() and Input.is_action_just_pressed("attack"):
		try_attack()

	if not is_on_floor():
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
		PlayerState.hurt:
			hurt_state(delta)

	check_lethal_overlaps()

	move_and_slide()

func go_to_idle_state():
	status = PlayerState.idle
	anim.play("idle")

func go_to_walk_state():
	status = PlayerState.walk
	anim.play("walk")

func go_to_jump_state():
	status = PlayerState.jump
	anim.play("jump")
	velocity.y = JUMP_VELOCITY
	jump_count += 1

func go_to_fall_state():
	status = PlayerState.fall
	anim.play("fall")

func go_to_duck_state():
	status = PlayerState.duck
	anim.play("duck")
	velocity.x = 0
	set_duck_collision(true)

func exit_from_duck_state():
	set_duck_collision(false)

func go_to_hurt_state():
	exit_from_duck_state()
	status = PlayerState.hurt
	anim.play("hurt")
	velocity.x = 0
	reload_timer.start()

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
	velocity.x = 0
	update_direction()
	if Input.is_action_just_released("duck"):
		exit_from_duck_state()
		go_to_idle_state()
		return

func hurt_state(_delta):
	pass

func move(delta):
	update_direction()

	if direction:
		velocity.x = move_toward(velocity.x, direction * max_speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)

func update_direction():
	direction = Input.get_axis("left", "right")

	if direction < 0:
		anim.flip_h = true
		attack_area.scale.x = -1

	elif direction > 0:
		anim.flip_h = false
		attack_area.scale.x = 1

func can_jump() -> bool:
	return jump_count < max_jump_count

func can_attack() -> bool:
	return status != PlayerState.hurt and not is_ducking() and not is_instance_valid(active_attack_modal)

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

func set_duck_collision(is_ducking_state: bool):
	collision_shape.shape.radius = 12
	collision_shape.shape.height = DUCK_BODY_HEIGHT if is_ducking_state else STANDING_BODY_HEIGHT
	collision_shape.position.y = DUCK_BODY_Y if is_ducking_state else STANDING_BODY_Y
	hit_box_collision_shape.shape.size.y = DUCK_HITBOX_HEIGHT if is_ducking_state else STANDING_HITBOX_HEIGHT
	hit_box_collision_shape.position.y = DUCK_HITBOX_Y if is_ducking_state else STANDING_HITBOX_Y

func check_lethal_overlaps():
	if status == PlayerState.hurt:
		return

	for area in hit_box.get_overlapping_areas():
		if area.is_in_group("lethalArea") and not is_defending_against(area):
			hit_lethal_area()
			return

func _on_hit_box_area_entered(area: Area2D) -> void:
	if status == PlayerState.hurt:
		return

	if area.is_in_group("enemies"):
		hirt_enemy(area)
	elif area.is_in_group("lethalArea") && not is_defending_against(area):
		hit_lethal_area()

func hirt_enemy(area: Area2D):
	if velocity.y > 0:
		area.get_parent().take_damage()
		go_to_jump_state()
	else:
		if status != PlayerState.hurt:
			go_to_hurt_state()

func hit_lethal_area():
	go_to_hurt_state()

func _on_reload_timer_timeout() -> void:
	get_tree().reload_current_scene()

func try_attack():
	if not can_attack():
		return

	var target_enemy = get_attack_target()
	if target_enemy == null:
		show_attack_feedback(no_enemy_attack_message)
		return

	if not target_enemy.has_method("get_math_prompt_data"):
		return

	var math_prompt: Dictionary = target_enemy.get_math_prompt_data()
	if math_prompt.is_empty():
		show_attack_feedback(no_enemy_attack_message)
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
	get_tree().root.add_child(active_attack_modal)
	active_attack_modal.answered.connect(_on_math_attack_modal_answered)
	active_attack_modal.open_modal(
		math_prompt.get("question", ""),
		math_prompt.get("options", []),
		int(math_prompt.get("answer", 0)),
		target_enemy
	)

func _on_math_attack_modal_answered(target_enemy: Node, is_correct: bool, did_timeout: bool) -> void:
	active_attack_modal = null

	if did_timeout:
		show_attack_feedback(attack_timeout_message)
		return

	if is_correct:
		if is_instance_valid(target_enemy) and target_enemy.has_method("take_damage"):
			target_enemy.take_damage()
		show_attack_feedback(attack_success_message)
		return

	show_attack_feedback(attack_fail_message)

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
