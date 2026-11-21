extends Node3D

const PLAYER_SCRIPT = preload("res://scripts/player.gd")
const CAR_SCRIPT = preload("res://scripts/car.gd")
var player: CharacterBody3D
var car: CharacterBody3D
var hud: CanvasLayer
var mission_marker: MeshInstance3D
var in_car := false
var mission_done := false
var mission_time := 0.0
var touch_interact_pressed := false

func _ready() -> void:
	_build_world()
	_build_player()
	_build_car()
	_build_hud()
	_build_marker()
	Engine.max_fps = 30
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func _process(delta: float) -> void:
	mission_time += delta
	if is_instance_valid(mission_marker):
		mission_marker.rotate_y(delta * 1.5)
		mission_marker.position.y = 1.5 + sin(mission_time * 2.0) * 0.22
	if not mission_done and player.global_position.distance_to(mission_marker.global_position) < 3.0:
		mission_done = true
		$HUD/Panel/Objective.text = "МИССИЯ ВЫПОЛНЕНА  •  +$500"
		$HUD/Panel/Objective.add_theme_color_override("font_color", Color(0.4, 1.0, 0.7))
	if Input.is_action_just_pressed("interact") or touch_interact_pressed:
		touch_interact_pressed = false
		_toggle_vehicle()
	if in_car:
		$HUD/Panel/Status.text = "ЗА РУЛЁМ  •  E — ВЫЙТИ"
	else:
		$HUD/Panel/Status.text = "ПЕШКОМ  •  E — СЕСТЬ В МАШИНУ"

func _build_world() -> void:
	var env := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = Color(0.025, 0.06, 0.17)
	sky_mat.sky_horizon_color = Color(0.98, 0.36, 0.25)
	sky_mat.ground_bottom_color = Color(0.02, 0.035, 0.07)
	sky_mat.ground_horizon_color = Color(0.25, 0.12, 0.18)
	sky.sky_material = sky_mat
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.55, 0.62, 0.82)
	environment.ambient_light_energy = 0.65
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	env.environment = environment
	add_child(env)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-32, -28, 0)
	sun.light_color = Color(1.0, 0.63, 0.43)
	sun.light_energy = 1.2
	add_child(sun)
	_make_box("Island", Vector3(0,-0.7,0), Vector3(170,1,130), Color(0.19,0.24,0.22))
	_make_box("Ocean", Vector3(0,-1.4,-82), Vector3(260,1,80), Color(0.025,0.19,0.31))
	_make_box("Beach", Vector3(0,-0.12,-28), Vector3(170,0.25,12), Color(0.78,0.59,0.35))
	_make_box("Boulevard", Vector3(0,-0.05,0), Vector3(170,0.25,15), Color(0.12,0.13,0.16))
	_make_box("Road", Vector3(0,0.0,18), Vector3(170,0.3,20), Color(0.07,0.08,0.11))
	for x in range(-80, 85, 10):
		_make_box("Lane", Vector3(x,0.17,18), Vector3(4,0.04,0.22), Color(0.95,0.75,0.38))
	for i in range(14):
		var x := -72.0 + float(i) * 11.0
		var depth := 10.0 + float((i * 7) % 4) * 3.0
		var h := 9.0 + float((i * 13) % 5) * 3.2
		var color: Color
		match i % 4:
			0: color = Color(0.83,0.48,0.31)
			1: color = Color(0.32,0.48,0.59)
			2: color = Color(0.82,0.71,0.51)
			_: color = Color(0.46,0.35,0.48)
		_make_building(Vector3(x, h/2.0, -2.0 - depth/2.0), Vector3(8.0,h,depth), color)
		_make_building(Vector3(x+3.5, h*0.34, 35.0), Vector3(6.0,h*0.68,10.0), color.darkened(0.18))
	for x in range(-75, 80, 15):
		_make_palm(Vector3(x,0,-23))
		_make_lamp(Vector3(x+7,0,5))
	for i in range(7):
		var x := -55.0 + i * 18.0
		_make_box("Neon sign", Vector3(x,5,-8), Vector3(4.2,0.35,0.15), Color(0.1,0.85,1.0))
		_make_box("Neon glow", Vector3(x,5.0,-8.12), Vector3(4.5,0.55,0.1), Color(0.03,0.35,0.65,0.35))

