extends CharacterBody3D

@export var acceleration := 22.0
@export var max_speed := 25.0
@export var turn_speed := 1.5
var throttle_touch := 0.0
var steering_touch := 0.0
var active := false

func _ready() -> void:
	set_physics_process(false)
	var camera := Camera3D.new()
	camera.name = "Camera3D"
	camera.position = Vector3(0,5.2,9.0)
	camera.rotation_degrees = Vector3(-20,0,0)
	add_child(camera)

func _physics_process(delta: float) -> void:
	var throttle := Input.get_action_strength("move_forward") - Input.get_action_strength("move_back")
	var steer := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	if abs(throttle_touch) > 0.05:
		throttle = throttle_touch
	if abs(steering_touch) > 0.05:
		steer = steering_touch
	velocity.x = -sin(rotation.y) * velocity.length()
	velocity.z = -cos(rotation.y) * velocity.length()
	var forward := -global_transform.basis.z
	var current := velocity.dot(forward)
	current = move_toward(current, throttle*max_speed, acceleration*delta)
	velocity = forward*current
	if abs(current) > 0.8:
		rotation.y -= steer*turn_speed*delta*sign(current)
	move_and_slide()
