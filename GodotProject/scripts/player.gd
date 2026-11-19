extends CharacterBody3D

@export var walk_speed := 6.0
@export var run_speed := 9.0
@export var acceleration := 18.0
@export var gravity := 18.0
var touch_move := Vector2.ZERO
var camera_yaw := 0.0

func _physics_process(delta: float) -> void:
	var input := Input.get_vector("move_left","move_right","move_forward","move_back")
	if touch_move.length() > 0.08:
		input = touch_move
	var direction := Vector3(input.x,0,input.y).rotated(Vector3.UP,camera_yaw)
	if direction.length() > 0.1:
		rotation.y = lerp_angle(rotation.y, atan2(-direction.x,-direction.z), delta*10.0)
	var speed := run_speed if Input.is_action_pressed("sprint") else walk_speed
	velocity.x = move_toward(velocity.x,direction.x*speed,acceleration*delta)
	velocity.z = move_toward(velocity.z,direction.z*speed,acceleration*delta)
	if not is_on_floor():
		velocity.y -= gravity*delta
	else:
		velocity.y = -0.2
	move_and_slide()