func _make_box(n: String, p: Vector3, s: Vector3, c: Color) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = s
	var node := MeshInstance3D.new()
	node.name = n
	node.mesh = mesh
	node.position = p
	node.material_override = _mat(c)
	add_child(node)
	if n in ["Island","Boulevard","Road","Beach"]:
		var body := StaticBody3D.new()
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = s
		shape.shape = box
		body.add_child(shape)
		body.position = p
		add_child(body)
	return node

func _make_building(p: Vector3, s: Vector3, c: Color) -> void:
	_make_box("Art-deco block", p, s, c)
	for floor in range(1, int(s.y/2.6)):
		for side: int in [-1,1]:
			var z: float = p.z + float(side) * (s.z/2.0 + 0.035)
			for wx in range(1, int(s.x/1.8)):
				var x := p.x - s.x/2.0 + float(wx)*1.8
				_make_box("Lit window", Vector3(x,p.y-s.y/2.0+1.5+floor*2.6,z), Vector3(0.8,1.15,0.08), Color(0.15,0.65,0.78) if (wx+floor)%3 else Color(1.0,0.67,0.32))

func _make_palm(p: Vector3) -> void:
	var trunk := CylinderMesh.new()
	trunk.top_radius = 0.22
	trunk.bottom_radius = 0.34
	trunk.height = 5.5
	var t := MeshInstance3D.new()
	t.mesh = trunk
	t.position = p + Vector3(0,2.75,0)
	t.material_override = _mat(Color(0.42,0.24,0.14))
	add_child(t)
	for i in range(7):
		var leaf := MeshInstance3D.new()
		var m := BoxMesh.new()
		m.size = Vector3(0.32,0.18,3.4)
		leaf.mesh = m
		leaf.position = p + Vector3(0,5.45,0)
		leaf.rotation.y = TAU * float(i)/7.0
		leaf.rotation.x = -0.25
		leaf.material_override = _mat(Color(0.12,0.38,0.22))
		add_child(leaf)

func _make_lamp(p: Vector3) -> void:
	_make_box("Street lamp", p+Vector3(0,3.0,0), Vector3(0.12,6,0.12), Color(0.12,0.15,0.19))
	_make_box("Lamp head", p+Vector3(0,6.1,0), Vector3(1.0,0.16,0.3), Color(1.0,0.72,0.35))

