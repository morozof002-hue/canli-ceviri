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
	"Иди нахуй, кусок ебаного дерьма!",
	"Ты чё, бессмертный, что ли, кусок ебаного картона?!",
	"Мать твою за ногу, отойди, пока я не вскипел!",
	"Уёбище, ты решил сегодня проверить прочность своих зубов?!",
	"Да ты охренел настолько, что даже стены от тебя отворачиваются!",
	"Слышь, обмудок, мозги включи, если они там вообще есть!",
	"Ты как умудрился быть таким конченым и ещё ходить по улицам?!",
	"Ебаный ты цирк на ножках, проваливай отсюда!",
	"Тебя кто выпустил, недоделанный ты кусок неприятностей?!",
	"Ты мне сейчас весь день испортил, говнюк ты ходячий!",
	"Да у тебя вместо мозгов прокисшая каша, придурок!",
	"Свали нахрен, пока я не начал объяснять кулаками!",
	"Ты, блядь, ходячая авария, смотри куда прёшь!",
	"Какого чёрта ты вылупился, будто впервые человека увидел?!",
	"У тебя совесть в отпуске, а мозги уволились, да?!",
	"Ещё шаг, и будешь собирать свою наглость по асфальту!",
	"Ты настолько тупой, что даже грабли тебя обходят стороной!",
	"Не испытывай моё терпение, оно и так на последнем матерном слове!",
	"Охреневший кусок недоразумения, исчезни с глаз!",
	"Ты чё, решил стать главным идиотом этого района?!",
	"Да чтоб тебя ветром унесло, вместе с твоими понтами!",
	"Не ори на меня, говно с претензией на человека!",
	"Ты сначала научись думать, а потом уже открывай эту помойку!",
	"Ебаный ты пассажир без тормозов, успокойся!",
	"Тебе бы рот закрыть и инструкцию к мозгам найти!",
	"Ты меня за кого держишь, за бесплатную мишень, что ли?!",
	"Пиздец, у тебя наглости на десятерых, а ума на полкнопки!",
	"Отвали, пока я не превратил твой гонор в воспоминание!",
	"Ты чё несёшь, словесный мусорный бак?!",
	"Сгинь с дороги, пока я не потерял остатки воспитания!",
	"Да ты просто ходячий сбой природы, мать твою!",
	"Гандон несчастный, не стой у меня над душой!",
	"Ты бы лучше молчал, умнее бы выглядел, дебил!",
	"Ещё раз полезешь — будешь жалеть о каждом своём шаге!",
	"Ты, блядь, как таракан: откуда ни возьмись и всем мешаешь!",
	"Уёбок, не путай моё спокойствие с разрешением хамить!",
	"Даже моя старая обувь соображает быстрее тебя!",
	"Слышь, чудо в перьях, убери своё недовольное рыло!",
	"Ты что, по жизни такой ебанутый или сегодня праздник?!",
	"Проваливай, пока я не начал разговаривать на языке асфальта!",
	"Да ты не наглый, ты просто неисправимый долбоёб!",
	"Хватит выпендриваться, дешёвый герой помойного переулка!",
	"Убери свои лапы, гнида, я тебе не банкомат!",
	"Ты мне сейчас расскажешь, какого хрена творишь!",
	"Ебаный самоуверенный мешок с проблемами, отойди!",
	"Тебе кто разрешил тут борзеть, районный клоун?!",
	"Не беси меня, а то я забуду, что мы на людях!",
	"Ты, похоже, родился с инструкцией наоборот, придурок!",
	"Слышь, кусок бесполезного дерьма, разговор окончен!",
	"Твоё мнение мне нужно, как дырка в бензобаке, мудак!",
	"Ты так громко несёшь чушь, что уши сами увольняются!",
	"Отойди, пока я не начал делать глупости быстрее тебя!",
	"Блядь, да ты не человек, а ходячая проверка нервов!",
	"Я сейчас настолько зол, что даже голуби держатся подальше!",
	"Ты чё, решил докопаться до самого терпеливого психа района?!",
	"Не подходи ко мне со своей ебаной уверенностью!",
	"Тебе бы язык помыть и характер выбросить, урод!",
	"Ты, мать твою, даже извиняешься наверняка с угрозами!",
	"Вали отсюда, пока твоя наглость не встретилась с асфальтом!",
	"Ещё одно слово — и начнётся очень плохой разговор!",
	"Ты как мусорный пакет: шума много, пользы ноль!",
	"Не строй из себя босса, ты даже на массовку не тянешь!",
	"Какого хуя ты решил, что тебе всё можно?!",
	"Тебя бы в музей отправить: экспонат «ошибка сборки»!",
	"Да ты конченый чемпион по созданию проблем!",
	"Уйди с глаз, пока я не начал материться на древних языках!",
	"Ты, блядь, не искра, ты целый пожар идиотизма!",
	"Слышь, пень с амбициями, не испытывай судьбу!",
	"Тебе бы тормоза купить, а заодно и мозги в комплекте!",
	"Я не обязан терпеть твоё ебаное представление!",
	"Ты сейчас нарываешься с такой скоростью, что сам не заметишь!",
	"Отвали, а то мой кулак уже хочет познакомиться с тобой!",
	"Ебаный ты мастер портить людям настроение!",
	"У тебя талант: открыть рот и сразу всех достать!",
	"Ты чё, решил проверить, насколько у меня короткий фитиль?!",
	"Свали в туман, пока я не устроил тебе экскурсию по неприятностям!",
	"Ты не борзый, ты просто плохо воспитанный кусок хаоса!",
	"Блядь, даже мусорный бак выглядит приличнее твоего поведения!",
	"Слышь, гнида, не делай вид, что не понял предупреждение!",
	"Ты мне тут спектакль не устраивай, клоун хренов!",
	"Да заткнись ты уже, словесная канализация!",
	"Твоё присутствие — это прям отдельный вид наказания!",
	"Ещё раз подойдёшь — и разговор станет очень коротким!",
	"Ты, блядь, ходячее доказательство, что мозг не всем выдают!",
	"Собрался хамить — хотя бы делай это не так тупо!",
	"Уёбок, не заставляй меня повторять дважды!",
	"Как же ты меня заебал, ходячий генератор проблем!",
	"Да пошёл ты к чёрту, вместе со своим поганым характером!",
	"Не трогай меня, пока я окончательно не охуел!",
	"Ты настолько неприятный, что даже тень от тебя уходит!",
	"Ебаный ты пассажир, выйди из моей жизни и с тротуара!",
	"Сейчас бы твою самоуверенность да в мусорный контейнер!",
	"Не стой столбом, проваливай, пока цел!",
	"Ты, блядь, даже конфликтуешь как последний дилетант!",
	"Мудак, у тебя совести меньше, чем шума от мопеда!",
	"Закрой варежку, пока я не начал отвечать без цензуры!",
	"Да ты просто ходячий повод для нервного срыва!",
	"Убирайся, пока я ещё помню слова без мата!",
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
var dialogue_bag: Array = []
var angry_bag: Array = []
var dialogue_manager: Node
var rival_target: Node3D
var aggression := 0.0
var rival_scan_timer := 0.0
var step_height := 0.38

