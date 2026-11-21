extends Control

var stick_vector := Vector2.ZERO
var stick_touch_id := -1
var active_buttons: Dictionary = {}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process_input(true)
	queue_redraw()

func _layout() -> Dictionary:
	var s := get_viewport_rect().size
	return {
		"stick": Vector2(132.0, s.y - 132.0),
		"run": Vector2(s.x - 250.0, s.y - 125.0),
		"jump": Vector2(s.x - 112.0, s.y - 205.0),
		"use": Vector2(s.x - 112.0, s.y - 76.0),
		"attack": Vector2(s.x - 250.0, s.y - 260.0)
	}

func _draw() -> void:
	var p := _layout()
	var base: Vector2 = p.stick
	draw_circle(base, 72, Color(0.02, 0.04, 0.08, 0.40))
	draw_arc(base, 72, 0, TAU, 48, Color(0.20, 0.85, 1.0, 0.72), 3.0)
	draw_circle(base + stick_vector * 43.0, 29, Color(0.25, 0.85, 1.0, 0.78))
	_draw_button(p.run, 53.0, "БЕГ", "run")
	_draw_button(p.jump, 56.0, "ПРЫЖОК", "jump")
	_draw_button(p.use, 48.0, "МАШИНА", "use")
	_draw_button(p.attack, 55.0, "УДАР", "attack")

func _draw_button(center: Vector2, radius: float, caption: String, key: String) -> void:
	var held := active_buttons.values().has(key)
	var fill := Color(0.04, 0.18, 0.25, 0.76) if held else Color(0.02, 0.04, 0.08, 0.48)
	var edge := Color(0.20, 0.85, 1.0, 0.9) if key == "jump" else Color(1.0, 0.55, 0.3, 0.82)
	draw_circle(center, radius, fill)
	draw_arc(center, radius, 0, TAU, 48, edge, 3.0)
	var font := ThemeDB.fallback_font
	var font_size := 17 if key == "jump" else 16
	var width := font.get_string_size(caption, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	draw_string(font, center + Vector2(-width * 0.5, 6), caption, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color.WHITE)

func _input(event: InputEvent) -> void:
	var p := _layout()
	if event is InputEventScreenTouch:
		if event.pressed:
			if event.position.distance_to(p.stick) < 105.0 and stick_touch_id == -1:
				stick_touch_id = event.index
				_update_stick(event.position, p.stick)
			else:
				var button := _button_at(event.position, p)
				if button != "":
					active_buttons[event.index] = button
					_apply_button(button, true)
					queue_redraw()
		else:
			if event.index == stick_touch_id:
				stick_touch_id = -1
				stick_vector = Vector2.ZERO
				_send_move()
			if active_buttons.has(event.index):
				var button: String = active_buttons[event.index]
				active_buttons.erase(event.index)
				_apply_button(button, false)
			queue_redraw()
	elif event is InputEventScreenDrag and event.index == stick_touch_id:
		_update_stick(event.position, p.stick)

func _button_at(pos: Vector2, p: Dictionary) -> String:
	if pos.distance_to(p.attack) < 65.0:
		return "attack"
	if pos.distance_to(p.jump) < 68.0:
		return "jump"
	if pos.distance_to(p.run) < 65.0:
		return "run"
	if pos.distance_to(p.use) < 60.0:
		return "use"
	return ""

func _apply_button(button: String, pressed: bool) -> void:
	var world := get_tree().current_scene
	if not world:
		return
	if not world.has_node("Player"):
		return
	var actor = world.get_node("Player")
	if button == "run":
		actor.touch_sprint = pressed
	elif button == "jump" and pressed:
		actor.touch_jump_pressed = true
	elif button == "use" and pressed:
		world.call("_toggle_vehicle")

func _update_stick(pos: Vector2, base: Vector2) -> void:
	stick_vector = ((pos - base) / 65.0).limit_length(1.0)
	_send_move()
	queue_redraw()

func _send_move() -> void:
	var world := get_tree().current_scene
	if world and world.has_node("Player") and world.has_node("Car"):
		if world.in_car:
			world.get_node("Car").throttle_touch = -stick_vector.y
			world.get_node("Car").steering_touch = stick_vector.x
		else:
			world.get_node("Player").touch_move = stick_vector
