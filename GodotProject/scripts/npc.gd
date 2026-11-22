extends CharacterBody3D

const HERO_SCENE = preload("res://assets/character/neon_coast_hero.glb")
const DIALOGUE_LINES := [
	"Да какого хрена опять жара, я уже заебался!",
	"Ну и хрень творится в этом городе, просто пиздец.",
	"Кто, блядь, поставил эту тачку посреди дороги?!",
	"Да пошло оно всё нахуй, сегодня ни черта не получается.",
	"Какого хуя автобус опять не пришёл?",
	"Заебали эти пробки, честное слово!",
	"Вот же пиздец, опять цены подняли!",
	"Да ебаный в рот, где я оставил ключи?",
	"Не день, а какая-то хуйня собачья.",
	"Кто-нибудь видел этого мудака, который орёт с утра?",
	"Блядь, кофе остыл. Ну что за день такой?",
	"Да чтоб меня, опять эта грёбаная музыка у соседей!",
	"Мне бы пожрать нормально, а не эту херню.",
	"Какого чёрта все сегодня такие злые?",
	"Да ну нахер такую работу, сил уже нет.",
	"Этот город охуенный, если не считать идиотов вокруг.",
	"Пиздец, чуть не навернулся на этой хреновине!",
	"Слышь, дружище, не стой посреди прохода, ё-моё!",
	"Да блин, опять опаздываю. Всё через жопу!",
	"Кто спиздил мои сигареты? Вот же крыса!",
	"Ебаный ремонт, третий день долбят с утра!",
	"Да что за хуйня с этой машиной? Опять не заводится!",
	"Мне сегодня вообще никто не нужен, идите нахер.",
	"Блядь, солнце жарит так, будто нас решили поджарить!",
	"У кого тут можно купить нормальную жратву, а не эту дрянь?",
	"Да ёбаный случай, опять телефон сел!",
	"Вот же засранец, всю очередь без очереди пролез!",
	"Какого хрена тут так дорого? Они охренели совсем?",
	"Плевать я хотел на эти ваши правила, достали уже.",
	"Да чтоб всё провалилось, опять колесо спустило!",
	"Пиздец, я думал сегодня будет спокойный день.",
	"Эй, не пялься на меня, иди своей дорогой!",
	"К чёрту планы, сегодня просто нажрусь газировки и буду отдыхать.",
	"Блядь, кто опять бросил мусор прямо на тротуаре?",
	"Да заебало всё это: шум, жара и тупые рожи!",
	"Нормально же сидели, какого беса всем понадобилось орать?",
	"Чёртова развалюха, сдохни уже или заведи́сь!",
	"Да ну нахуй, я в эту драку не полезу… наверное.",
	"Какой же идиот придумал парковку в этом месте?",
	"У меня настроение паршивое, так что не еби мне мозги.",
	"Блядь, опять забыл кошелёк. Старею, что ли?",
	"Да пиздец, море красивое, а вокруг одни крикуны.",
	"Кто-нибудь заткнёт эту сигнализацию? Она уже мозг выела!",
	"Да пошло всё к чёрту, пойду лучше поем.",
	"Ну и денёк, сплошная задница на колёсах!",
	"Какого хрена ты так медленно плетёшься, приятель?"
]
const ANGRY_LINES := [
	"Ты охуевший ублюдок, ебаный мудак! Получай!",
	"Ты чё, гандон заёбанный, совсем берега попутал?!",
	"Ах ты пиздюк конченый, иди сюда, я тебе щас втащу!",
	"Пошёл нахуй, кусок говна! Не лезь ко мне!",
	"Ты охуел, что ли, ебаная мразь?!",
	"Уёбок тупорылый, я тебе сейчас харю начищу!",
	"Гандон ты дырявый, руки свои убрал!",
	"Ты охуевшая тварь, щас огребёшь по полной!",
	"Какого хуя ты до меня доебался, мудак?!",
	"Ебаный придурок, вали отсюда нахрен!",
	"Ты, блядь, совсем отбитый ублюдок?!",
	"Слышь, гондон засраный, тебе жить надоело?!",
	"Ах ты залупоглазый мудак, получай!",
	"Отъебись от меня, конченый придурок!",
	"Ты охуевший кусок дерьма, сейчас пожалеешь!",
	"Ещё раз тронешь — пизды получишь, гнида!",
	"Ты чё творишь, ебанат тупой?!",
	"Мразь ебаная, иди нахуй со своими предъявами!",
	"Да ты охуел в край, говно собачье!",
	"Сука, какой же ты конченый долбоёб!",
	"Ублюдок ебаный, я тебе сейчас башку откручу!",
	"Не стой, блядь, как дебил, подходи!",
	"Ты мне ещё указывать будешь, гандон несчастный?!",
	"Пошёл в жопу, чмо поганое!",
	"Ебаный ты выродок, отвали нахуй!",
	"Ты чё, самый умный, мудак тупорылый?!",
	"Да засунь свои угрозы себе в задницу, ублюдок!",
	"Сука, я тебе сейчас устрою весёлую жизнь!",
	"Охреневший гондон, проваливай, пока цел!",
	"Ты, блядь, нарываешься, кусок говна!",
	"Ебать ты наглый, уёбок! Сейчас получишь!",
	"Не беси меня, долбоёб конченый!",
	"Да пошёл ты нахуй, мудила вонючая!",
	"Ты охуевший ублюдок, ещё и огрызаешься?!",
	"Слышь, гандон заёбанный, закрой свой рот!",
	"Я тебе сейчас ебало разобью, мразота!",
	"Какого хуя ты меня трогаешь, сука тупая?!",
	"Тебе пиздец, уёбок! Сам напросился!",
	"Вали нахуй, пока я тебе рыло не расквасил!",
	"Ты конченый мудак, мать твою!",
	"Ещё слово, блядь, и огребёшь!",
	"Долбоёб несчастный, отойди от меня!",
	"Сука ебаная, я тебя предупреждал!",
	"Ты совсем страх потерял, гондон поганый?!",
	"Иди нахуй, кусок ебаного дерьма!"
]
var health := 8
var wander_dir := Vector3.ZERO
var wander_timer := 0.0
var talk_cooldown := 0.0
var attack_cooldown := 0.0
var hop_cooldown := 0.0
var personal_speed := 0.0
var respawn_delay := 22.0
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
	visual.scale = Vector3.ONE * randf_range(0.90, 1.08)
	personal_speed = randf_range(2.3, 3.1)
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
	hop_cooldown = maxf(0.0, hop_cooldown - delta)
	attack_cooldown = maxf(0.0, attack_cooldown - delta)
	var moving := false
	if is_angry and is_instance_valid(player_ref):
		var offset: Vector3 = player_ref.global_position - global_position
		offset.y = 0.0
		var distance := offset.length()
		if distance > 1.45:
			var direction := offset.normalized()
			velocity.x = move_toward(velocity.x, direction.x * personal_speed, delta * 7.0)
			velocity.z = move_toward(velocity.z, direction.z * personal_speed, delta * 7.0)
			_try_hop(direction)
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
		velocity.z = move_toward(velocity.z, wander_dir.z * personal_speed * 0.35, delta * 2.2)
		_try_hop(wander_dir)
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
		get_tree().create_timer(respawn_delay).timeout.connect(_revive)


