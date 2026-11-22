extends CharacterBody3D

const HERO_SCENE = preload("res://assets/character/neon_coast_hero.glb")
const DIALOGUE_LINES := [
	"Ну и погодка сегодня — хоть весь день на пляже валяйся!",
	"Эй, дружище, ты местный или тоже потерялся?",
	"Говорят, у порта творится какая-то дичь.",
	"Вот это тачка! Интересно, сколько она жрёт бензина?",
	"Да чтоб меня морской ёж укусил!",
	"В этом городе даже пальмы выглядят богаче меня.",
	"Слушай, знаешь хороший бар? Только без туристических цен!",
	"Опять пробка. Да вы издеваетесь, что ли?",
	"Море шикарное, а жизнь — сплошной квест.",
	"Я сегодня обещал вести себя прилично. Уже надоело.",
	"Эй, красавчик, не загораживай проход!",
	"Кто украл мой сэндвич? Вот же засранец!",
	"Если увидишь копов — скажи, что меня тут не было.",
	"У меня план на вечер: поесть, поспать и никого не слушать.",
	"Да ну нафиг, опять эта жара!",
	"Видел цены на бензин? Скоро будем ездить на ослах.",
	"Город красивый, но народ иногда чудит по полной.",
	"Не стой столбом, приятель, жизнь проходит!",
	"Я не грубый. Просто кофе ещё не подействовал.",
	"Вот бы отпуск, отпуск и ещё раз отпуск.",
	"Слышь, аккуратнее! Тут вообще-то люди ходят.",
	"Чёрт побери, опять забыл ключи!",
	"Сегодня такой закат, что даже ворчать не хочется.",
	"Эй, не пялься, я тоже тебя впервые вижу.",
	"У меня всё под контролем. Почти. Ладно, ни черта не под контролем.",
	"Да чтоб эту развалюху! Где нормальный механик?",
	"Кто-нибудь видел, куда делась моя зарплата?",
	"Не жизнь, а сплошная карусель, мать её.",
	"Слушай, а ты всегда так быстро ходишь?",
	"Если ищешь приключения — ты их уже нашёл, дружок."
]
const ANGRY_LINES := [
	"Ты совсем охренел?! Получай!",
	"Эй! За такое ответишь!",
	"Ну всё, приятель, сам напросился!",
	"Руки убрал! Сейчас будет больно!",
	"Ты думаешь, я просто так это проглочу?!",
	"Вот же псих! На тебе!",
	"Давай, попробуй ещё раз — пожалеешь!",
	"Я тебе сейчас объясню по-хорошему!",
	"Отвали от меня, придурок!",
	"Ну держись, гад!"
]

var health := 8
var wander_dir := Vector3.ZERO
var wander_timer := 0.0
var talk_cooldown := 0.0
var attack_cooldown := 0.0
var body_material: StandardMaterial3D
var animation_player: AnimationPlayer
var animations: Dictionary = {}
var current_animation := ""
var visual: Node3D
var player_ref: Node3D
var is_down := false
var is_angry := false
var russian_voices: PackedStringArray = PackedStringArray()

func _ready() -> void:
	add_to_group("fightable_npc")
	visual = HERO_SCENE.instantiate()
	visual.name = "CivilianVisual"
	visual.rotation.y = PI
	visual.scale = Vector3.ONE * randf_range(0.88, 1.02)
	add_child(visual)
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
	wander_dir = Vector3.RIGHT.rotated(Vector3.UP, randf() * TAU)
	talk_cooldown = randf_range(2.0, 5.0)
	if DisplayServer.has_feature(DisplayServer.FEATURE_TEXT_TO_SPEECH):
		russian_voices = DisplayServer.tts_get_voices_for_language("ru")

func set_player_reference(target: Node3D) -> void:
	player_ref = target

