extends CharacterBody3D

@export var walk_speed := 5.4
@export var run_speed := 8.6
@export var acceleration := 24.0
@export var gravity := 22.0
@export var turn_speed := 13.0
@export var jump_velocity := 7.2

var touch_move := Vector2.ZERO
var touch_sprint := false
var touch_jump_pressed := false
var touch_attack_pressed := false
var animation_player: AnimationPlayer
var animation_names: Dictionary = {}
var current_motion := ""
var attack_timer := 0.0
var health := 100
var hit_invulnerability := 0.0

func _ready() -> void:
	animation_player = _find_animation_player(self)
	_cache_hero_animations()
	_play_motion("idle")

func _physics_process(delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if touch_move.length() > 0.08:
		input = touch_move
	var direction := Vector3(input.x, 0.0, input.y).rotated(Vector3.UP, 0.0)
	if direction.length() > 0.08:
		rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), delta * turn_speed)

	var moving := direction.length() > 0.08
	var running := Input.is_action_pressed("sprint") or touch_sprint
	var speed := run_speed if running else walk_speed
	var target_velocity := direction.normalized() * speed if moving else Vector3.ZERO
	velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)

	if is_on_floor():
		if Input.is_action_just_pressed("jump") or touch_jump_pressed:
			velocity.y = jump_velocity
		else:
			velocity.y = -0.25
	else:
		velocity.y -= gravity * delta
	touch_jump_pressed = false
	move_and_slide()

	attack_timer = maxf(0.0, attack_timer - delta)
	hit_invulnerability = maxf(0.0, hit_invulnerability - delta)
	if attack_timer > 0.0 and animation_names.has("punch"):
		_play_motion("punch")
	elif not is_on_floor():
		_play_motion("run_jump" if moving else "jump")
	elif moving:
		_play_motion("run" if running else "walk")
	else:
		_play_motion("idle")

func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child in node.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found
	return null

func _cache_hero_animations() -> void:
	if animation_player == null:
		push_warning("Hero GLB has no AnimationPlayer; check imported model.")
		return
	for animation_name in animation_player.get_animation_list():
		var key := String(animation_name).to_lower()
		if key.contains("man_idle"):
			animation_names["idle"] = animation_name
		elif key.contains("man_walk"):
			animation_names["walk"] = animation_name
		elif key.contains("man_run") and not key.contains("runningjump"):
			animation_names["run"] = animation_name
		elif key.contains("man_runningjump"):
			animation_names["run_jump"] = animation_name
		elif key.contains("man_jump"):
			animation_names["jump"] = animation_name
		elif key.contains("punch") or key.contains("melee") or key.contains("attack"):
			animation_names["punch"] = animation_name
	if animation_names.has("punch"):
		animation_player.get_animation(animation_names["punch"]).loop_mode = Animation.LOOP_NONE
	for loop_key in ["idle", "walk", "run"]:
		if animation_names.has(loop_key):
			animation_player.get_animation(animation_names[loop_key]).loop_mode = Animation.LOOP_LINEAR

func _play_motion(motion: String) -> void:
	if animation_player == null or not animation_names.has(motion):
		return
	var target: StringName = animation_names[motion]
	if current_motion == motion:
		return
	current_motion = motion
	animation_player.play(target, 0.16)
	animation_player.speed_scale = 1.0 if motion in ["idle", "walk", "jump"] else 1.08

func start_attack() -> void:
	attack_timer = 0.48
	if animation_names.has("punch"):
		current_motion = ""
		_play_motion("punch")

func take_npc_hit(from_position: Vector3) -> void:
	if hit_invulnerability > 0.0 or health <= 0:
		return
	hit_invulnerability = 0.7
	health = maxi(0, health - 8)
	var push := global_position - from_position
	push.y = 0.0
	if push.length() > 0.01:
		velocity.x = push.normalized().x * 4.2
		velocity.z = push.normalized().z * 4.2
