extends Node

var pending: Array[Dictionary] = []
var current_utterance := false

func queue_line(speaker_id: int, line: String, voice_id: String, rate: int, pitch: float) -> void:
	# One shared speech channel: pedestrians wait instead of talking over each other.
	pending.append({
		"speaker_id": speaker_id,
		"line": line,
		"voice_id": voice_id,
		"rate": rate,
		"pitch": pitch
	})

func _process(_delta: float) -> void:
	if pending.is_empty():
		return
	if DisplayServer.tts_is_speaking():
		return
	var item: Dictionary = pending.pop_front()
	if not is_instance_id_valid(int(item["speaker_id"])):
		return
	DisplayServer.tts_speak(
		String(item["line"]),
		String(item["voice_id"]),
		int(item["rate"]),
		1.0,
		float(item["pitch"]),
		int(item["speaker_id"]),
		true
	)