func _physics_process(delta: float) -> void:
	if is_down:
		return
	talk_cooldown = maxf(0.0, talk_cooldown - delta)
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	var moving := false
	if is_angry and is_instance_valid(player_ref):
		var offset: Vector3 = player_ref.global_position - global_position
		offset.y = 0.0
		var distance := offset.length()
		if distance > 1.45:
			var direction := offset.normalized()
			velocity.x = move_toward(velocity.x, direction.x * 2.7, delta * 7.0)
			velocity.z = move_toward(velocity.z, direction.z * 2.7, delta * 7.0)
			rotation.y = atan2(-direction.x, -direction.z)
			moving = true
			_play_animation("walk")
		else:
			velocity.x = move_toward(velocity.x, 0.0, delta * 10.0)
			velocity.z = move_toward(velocity.z, 0.0, delta * 10.0)
			_play_animation("attack")
			if attack_cooldown <= 0.0:
				attack_cooldown = 1.35
				if player_ref.has_method("take_npc_hit"):
					player_ref.call("take_npc_hit", global_position)
				_speak_random(ANGRY_LINES)
	else:
		wander_timer -= delta
		if wander_timer <= 0.0:
			wander_timer = randf_range(1.8, 4.2)
			wander_dir = Vector3.RIGHT.rotated(Vector3.UP, randf() * TAU)
		velocity.x = move_toward(velocity.x, wander_dir.x * 0.8, delta * 2.2)
		velocity.z = move_toward(velocity.z, wander_dir.z * 0.8, delta * 2.2)
		moving = Vector2(velocity.x, velocity.z).length() > 0.12
		if moving:
			rotation.y = atan2(-velocity.x, -velocity.z)
			_play_animation("walk")
		else:
			_play_animation("idle")
		_update_dialogue()
	velocity.y = -0.3
	move_and_slide()

func _update_dialogue() -> void:
	if not is_instance_valid(player_ref) or is_down or is_angry:
		return
	if global_position.distance_to(player_ref.global_position) < 7.0 and talk_cooldown <= 0.0:
		_speak_random(DIALOGUE_LINES)
		talk_cooldown = randf_range(5.0, 9.0)

func _speak_random(lines: Array) -> void:
	if russian_voices.is_empty():
		return
	var line: String = lines[randi() % lines.size()]
	var voice_id: String = russian_voices[randi() % russian_voices.size()]
	DisplayServer.tts_speak(line, voice_id, 95, randf_range(0.88, 1.12), randf_range(0.88, 1.04), get_instance_id(), true)

func take_hit(from_position: Vector3) -> void:
	if is_down:
		return
	health -= 1
	is_angry = true
	talk_cooldown = 0.0
	_speak_random(ANGRY_LINES)
	var push := global_position - from_position
	push.y = 0.0
	if push.length() > 0.01:
		velocity = push.normalized() * 4.0
	if health <= 0:
		is_down = true
		is_angry = false
		DisplayServer.tts_stop()
		collision_layer = 0
		collision_mask = 0
		for child in get_children():
			if child is CollisionShape3D:
				child.set_deferred("disabled", true)
		_play_animation("death")
		set_physics_process(false)
		if not animations.has("death"):
			var tween := create_tween()
			tween.tween_property(visual, "rotation:z", visual.rotation.z + deg_to_rad(82.0), 0.45)

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
		if key.contains("idle"):
			animations["idle"] = animation_name
		elif key.contains("walk"):
			animations["walk"] = animation_name
		elif key.contains("death") or key.contains("fall"):
			animations["death"] = animation_name
		elif key.contains("punch") or key.contains("attack"):
			animations["attack"] = animation_name
	for key in ["idle", "walk"]:
		if animations.has(key):
			animation_player.get_animation(animations[key]).loop_mode = Animation.LOOP_LINEAR
	if animations.has("death"):
		animation_player.get_animation(animations["death"]).loop_mode = Animation.LOOP_NONE

func _play_animation(key: String) -> void:
	if animation_player == null or not animations.has(key) or current_animation == key:
		return
	current_animation = key
	animation_player.play(animations[key], 0.14)
