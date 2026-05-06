extends CharacterBody2D

enum SkeletonState {
	walk,
	attack,
	hurt
}

const SPINNING_BONE = preload("res://entities/spinning_bone.tscn")
const DEFAULT_ANIMATION_SPEED_SCALE := 1.0

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hit_box: Area2D = $HitBox
@onready var wall_detector: RayCast2D = $WallDetector
@onready var ground_detector: RayCast2D = $GroundDetector
@onready var player_detector: RayCast2D = $PlayerDetector
@onready var bone_start_position: Node2D = $BoneStartPosition

const SPEED = 8.0

var status: SkeletonState

var direction = 1
var can_throw = true
@export var attack_cooldown := 1.2
@export var attack_animation_speed_scale := 1.7
var attack_cooldown_left := 0.0

var math_system = MathSystem.new()

var current_question
var correct_answer
var options

var balloon
var math_state_key := ""
@export var operation_type: String = "mult"

func _ready() -> void:
	math_state_key = get_math_state_key()
	go_to_walk_state()
	load_math_state()
	spawn_balloon()

func _physics_process(delta: float) -> void:
	if attack_cooldown_left > 0.0:
		attack_cooldown_left = max(attack_cooldown_left - delta, 0.0)
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	match status:
		SkeletonState.walk:
			walk_state(delta)
		SkeletonState.attack:
			attack_state(delta)
		SkeletonState.hurt:
			hurt_state(delta)

	move_and_slide()

func go_to_walk_state():
	anim.speed_scale = DEFAULT_ANIMATION_SPEED_SCALE
	status = SkeletonState.walk
	anim.play("walk")
	
func go_to_attack_state():
	if attack_cooldown_left > 0.0:
		return
	
	anim.speed_scale = attack_animation_speed_scale
	status = SkeletonState.attack
	anim.play("attack")
	velocity = Vector2.ZERO
	can_throw = true
	attack_cooldown_left = attack_cooldown
	
func go_to_hurt_state():
	anim.speed_scale = DEFAULT_ANIMATION_SPEED_SCALE
	status = SkeletonState.hurt
	anim.play("hurt")
	hit_box.process_mode = Node.PROCESS_MODE_DISABLED
	hit_box.set_deferred("monitoring", false)
	hit_box.set_deferred("monitorable", false)
	wall_detector.enabled = false
	ground_detector.enabled = false
	player_detector.enabled = false
	collision_layer = 0
	collision_mask = 1
	velocity = Vector2.ZERO
	
func walk_state(_delta):
	if anim.frame == 3 or anim.frame == 4:
		velocity.x = SPEED * direction
	else:
		velocity.x = 0
	
	if wall_detector.is_colliding():
		scale.x *= -1
		direction *= -1

	if not ground_detector.is_colliding():
		scale.x *= -1
		direction *= -1
	
	if player_detector.is_colliding():
		go_to_attack_state()

func attack_state(_delta):
	velocity.x = 0
	
	if anim.frame == 2 && can_throw:
		throw_bone()
		can_throw = false

func hurt_state(_delta):
	pass
	
func take_damage():
	if balloon:
		balloon.queue_free()
	
	go_to_hurt_state()

func is_attackable() -> bool:
	return status != SkeletonState.hurt

func get_math_prompt_data() -> Dictionary:
	return {
		"question": current_question,
		"answer": correct_answer,
		"options": options.duplicate()
	}

func throw_bone():
	if get_parent() == null:
		return
	
	var new_bone = SPINNING_BONE.instantiate()
	add_sibling(new_bone)
	
	new_bone.global_position = bone_start_position.global_position
	new_bone.set_direction(self.direction)

func _on_animated_sprite_2d_animation_finished() -> void:
	if anim.animation == "attack":
		go_to_walk_state()
		return

func generate_math():
	var data = math_system.generate(operation_type)
	
	current_question = data["question"]
	correct_answer = data["answer"]
	options = data["options"]

func get_math_state_key() -> String:
	var current_scene = get_tree().current_scene
	var scene_path := ""
	if current_scene != null:
		scene_path = current_scene.scene_file_path
	
	return "%s:%s" % [scene_path, get_path()]

func load_math_state():
	var saved_state = DialogManager.get_math_state(math_state_key)
	if saved_state.is_empty():
		generate_math()
		DialogManager.save_math_state(math_state_key, {
			"question": current_question,
			"answer": correct_answer,
			"options": options
		})
		return
	
	current_question = saved_state["question"]
	correct_answer = saved_state["answer"]
	options = saved_state["options"]

func spawn_balloon():
	balloon = DialogManager.show_balloon(self, current_question, math_state_key)
