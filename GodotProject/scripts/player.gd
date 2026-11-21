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
var camera_yaw := 0.0
var animation_clock := 0.0
var left_leg: Node3D
var right_leg: Node3D
var left_arm: Node3D
var right_arm: Node3D
var torso: Node3D

func _ready() -> void:
	left_leg = get_node_or_null("CharacterVisual/LeftLegPivot")
	right_leg = get_node_or_null("CharacterVisual/RightLegPivot")
	left_arm = get_node_or_null("CharacterVisual/LeftArmPivot")
	right_arm = get_node_or_null("CharacterVisual/RightArmPivot")
	torso = get_node_or_null("CharacterVisual/Torso")

func _physics_process(delta: float) -> void:
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if touch_move.length() > 0.08:
		input = touch_move
	var direction := Vector3(input.x, 0.0, input.y).rotated(Vector3.UP, camera_yaw)
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
	_animate_character(delta, moving, running)

func _animate_character(delta: float, moving: bool, running: bool) -> void:
	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	var intensity := clampf(horizontal_speed / run_speed, 0.0, 1.0)
	var airborne := not is_on_floor()
	if moving and not airborne:
		animation_clock += delta * (10.0 if running else 6.5) * maxf(intensity, 0.35)
	var swing := sin(animation_clock) * 0.62 * intensity
	if airborne:
		swing = -0.28
	if left_leg:
		left_leg.rotation.x = lerpf(left_leg.rotation.x, swing, delta * 12.0)
	if right_leg:
		right_leg.rotation.x = lerpf(right_leg.rotation.x, -swing, delta * 12.0)
	if left_arm:
		left_arm.rotation.x = lerpf(left_arm.rotation.x, -swing * 0.72 - 0.08, delta * 12.0)
	if right_arm:
		right_arm.rotation.x = lerpf(right_arm.rotation.x, swing * 0.72 - 0.08, delta * 12.0)
	if torso:
		torso.rotation.z = lerpf(torso.rotation.z, -signf(velocity.x) * 0.025 * intensity, delta * 6.0)