func _ready() -> void:
	add_to_group("fightable_npc")
	visual = HERO_SCENE.instantiate()
	visual.name = "CivilianVisual"
	visual.rotation.y = PI
	visual.scale = Vector3(randf_range(0.91, 1.08), randf_range(0.94, 1.09), randf_range(0.91, 1.08))
	_customize_appearance()
	dialogue_manager = get_tree().get_first_node_in_group("npc_dialogue_manager")
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
	collision_layer = 1
	collision_mask = 1
	safe_margin = 0.08
	floor_snap_length = 0.32
	floor_max_angle = deg_to_rad(52.0)
	floor_stop_on_slope = true
	aggression = randf_range(0.0, 1.0)
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
	rival_scan_timer = maxf(0.0, rival_scan_timer - delta)
	if not is_instance_valid(rival_target) or rival_target.get("is_down"):
		rival_target = null
		if rival_scan_timer <= 0.0:
			rival_scan_timer = randf_range(2.5, 5.5)
			if aggression > 0.68:
				_pick_rival()
	var moving := false
	if is_instance_valid(rival_target):
		var rival_offset: Vector3 = rival_target.global_position - global_position
		rival_offset.y = 0.0
		var rival_distance := rival_offset.length()
		if rival_distance > 1.35:
			var rival_direction := rival_offset.normalized()
			velocity.x = move_toward(velocity.x, rival_direction.x * personal_speed * 1.08, delta * 7.0)
			velocity.z = move_toward(velocity.z, rival_direction.z * personal_speed * 1.08, delta * 7.0)
			rotation.y = atan2(-rival_direction.x, -rival_direction.z)
			_play_animation("walk")
			moving = true
		else:
			velocity.x = move_toward(velocity.x, 0.0, delta * 12.0)
			velocity.z = move_toward(velocity.z, 0.0, delta * 12.0)
			_play_animation("attack")
			if attack_cooldown <= 0.0:
				attack_cooldown = randf_range(0.9, 1.45)
				rival_target.call("take_hit", global_position, self)
				_speak_random(ANGRY_LINES)
	elif is_angry and is_instance_valid(player_ref):
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
	_apply_crowd_separation()
	_try_step_up(delta)
	velocity.y = -0.3 if is_on_floor() else velocity.y - 22.0 * delta
	move_and_slide()

func _update_dialogue() -> void:
	if not is_instance_valid(player_ref) or is_down or is_angry:
		return
	if global_position.distance_to(player_ref.global_position) < 7.0 and talk_cooldown <= 0.0:
		_speak_random(DIALOGUE_LINES)
		talk_cooldown = randf_range(5.0, 9.0)

