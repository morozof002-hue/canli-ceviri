extends Node

var pending: Array[Dictionary] = []
var active_speaker_id := 0
var active_listener_id := 0
var active_max_distance := 0.0

func queue_line(speaker_id: int, line: String, voice_id: String, rate: int, pitch: float, listener_id: int, max_distance: float = 12.0) -> void:
	pending.append({
		"speaker_id": speaker_id,
		"line": line,
		"voice_id": voice_id,
		"rate": rate,
		"pitch": pitch,
		"listener_id": listener_id,
		"max_distance": max_distance,
		"scene_id": 0
	})

func queue_conversation(turns: Array[Dictionary]) -> void:
	var scene_id := randi()
	for index in range(turns.size() - 1, -1, -1):
		var item := turns[index].duplicate()
		item["scene_id"] = scene_id
		pending.push_front(item)

func _process(_delta: float) -> void:
	# System TTS is not a 3D audio source. We enforce a listener radius and
	# cut off the current utterance if the hero walks out of hearing range.
	if DisplayServer.tts_is_speaking():
		if not _can_listener_hear(active_speaker_id, active_listener_id, active_max_distance):
			DisplayServer.tts_stop()
			_drop_active_scene()
			_clear_active()
		return
	_clear_active()

	while not pending.is_empty():
		var item: Dictionary = pending.pop_front()
		var speaker_id := int(item.get("speaker_id", 0))
		var listener_id := int(item.get("listener_id", 0))
		var max_distance := float(item.get("max_distance", 12.0))
		if not _can_listener_hear(speaker_id, listener_id, max_distance):
			if int(item.get("scene_id", 0)) != 0:
				_drop_scene(int(item["scene_id"]))
			continue
		var speaker := instance_from_id(speaker_id) as Node3D
		var listener := instance_from_id(listener_id) as Node3D
		var distance := speaker.global_position.distance_to(listener.global_position)
		var volume := clampi(int(round(100.0 * (1.0 - distance / max_distance))), 18, 100)
		var rate := clampf(float(item.get("rate", 100)) / 100.0, 0.75, 1.25)
		active_speaker_id = speaker_id
		active_listener_id = listener_id
		active_max_distance = max_distance
		DisplayServer.tts_speak(
			String(item["line"]),
			String(item["voice_id"]),
			volume,
			float(item["pitch"]),
			rate,
			speaker_id,
			true
		)
		return

func _can_listener_hear(speaker_id: int, listener_id: int, max_distance: float) -> bool:
	if speaker_id == 0 or listener_id == 0:
		return false
	var speaker_object := instance_from_id(speaker_id)
	var listener_object := instance_from_id(listener_id)
	if not is_instance_valid(speaker_object) or not is_instance_valid(listener_object):
		return false
	if not speaker_object is Node3D or not listener_object is Node3D:
		return false
	return (speaker_object as Node3D).global_position.distance_to((listener_object as Node3D).global_position) <= max_distance

func _drop_active_scene() -> void:
	# If the hero walks away mid-conversation, do not continue the remaining turns.
	var kept: Array[Dictionary] = []
	for item in pending:
		if int(item.get("scene_id", 0)) == 0:
			kept.append(item)
	pending = kept

func _drop_scene(scene_id: int) -> void:
	var kept: Array[Dictionary] = []
	for item in pending:
		if int(item.get("scene_id", 0)) != scene_id:
			kept.append(item)
	pending = kept

func _clear_active() -> void:
	active_speaker_id = 0
	active_listener_id = 0
	active_max_distance = 0.0