func _mat(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = 0.78
	return m

func _build_player() -> void:
	player = CharacterBody3D.new()
	player.name = "Player"
	player.set_script(PLAYER_SCRIPT)
	player.position = Vector3(0, 1, 24)
	add_child(player)

	var visual := Node3D.new()
	visual.name = "CharacterVisual"
	player.add_child(visual)

	var skin := _mat(Color(0.72, 0.46, 0.32))
	skin.roughness = 0.88
	var jacket := _mat(Color(0.035, 0.30, 0.34))
	jacket.roughness = 0.62
	var jacket_dark := _mat(Color(0.018, 0.13, 0.18))
	var shirt := _mat(Color(0.83, 0.82, 0.72))
	var pants := _mat(Color(0.055, 0.075, 0.12))
	var shoe := _mat(Color(0.035, 0.04, 0.055))
	var hair := _mat(Color(0.075, 0.045, 0.035))
	var eye := _mat(Color(0.018, 0.014, 0.012))
	var accent := _mat(Color(0.95, 0.48, 0.20))
	accent.metallic = 0.25

	# Athletic 1980s streetwear silhouette: bomber jacket, light shirt, dark denim.
	var torso := Node3D.new()
	torso.name = "Torso"
	visual.add_child(torso)
	_add_character_piece(torso, "Jacket", CapsuleMesh.new(), Vector3(0, 1.22, 0), Vector3(0.82, 0.88, 0.48), jacket)
	_add_character_piece(torso, "Shirt", BoxMesh.new(), Vector3(0, 1.23, -0.245), Vector3(0.24, 0.65, 0.045), shirt)
	_add_character_piece(torso, "JacketZip", BoxMesh.new(), Vector3(0, 1.22, -0.274), Vector3(0.025, 0.68, 0.018), accent)
	_add_character_piece(torso, "CollarLeft", BoxMesh.new(), Vector3(-0.105, 1.62, -0.20), Vector3(0.16, 0.12, 0.08), jacket_dark)
	_add_character_piece(torso, "CollarRight", BoxMesh.new(), Vector3(0.105, 1.62, -0.20), Vector3(0.16, 0.12, 0.08), jacket_dark)
	_add_character_piece(torso, "Neck", CapsuleMesh.new(), Vector3(0, 1.72, 0), Vector3(0.28, 0.32, 0.28), skin)

	# Head, hairline and readable facial features.
	_add_character_piece(torso, "Head", SphereMesh.new(), Vector3(0, 1.98, -0.015), Vector3(0.48, 0.57, 0.43), skin)
	_add_character_piece(torso, "Hair", SphereMesh.new(), Vector3(0, 2.16, 0.025), Vector3(0.50, 0.32, 0.46), hair)
	_add_character_piece(torso, "SideHairL", BoxMesh.new(), Vector3(-0.205, 2.02, 0.025), Vector3(0.075, 0.27, 0.30), hair)
	_add_character_piece(torso, "SideHairR", BoxMesh.new(), Vector3(0.205, 2.02, 0.025), Vector3(0.075, 0.27, 0.30), hair)
	_add_character_piece(torso, "EyeL", SphereMesh.new(), Vector3(-0.095, 2.015, -0.207), Vector3(0.045, 0.035, 0.025), eye)
	_add_character_piece(torso, "EyeR", SphereMesh.new(), Vector3(0.095, 2.015, -0.207), Vector3(0.045, 0.035, 0.025), eye)
	_add_character_piece(torso, "Nose", SphereMesh.new(), Vector3(0, 1.965, -0.235), Vector3(0.055, 0.075, 0.07), skin)

	# Arms are separate pivots so the walk/run cycle can animate them.
	for side in [-1, 1]:
		var arm := Node3D.new()
		arm.name = "LeftArmPivot" if side == -1 else "RightArmPivot"
		arm.position = Vector3(float(side) * 0.39, 1.55, 0)
		visual.add_child(arm)
		_add_character_piece(arm, "Sleeve", CapsuleMesh.new(), Vector3(0, -0.31, 0), Vector3(0.31, 0.78, 0.31), jacket)
		_add_character_piece(arm, "Cuff", CylinderMesh.new(), Vector3(0, -0.62, 0), Vector3(0.22, 0.10, 0.22), jacket_dark)
		_add_character_piece(arm, "Hand", SphereMesh.new(), Vector3(0, -0.76, -0.005), Vector3(0.19, 0.22, 0.16), skin)

	# Jeans, articulated legs and sneakers.
	_add_character_piece(visual, "Waist", BoxMesh.new(), Vector3(0, 0.91, 0), Vector3(0.62, 0.25, 0.38), pants)
	for side in [-1, 1]:
		var leg := Node3D.new()
		leg.name = "LeftLegPivot" if side == -1 else "RightLegPivot"
		leg.position = Vector3(float(side) * 0.17, 0.86, 0)
		visual.add_child(leg)
		_add_character_piece(leg, "Jeans", CapsuleMesh.new(), Vector3(0, -0.36, 0), Vector3(0.31, 0.82, 0.34), pants)
		_add_character_piece(leg, "Sneaker", BoxMesh.new(), Vector3(0, -0.77, -0.075), Vector3(0.34, 0.18, 0.52), shoe)
		_add_character_piece(leg, "Sole", BoxMesh.new(), Vector3(0, -0.855, -0.075), Vector3(0.35, 0.045, 0.53), shirt)

	var col := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.34
	shape.height = 1.92
	col.shape = shape
	col.position.y = 0.96
	player.add_child(col)

	var camera := Camera3D.new()
	camera.name = "Camera3D"
	camera.position = Vector3(0, 3.7, 6.8)
	camera.rotation_degrees = Vector3(-17, 0, 0)
	camera.current = true
	player.add_child(camera)

func _add_character_piece(parent: Node3D, piece_name: String, mesh: Mesh, pos: Vector3, piece_scale: Vector3, material: Material) -> MeshInstance3D:
	var piece := MeshInstance3D.new()
	piece.name = piece_name
	piece.mesh = mesh
	piece.position = pos
	piece.scale = piece_scale
	piece.material_override = material
	parent.add_child(piece)
	return piece

func _build_car() -> void:
	car = CharacterBody3D.new()
	car.name = "Car"
	car.set_script(CAR_SCRIPT)
	car.position = Vector3(4,0.6,18)
	add_child(car)
	var shell := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(2.1,0.85,4.2)
	shell.mesh = mesh
	shell.position.y = 0.55
	shell.material_override = _mat(Color(0.83,0.19,0.23))
	car.add_child(shell)
	var roof := MeshInstance3D.new()
	var roofmesh := BoxMesh.new()
	roofmesh.size = Vector3(1.7,0.65,2.0)
	roof.mesh = roofmesh
	roof.position = Vector3(0,1.25,-0.15)
	roof.material_override = _mat(Color(0.12,0.22,0.31))
	car.add_child(roof)
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(2.1,1.4,4.2)
	col.shape = shape
	col.position.y = 0.7
	car.add_child(col)

func _build_marker() -> void:
	mission_marker = MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.6
	mesh.bottom_radius = 0.6
	mesh.height = 0.18
	mission_marker.mesh = mesh
	mission_marker.position = Vector3(30,1.5,-4)
	mission_marker.material_override = _mat(Color(0.1,0.95,0.85))
	add_child(mission_marker)
	var light := OmniLight3D.new()
	light.light_color = Color(0.05,0.9,1.0)
	light.light_energy = 2.0
	light.omni_range = 8
	mission_marker.add_child(light)

func _build_hud() -> void:
	hud = CanvasLayer.new()
	hud.name = "HUD"
	add_child(hud)
	var panel := PanelContainer.new()
	panel.name = "Panel"
	panel.position = Vector2(20,18)
	panel.custom_minimum_size = Vector2(360,110)
	hud.add_child(panel)
	var vb := VBoxContainer.new()
	panel.add_child(vb)
	var title := Label.new()
	title.text = "NEON COAST  /  VICE DISTRICT"
	title.add_theme_font_size_override("font_size",22)
	vb.add_child(title)
	var objective := Label.new()
	objective.name = "Objective"
	objective.text = "ЗАДАНИЕ: ДОБЕРИСЬ ДО НЕОНОВОЙ МАРКИ"
	objective.add_theme_font_size_override("font_size",15)
	vb.add_child(objective)
	var status := Label.new()
	status.name = "Status"
	status.text = "ПЕШКОМ  •  E — СЕСТЬ В МАШИНУ"
	vb.add_child(status)
	var joystick := Control.new()
	joystick.name = "TouchPad"
	joystick.set_script(preload("res://scripts/touch_pad.gd"))
	joystick.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.add_child(joystick)

func _toggle_vehicle() -> void:
	if player.global_position.distance_to(car.global_position) > 5.0 and not in_car:
		$HUD/Panel/Status.text = "ПОДОЙДИ БЛИЖЕ К МАШИНЕ"
		return
	in_car = not in_car
	if in_car:
		player.visible = false
		player.set_physics_process(false)
		car.set_physics_process(true)
		car.get_node("Camera3D").current = true
		car.global_position = player.global_position
	else:
		player.global_position = car.global_position + Vector3(2,0,0)
		player.visible = true
		player.set_physics_process(true)
		car.set_physics_process(false)
		player.get_node("Camera3D").current = true

# Android CI rebuild trigger after export environment setup.
