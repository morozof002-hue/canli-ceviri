extends CharacterBody3D

var health := 3
var wander_dir := Vector3.ZERO
var wander_timer := 0.0
var hit_flash := 0.0
var body_material: StandardMaterial3D

func _ready() -> void:
	add_to_group("fightable_npc")
	body_material = StandardMaterial3D.new()
	body_material.albedo_color = Color(0.25, 0.55, 0.78)
	body_material.roughness = 0.72
	var shirt := MeshInstance3D.new()
	var torso := CapsuleMesh.new()
	torso.radius = 0.31
	torso.height = 0.9
	shirt.mesh = torso
	shirt.position.y = 1.18
	shirt.material_override = body_material
	add_child(shirt)
	var head := MeshInstance3D.new()
	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.23
	head_mesh.height = 0.46
	head.mesh = head_mesh
	head.position.y = 1.88
	head.material_override = _make_mat(Color(0.72, 0.49, 0.34))
	add_child(head)
	for side in [-1.0, 1.0]:
		var leg := MeshInstance3D.new()
		var leg_mesh := CapsuleMesh.new()
		leg_mesh.radius = 0.12
		leg_mesh.height = 0.78
		leg.mesh = leg_mesh
		leg.position = Vector3(side * 0.15, 0.48, 0)
		leg.material_override = _make_mat(Color(0.12, 0.16, 0.23))
		add_child(leg)
		var arm := MeshInstance3D.new()
		var arm_mesh := CapsuleMesh.new()
		arm_mesh.radius = 0.095
		arm_mesh.height = 0.72
		arm.mesh = arm_mesh
		arm.position = Vector3(side * 0.39, 1.22, 0)
		arm.rotation.z = side * -0.12
		arm.material_override = _make_mat(Color(0.72, 0.49, 0.34))
		add_child(arm)
	var collision := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.85
	collision.shape = capsule
	collision.position.y = 0.92
	add_child(collision)
	# Keep NPCs light on mobile: simple wander, no navigation mesh required.
	wander_dir = Vector3.RIGHT.rotated(Vector3.UP, randf() * TAU)

func _physics_process(delta: float) -> void:
	wander_timer -= delta
	if wander_timer <= 0.0:
		wander_timer = randf_range(1.2, 3.5)
		wander_dir = Vector3.RIGHT.rotated(Vector3.UP, randf() * TAU)
	velocity.x = move_toward(velocity.x, wander_dir.x * 0.65, delta * 2.0)
	velocity.z = move_toward(velocity.z, wander_dir.z * 0.65, delta * 2.0)
	velocity.y = -0.3
	move_and_slide()
	if Vector2(velocity.x, velocity.z).length() > 0.1:
		rotation.y = atan2(-velocity.x, -velocity.z)
	if hit_flash > 0.0:
		hit_flash -= delta
		body_material.albedo_color = Color(1.0, 0.22, 0.16)
	else:
		body_material.albedo_color = Color(0.25, 0.55, 0.78)

func take_hit(from_position: Vector3) -> void:
	if health <= 0:
		return
	health -= 1
	hit_flash = 0.18
	var push := global_position - from_position
	push.y = 0.0
	if push.length() > 0.01:
		velocity += push.normalized() * 4.0
	if health <= 0:
		queue_free()

func _make_mat(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.8
	return material