func _try_hop(direction: Vector3) -> void:
	if hop_cooldown > 0.0 or not is_on_floor() or direction.length() < 0.1:
		return
	var flat := direction.normalized()
	var space := get_world_3d().direct_space_state
	var low_from := global_position + Vector3.UP * 0.45
	var high_from := global_position + Vector3.UP * 1.25
	var low_query := PhysicsRayQueryParameters3D.create(low_from, low_from + flat * 0.85)
	low_query.exclude = [get_rid()]
	var high_query := PhysicsRayQueryParameters3D.create(high_from, high_from + flat * 0.85)
	high_query.exclude = [get_rid()]
	var low_hit := space.intersect_ray(low_query)
	var high_hit := space.intersect_ray(high_query)
	if not low_hit.is_empty() and high_hit.is_empty():
		velocity.y = 5.0
		hop_cooldown = 1.25
		_play_animation("jump")

func _revive() -> void:
	if not is_inside_tree():
		return
	health = 8
	is_down = false
	is_angry = false
	velocity = Vector3.ZERO
	collision_layer = 1
	collision_mask = 1
	for child in get_children():
		if child is CollisionShape3D:
			child.set_deferred("disabled", false)
	current_animation = ""
	_play_animation("idle")
	set_physics_process(true)
	talk_cooldown = randf_range(3.0, 6.0)

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
