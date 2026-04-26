extends CharacterBody2D

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

@export var max_speed = 100.0
@export var acceleration = 400
@export var deceleration = 400
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
var is_attacking = false
var attack_offset_x = 20

func _ready() -> void:
	go_to_idle_state()

func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("attack"):
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
		# inimigo morre
		area.get_parent().take_damage()
		go_to_jump_state()
	else:
		# player morre
		if status != PlayerState.hurt:
			go_to_hurt_state()

func hit_lethal_area():
	go_to_hurt_state()

func _on_reload_timer_timeout() -> void:
	get_tree().reload_current_scene()

func try_attack():
	if enemies_in_range.is_empty():
		print("Nenhum inimigo na área")
		return

	print("Atacando inimigo")

func _on_attack_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		enemies_in_range.append(area.get_parent())

func _on_attack_area_exited(area: Area2D) -> void:
	if area.get_parent() in enemies_in_range:
		enemies_in_range.erase(area.get_parent())
