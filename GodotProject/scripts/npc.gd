extends CharacterBody3D

const HERO_SCENE = preload("res://assets/character/neon_coast_hero.glb")
const DIALOGUE_LINES := [
	"Отличный вечер, правда?",
	"Говорят, на набережной сегодня вечеринка.",
	"Эй, приятель! Не стой посреди дороги.",
	"В этом городе ночью жизнь только начинается.",
	"Знаешь, где здесь ближайший магазин?",
	"Осторожнее на бульваре — водят как сумасшедшие.",
	"Море сегодня просто шикарное.",
	"Я ищу работу. Может, повезёт у порта.",
	"Слышал музыку из клуба? Там жарко!",
	"Не видел тут красную спортивную машину?"
]

var health := 3
var wander_dir := Vector3.ZERO
var wander_timer := 0.0
var hit_flash := 0.0
var stun_timer := 0.0
var talk_cooldown := 0.0
var body_material: StandardMaterial3D
var animation_player: AnimationPlayer
var animations: Dictionary = {}
var current_animation := ""
var visual: Node3D
var mesh_nodes: Array = []
var speech: Label3D
var player_ref: Node3D
var is_down := false

func _ready() -> void:
	add_to_group("fightable_npc")
	visual = HERO_SCENE.instantiate()
	visual.name = "CivilianVisual"
	visual.rotation.y = PI
	visual.scale = Vector3.ONE * randf_range(0.88, 1.02)
	add_child(visual)
	mesh_nodes = _collect_meshes(visual)
	animation_player = _find_animation_player(visual)
	_cache_animations()
	_play_animation("idle")
	var collision := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.32
	capsule.height = 1.82
	collision.shape = capsule
	collision.position.y = 0.91
	add_child(collision)
	speech = Label3D.new()
	speech.name = "Speech"
	speech.position.y = 2.55
	speech.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	speech.font_size = 30
	speech.outline_size = 8
	speech.modulate = Color(1.0, 0.96, 0.78)
	speech.text = ""
	speech.visible = false
	add_child(speech)
	wander_dir = Vector3.RIGHT.rotated(Vector3.UP, randf() * TAU)
	talk_cooldown = randf_range(1.0, 4.0)

func set_player_reference(target: Node3D) -> void:
	player_ref = target

func _physics_process(delta: float) -> void:
	if is_down:
		return
	talk_cooldown = maxf(0.0, talk_cooldown - delta)
	hit_flash = maxf(0.0, hit_flash - delta)
	if stun_timer > 0.0:
		stun_timer -= delta
		velocity.x = move_toward(velocity.x, 0.0, delta * 3.0)
		velocity.z = move_toward(velocity.z, 0.0, delta * 3.0)
	else:
		wander_timer -= delta
		if wander_timer <= 0.0:
			wander_timer = randf_range(1.8, 4.2)
			wander_dir = Vector3.RIGHT.rotated(Vector3.UP, randf() * TAU)
		velocity.x = move_toward(velocity.x, wander_dir.x * 0.8, delta * 2.2)
		velocity.z = move_toward(velocity.z, wander_dir.z * 0.8, delta * 2.2)
	velocity.y = -0.3
	move_and_slide()
	if Vector2(velocity.x, velocity.z).length() > 0.12:
		rotation.y = atan2(-velocity.x, -velocity.z)
		_play_animation("walk")
	else:
		_play_animation("idle")
	_update_dialogue()

func _update_dialogue() -> void:
	if not is_instance_valid(player_ref) or is_down:
		speech.visible = false
		return
	var distance := global_position.distance_to(player_ref.global_position)
	if distance < 5.5 and talk_cooldown <= 0.0:
		speech.text = DIALOGUE_LINES[randi() % DIALOGUE_LINES.size()]
		speech.visible = true
		talk_cooldown = randf_range(7.0, 11.0)
	elif distance >= 7.0:
		speech.visible = false

func take_hit(from_position: Vector3) -> void:
	if health <= 0 or is_down:
		return
	health -= 1
	hit_flash = 0.28
	stun_timer = 0.48
	var push := global_position - from_position
	push.y = 0.0
	if push.length() > 0.01:
		velocity = push.normalized() * 5.0
	if health <= 0:
		is_down = true
		speech.visible = false
		_play_animation("death")
		collision_layer = 0
		collision_mask = 0
		velocity = Vector3.ZERO
		var tween := create_tween()
		tween.tween_property(visual, "rotation:x", visual.rotation.x + deg_to_rad(78.0), 0.28)
		tween.tween_interval(1.8)
		tween.tween_callback(queue_free)


func _collect_meshes(node: Node) -> Array:
	var result: Array = []
	if node is MeshInstance3D:
		result.append(node)
	for child in node.get_children():
		result.append_array(_collect_meshes(child))
	return result


func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child in node.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found
	return null

func _cache_animations() -> void:
	if animation_player == null:
		return
	for animation_name in animation_player.get_animation_list():
		var key := String(animation_name).to_lower()
		if key.contains("man_idle"):
			animations["idle"] = animation_name
		elif key.contains("man_walk"):
			animations["walk"] = animation_name
		elif key.contains("man_death") or key.contains("man_fall"):
			animations["death"] = animation_name
	for key in ["idle", "walk"]:
		if animations.has(key):
			animation_player.get_animation(animations[key]).loop_mode = Animation.LOOP_LINEAR

func _play_animation(key: String) -> void:
	if animation_player == null or not animations.has(key) or current_animation == key:
		return
	current_animation = key
	animation_player.play(animations[key], 0.14)