func _speak_random(lines: Array) -> void:
	if russian_voices.is_empty() or lines.is_empty():
		return
	var bag: Array
	if lines == ANGRY_LINES:
		if angry_bag.is_empty():
			angry_bag = lines.duplicate()
			angry_bag.shuffle()
		bag = angry_bag
	else:
		if dialogue_bag.is_empty():
			dialogue_bag = lines.duplicate()
			dialogue_bag.shuffle()
		bag = dialogue_bag
	var line: String = bag.pop_back()
	var voice_id: String = russian_voices[randi() % russian_voices.size()]
	var rate := 95 + randi_range(-9, 9)
	var pitch := randf_range(0.82, 1.16)
	if is_instance_valid(dialogue_manager):
		dialogue_manager.call("queue_line", get_instance_id(), line, voice_id, rate, pitch)
	else:
		DisplayServer.tts_speak(line, voice_id, rate, 1.0, pitch, get_instance_id(), true)


func _pick_rival() -> void:
	var candidates := get_tree().get_nodes_in_group("fightable_npc")
	var best: Node3D = null
	var best_distance := 8.5
	for candidate in candidates:
		if candidate == self or not is_instance_valid(candidate) or candidate.get("is_down"):
			continue
		var distance := global_position.distance_to(candidate.global_position)
		if distance < best_distance:
			best = candidate
			best_distance = distance
	if best != null and randf() < 0.72:
		rival_target = best
		is_angry = false
		_speak_random(ANGRY_LINES)

func take_hit(from_position: Vector3, attacker: Node3D = null) -> void:
	if is_down:
		return
	health -= 1
	if is_instance_valid(attacker) and attacker != self:
		rival_target = attacker
		is_angry = false
	else:
		is_angry = true
		rival_target = null
	talk_cooldown = 0.0
	_speak_random(ANGRY_LINES)
	var push := global_position - from_position
	push.y = 0.0
	if push.length() > 0.01:
		velocity = push.normalized() * 4.0
	if health <= 0:
		is_down = true
		is_angry = false
		rival_target = null
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


func _try_step_up(delta: float) -> void:
	if not is_on_floor():
		return
	var horizontal_motion := Vector3(velocity.x, 0.0, velocity.z) * delta
	if horizontal_motion.length() < 0.015:
		return
	var hit := KinematicCollision3D.new()
	if not test_move(global_transform, horizontal_motion, hit):
		return
	# Raise the capsule a small amount, then test whether the forward path is clear.
	var raised := global_transform
	raised.origin.y += step_height
	if test_move(raised, horizontal_motion):
		return
	global_position.y += step_height

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
	rival_target = null
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

func _customize_appearance() -> void:
	# Give each pedestrian a distinct silhouette and a restrained clothing tint.
	var palettes := [
		Color(0.82, 0.94, 1.0), Color(1.0, 0.82, 0.72),
		Color(0.78, 1.0, 0.82), Color(1.0, 0.94, 0.70),
		Color(0.88, 0.82, 1.0), Color(1.0, 0.80, 0.91),
		Color(0.78, 0.90, 0.96), Color(0.94, 0.94, 0.94)
	]
	var tint: Color = palettes[randi() % palettes.size()]
	var meshes: Array[MeshInstance3D] = []
	_collect_meshes(visual, meshes)
	for mesh_instance in meshes:
		if mesh_instance.mesh == null:
			continue
		for surface in range(mesh_instance.mesh.get_surface_count()):
			var source := mesh_instance.get_active_material(surface)
			if source is StandardMaterial3D:
				var material := (source as StandardMaterial3D).duplicate() as StandardMaterial3D
				material.albedo_color = material.albedo_color * tint
				mesh_instance.set_surface_override_material(surface, material)

func _collect_meshes(node: Node, result: Array[MeshInstance3D]) -> void:
	if node is MeshInstance3D:
		result.append(node as MeshInstance3D)
	for child in node.get_children():
		_collect_meshes(child, result)

func _apply_crowd_separation() -> void:
	if is_down:
		return
	var push := Vector3.ZERO
	for other in get_tree().get_nodes_in_group("fightable_npc"):
		if other == self or not is_instance_valid(other) or other.get("is_down"):
			continue
		var away: Vector3 = global_position - other.global_position
		away.y = 0.0
		var distance := away.length()
		if distance > 0.001 and distance < 0.95:
			push += away.normalized() * ((0.95 - distance) / 0.95)
	if push.length() > 0.01:
		var separation := push.normalized() * 1.8
		velocity.x = move_toward(velocity.x, velocity.x + separation.x, 8.0 * get_physics_process_delta_time())
		velocity.z = move_toward(velocity.z, velocity.z + separation.z, 8.0 * get_physics_process_delta_time())

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
