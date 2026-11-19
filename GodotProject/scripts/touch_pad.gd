extends Control

var player: CharacterBody3D
var car: CharacterBody3D
var stick_origin := Vector2.ZERO
var stick_vector := Vector2.ZERO
var dragging := false
var touch_id := -1

func _ready() -> void:
	set_process_input(true)
	queue_redraw()

func _draw() -> void:
	var base := Vector2(135,size.y-145)
	draw_circle(base,76,Color(0.02,0.04,0.08,0.42))
	draw_arc(base,76,0,TAU,48,Color(0.2,0.85,1.0,0.65),3)
	draw_circle(base+stick_vector*48, thirty(), Color(0.25,0.85,1.0,0.72))
	var right := Vector2(size.x-130,size.y-150)
	draw_circle(right,66,Color(0.02,0.04,0.08,0.35))
	draw_arc(right,66,0,TAU,48,Color(1.0,0.55,0.3,0.65),3)
	draw_string(ThemeDB.fallback_font, right+Vector2(-22,8), "RUN", HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color.WHITE)

func thirty() -> float:
	return 31.0

func _input(event: InputEvent) -> void:
	var base := Vector2(135,size.y-145)
	if event is InputEventScreenTouch:
		if event.pressed and event.position.distance_to(base) < 110:
			dragging = true
			touch_id = event.index
			_update_stick(event.position,base)
		elif not event.pressed and event.index == touch_id:
			dragging = false
			touch_id = -1
			stick_vector = Vector2.ZERO
			_send_move()
			queue_redraw()
	elif event is InputEventScreenDrag and dragging and event.index == touch_id:
		_update_stick(event.position,base)

func _update_stick(pos: Vector2, base: Vector2) -> void:
	stick_vector = ((pos-base)/65.0).limit_length(1.0)
	_send_move()
	queue_redraw()

func _send_move() -> void:
	var world := get_tree().current_scene
	if world and world.has_node("Player"):
		world.get_node("Player").touch_move = stick_vector
