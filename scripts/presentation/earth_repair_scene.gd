extends Node3D

const Simulation = preload("res://scripts/simulation/earth_repair_simulation.gd")

const FIELD_SIZE := 72.0
const TERRAIN_RESOLUTION := 54
const PLAYER_START := Vector3(1.0, 0.0, 10.0)
const PLANT_POSITION := Vector3(0.0, 0.0, -1.5)
const GOVERNMENT_POSITION := Vector3(13.0, 0.0, -7.0)
const PART_IDS := ["reactor_coolant", "turbine", "switchyard", "transmission_cable"]
const PART_LABELS := ["REACTOR COOLING", "STEAM TURBINE", "SWITCHYARD", "GRID CABLE"]

var sim: RefCounted
var player: CharacterBody3D
var camera: Camera3D
var plant_node: Node3D
var robot_node: Node3D
var repair_lamps: Array[MeshInstance3D] = []
var repair_labels: Array[Label3D] = []
var power_line: MeshInstance3D
var line_material: StandardMaterial3D
var hud: Label
var objective: Label
var action_button: Button
var notice: Label
var message := "Walk to the damaged plant and dispatch the maintenance robot."
var tick_accumulator := 0.0
var mouse_sensitivity := 0.0025
var camera_pitch := -0.12
var yaw := 0.0
var mouse_captured := true
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.seed = 241103
	sim = Simulation.new()
	_build_environment()
	_build_terrain()
	_build_road()
	_build_trees()
	_build_government_site()
	_build_power_plant()
	_build_robot()
	_build_player()
	_build_hud()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_update_game()

func _process(delta: float) -> void:
	tick_accumulator += delta
	while tick_accumulator >= Simulation.FIXED_STEP_SECONDS:
		tick_accumulator -= Simulation.FIXED_STEP_SECONDS
		sim.advance_tick()
	_update_game()

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(player):
		return
	var move := Vector2.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): move.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): move.y += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): move.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): move.x += 1.0
	move = move.normalized()
	var forward := -camera.global_basis.z
	var right := camera.global_basis.x
	var direction := (right * move.x + forward * move.y)
	direction.y = 0.0
	direction = direction.normalized()
	var speed := 7.0 if not Input.is_key_pressed(KEY_SHIFT) else 11.0
	player.velocity.x = direction.x * speed
	player.velocity.z = direction.z * speed
	if not player.is_on_floor():
		player.velocity.y -= 22.0 * _delta
	else:
		player.velocity.y = -0.2
	if Input.is_key_just_pressed(KEY_SPACE) and player.is_on_floor():
		player.velocity.y = 8.0
	player.move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and mouse_captured:
		yaw -= event.relative.x * mouse_sensitivity
		camera_pitch = clampf(camera_pitch - event.relative.y * mouse_sensitivity, -1.1, 0.65)
		player.rotation.y = yaw
		camera.rotation.x = camera_pitch
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			mouse_captured = false
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif event.keycode == KEY_E:
			_interact()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and not mouse_captured:
		mouse_captured = true
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _build_environment() -> void:
	var world := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	environment.sky = Sky.new()
	var sky := ProceduralSkyMaterial.new()
	sky.sky_top_color = Color("#3d80c0")
	sky.sky_horizon_color = Color("#c5e0e8")
	sky.ground_bottom_color = Color("#344331")
	sky.ground_horizon_color = Color("#9bb2a0")
	environment.sky.sky_material = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#a8b8b2")
	environment.ambient_light_energy = 0.7
	world.environment = environment
	add_child(world)
	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-48.0, -28.0, 0.0)
	sun.light_color = Color("#fff2d6")
	sun.light_energy = 1.2
	sun.shadow_enabled = true
	add_child(sun)

func _build_terrain() -> void:
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	for z in range(TERRAIN_RESOLUTION):
		for x in range(TERRAIN_RESOLUTION):
			var a := _terrain_point(x, z)
			var b := _terrain_point(x + 1, z)
			var c := _terrain_point(x, z + 1)
			var d := _terrain_point(x + 1, z + 1)
			st.add_vertex(a); st.add_vertex(c); st.add_vertex(b)
			st.add_vertex(b); st.add_vertex(c); st.add_vertex(d)
	st.generate_normals()
	var mesh := st.commit()
	var ground := MeshInstance3D.new()
	ground.name = "EarthTerrain"
	ground.mesh = mesh
	var grass := StandardMaterial3D.new()
	grass.albedo_color = Color("#547747")
	grass.roughness = 1.0
	grass.vertex_color_use_as_albedo = false
	ground.material_override = grass
	add_child(ground)
	var body := StaticBody3D.new()
	body.name = "TerrainCollision"
	var shape := CollisionShape3D.new()
	shape.shape = mesh.create_trimesh_shape()
	body.add_child(shape)
	add_child(body)

func _terrain_point(x: int, z: int) -> Vector3:
	var step := FIELD_SIZE / float(TERRAIN_RESOLUTION)
	var px := -FIELD_SIZE * 0.5 + float(x) * step
	var pz := -FIELD_SIZE * 0.5 + float(z) * step
	var height := 0.6 * sin(px * 0.12) * cos(pz * 0.1) + 0.28 * sin((px + pz) * 0.23)
	# Keep the repair yard and player start gentle enough to walk and read.
	var flatten := clampf(1.0 - Vector2(px, pz).length() / 15.0, 0.0, 1.0)
	height *= 1.0 - flatten * 0.85
	return Vector3(px, height, pz)

func _height_at(point: Vector3) -> float:
	return 0.6 * sin(point.x * 0.12) * cos(point.z * 0.1) + 0.28 * sin((point.x + point.z) * 0.23)

func _build_road() -> void:
	var road := _box("ServiceRoad", Vector3(4.0, 0.09, 31.0), Color("#77776a"))
	road.position = Vector3(6.5, _height_at(Vector3(6.5, 0.0, 0.0)) + 0.04, -9.0)
	add_child(road)
	var stripe := _box("RoadMarking", Vector3(0.12, 0.02, 30.0), Color("#d9c985"))
	stripe.position = road.position + Vector3(0.0, 0.06, 0.0)
	add_child(stripe)

func _build_trees() -> void:
	for i in range(105):
		var x := rng.randf_range(-FIELD_SIZE * 0.46, FIELD_SIZE * 0.46)
		var z := rng.randf_range(-FIELD_SIZE * 0.46, FIELD_SIZE * 0.46)
		var point := Vector2(x, z)
		if point.distance_to(Vector2(PLANT_POSITION.x, PLANT_POSITION.z)) < 8.0: continue
		if point.distance_to(Vector2(GOVERNMENT_POSITION.x, GOVERNMENT_POSITION.z)) < 6.0: continue
		if absf(x - 6.5) < 3.2 and z < 7.0 and z > -26.0: continue
		_add_tree(Vector3(x, _height_at(Vector3(x, 0.0, z)), z), rng.randf_range(0.72, 1.45))

func _add_tree(position: Vector3, scale_value: float) -> void:
	var tree := Node3D.new()
	tree.position = position
	tree.scale = Vector3.ONE * scale_value
	add_child(tree)
	var trunk := _cylinder("Trunk", 0.16, 1.65, Color("#604632"))
	trunk.position.y = 0.82
	tree.add_child(trunk)
	var crown := _sphere("Canopy", 0.92, Color("#2f6942"), 12, 8)
	crown.position.y = 1.85
	tree.add_child(crown)
	var crown2 := _sphere("CanopyTop", 0.62, Color("#468451"), 12, 8)
	crown2.position = Vector3(0.23, 2.35, 0.12)
	tree.add_child(crown2)

func _build_government_site() -> void:
	var site := Node3D.new()
	site.name = "GovernmentGrid"
	site.position = Vector3(GOVERNMENT_POSITION.x, _height_at(GOVERNMENT_POSITION), GOVERNMENT_POSITION.z)
	add_child(site)
	var building := _box("GovernmentOperations", Vector3(5.2, 2.8, 4.0), Color("#9aadae"))
	building.position.y = 1.4
	site.add_child(building)
	var roof := _box("Roof", Vector3(5.5, 0.35, 4.3), Color("#394f5a"))
	roof.position.y = 2.95
	site.add_child(roof)
	var sign := _label("GOVERNMENT GRID OFFICE", Vector3(0.0, 4.0, 0.0), 25, Color("#f4f3df"))
	site.add_child(sign)
	var pole := _cylinder("GridPylon", 0.16, 5.0, Color("#64717a"))
	pole.position = Vector3(-3.3, 2.5, 0.0)
	site.add_child(pole)
	var payout_label := _label("POWER CONTRACT • 35 MW DEMAND", Vector3(0.0, 3.45, 0.0), 17, Color("#ffdb7a"))
	site.add_child(payout_label)

func _build_power_plant() -> void:
	plant_node = Node3D.new()
	plant_node.name = "DamagedFissionPlant"
	plant_node.position = Vector3(PLANT_POSITION.x, _height_at(PLANT_POSITION), PLANT_POSITION.z)
	add_child(plant_node)
	var foundation := _box("ConcreteFoundation", Vector3(9.0, 0.55, 7.0), Color("#707a77"))
	foundation.position.y = 0.26
	plant_node.add_child(foundation)
	var hall := _box("TurbineHall", Vector3(4.5, 2.0, 3.6), Color("#747a70"))
	hall.position = Vector3(-1.5, 1.5, 0.2)
	plant_node.add_child(hall)
	var damaged_roof := _box("CollapsedRoof", Vector3(2.2, 0.25, 2.2), Color("#4d5552"))
	damaged_roof.position = Vector3(-1.4, 2.65, 0.0)
	damaged_roof.rotation_degrees = Vector3(0.0, 0.0, -21.0)
	plant_node.add_child(damaged_roof)
	var reactor := _cylinder("ReactorStack", 0.8, 4.2, Color("#69736d"))
	reactor.position = Vector3(2.25, 2.1, -0.8)
	plant_node.add_child(reactor)
	var broken_top := _cylinder("BrokenStackRim", 0.92, 0.28, Color("#b6533c"))
	broken_top.position = Vector3(2.25, 4.1, -0.8)
	plant_node.add_child(broken_top)
	for i in range(6):
		var rubble := _box("Rubble_%d" % i, Vector3(0.55, 0.35, 0.5), Color("#5b5c55"))
		rubble.position = Vector3(rng.randf_range(-4.2, 4.2), 0.55, rng.randf_range(-3.2, 3.2))
		rubble.rotation.y = rng.randf_range(0.0, TAU)
		plant_node.add_child(rubble)
	for i in range(PART_IDS.size()):
		var marker := _sphere("RepairMarker_%d" % i, 0.24, Color("#ff684f"), 12, 8)
		marker.position = Vector3(-3.1 + float(i) * 2.05, 0.9 + (0.25 if i % 2 == 0 else 0.0), 2.7)
		plant_node.add_child(marker)
		repair_lamps.append(marker)
		var label := _label(PART_LABELS[i] + " • BROKEN", marker.position + Vector3(0.0, 0.55, 0.0), 14, Color("#ffe6d2"))
		plant_node.add_child(label)
		repair_labels.append(label)
	plant_node.add_child(_label("DAMAGED FISSION PLANT • 40 MW", Vector3(0.0, 5.3, 0.0), 27, Color("#f3edcf")))
	line_material = _material(Color("#b24b42"), true)
	power_line = _cylinder("BrokenPowerLine", 0.08, 1.0, Color.WHITE)
	var start := plant_node.position + Vector3(3.0, 3.4, -1.0)
	var finish := Vector3(GOVERNMENT_POSITION.x - 3.5, _height_at(GOVERNMENT_POSITION) + 3.1, GOVERNMENT_POSITION.z)
	position_between(power_line, start, finish)
	power_line.material_override = line_material
	add_child(power_line)

func _build_robot() -> void:
	robot_node = Node3D.new()
	robot_node.name = "MaintenanceRobot"
	robot_node.position = plant_node.position + Vector3(5.0, 0.0, 2.0)
	add_child(robot_node)
	var body := _box("RobotBody", Vector3(0.85, 0.85, 0.65), Color("#d28c36"))
	body.position.y = 0.65
	robot_node.add_child(body)
	var head := _sphere("RobotSensor", 0.2, Color("#74e8ff"), 12, 8)
	head.position = Vector3(0.0, 1.25, -0.18)
	robot_node.add_child(head)
	for x in [-0.34, 0.34]:
		var wheel := _cylinder("Wheel", 0.2, 0.14, Color("#27343a"))
		wheel.rotation_degrees.z = 90.0
		wheel.position = Vector3(x, 0.28, 0.0)
		robot_node.add_child(wheel)
	robot_node.add_child(_label("MAINTENANCE BOT • READY", Vector3(0.0, 1.8, 0.0), 16, Color("#def6ff")))

func _build_player() -> void:
	player = CharacterBody3D.new()
	player.name = "Player"
	player.position = Vector3(PLAYER_START.x, _height_at(PLAYER_START) + 1.0, PLAYER_START.z)
	add_child(player)
	var capsule := CollisionShape3D.new()
	var shape := CapsuleShape3D.new()
	shape.radius = 0.42
	shape.height = 1.8
	capsule.shape = shape
	capsule.position.y = 0.9
	player.add_child(capsule)
	camera = Camera3D.new()
	camera.position.y = 1.62
	camera.current = true
	camera.fov = 78.0
	player.add_child(camera)

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	layer.name = "FieldHUD"
	add_child(layer)
	var top := PanelContainer.new()
	top.anchor_right = 1.0
	top.offset_left = 18.0
	top.offset_top = 18.0
	top.offset_right = -18.0
	top.offset_bottom = 156.0
	top.add_theme_stylebox_override("panel", _panel_style())
	layer.add_child(top)
	var top_box := VBoxContainer.new()
	top.add_child(top_box)
	var title := Label.new()
	title.text = "EARTH  /  GRID RECOVERY ZONE"
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color("#f0f5dd"))
	top_box.add_child(title)
	hud = Label.new()
	hud.add_theme_font_size_override("font_size", 17)
	top_box.add_child(hud)
	objective = Label.new()
	objective.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objective.add_theme_color_override("font_color", Color("#ffdc86"))
	top_box.add_child(objective)

	var action_panel := PanelContainer.new()
	action_panel.anchor_left = 1.0
	action_panel.anchor_top = 1.0
	action_panel.anchor_right = 1.0
	action_panel.anchor_bottom = 1.0
	action_panel.offset_left = -370.0
	action_panel.offset_top = -184.0
	action_panel.offset_right = -18.0
	action_panel.offset_bottom = -18.0
	action_panel.add_theme_stylebox_override("panel", _panel_style())
	layer.add_child(action_panel)
	var actions := VBoxContainer.new()
	action_panel.add_child(actions)
	var action_title := Label.new()
	action_title.text = "FIELD ORDERS"
	action_title.add_theme_color_override("font_color", Color("#83dcff"))
	actions.add_child(action_title)
	action_button = Button.new()
	action_button.custom_minimum_size.y = 45.0
	action_button.pressed.connect(_interact)
	actions.add_child(action_button)
	var controls := Label.new()
	controls.text = "WASD move • Mouse look • Shift sprint • Space jump\nE / button: order robot, start plant, or buy upgrade\nEsc: release mouse • Click: capture mouse"
	controls.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	controls.add_theme_font_size_override("font_size", 13)
	actions.add_child(controls)
	notice = Label.new()
	notice.text = message
	notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	notice_panel(layer)

func notice_panel(layer: CanvasLayer) -> void:
	var panel := PanelContainer.new()
	panel.anchor_left = 0.0
	panel.anchor_top = 1.0
	panel.anchor_right = 0.55
	panel.anchor_bottom = 1.0
	panel.offset_left = 18.0
	panel.offset_top = -78.0
	panel.offset_right = 0.0
	panel.offset_bottom = -18.0
	panel.add_theme_stylebox_override("panel", _panel_style())
	layer.add_child(panel)
	panel.add_child(notice)

func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.035, 0.075, 0.09, 0.88)
	style.border_color = Color(0.54, 0.72, 0.62, 0.9)
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 14.0
	style.content_margin_right = 14.0
	style.content_margin_top = 10.0
	style.content_margin_bottom = 10.0
	return style

func _update_game() -> void:
	if not is_instance_valid(hud): return
	var state: Dictionary = sim.get_snapshot()
	var grid: Dictionary = state["grid"]
	hud.text = "TICK %04d   •   CREDITS %d\nGENERATION %d MW   •   GOVERNMENT %d / %d MW   •   DEFICIT %d MW\nPLANT REPAIRS %d / %d   •   ROBOT: %s" % [state["tick"], state["credits"], int(state["generation_available_mw"]), int(grid["delivered_mw"]), int(grid["demand_mw"]), int(grid["deficit_mw"]), state["repairs_complete"], state["repair_total"], "WORKING: " + String(state["robot"]["working_on"]) if not String(state["robot"]["working_on"]).is_empty() else "READY"]
	if state["repairs_complete"] < state["repair_total"]:
		objective.text = "OBJECTIVE: Repair the damaged plant. Get near the plant and dispatch the robot to each red-marked broken system."
	elif not state["plant_started"]:
		objective.text = "OBJECTIVE: The plant is repaired. Start it to supply the government grid."
	elif grid["delivered_mw"] < grid["demand_mw"] and not state["upgraded"]:
		objective.text = "CONTRACT ACTIVE: Government buys your power. Earn credits, then install the 250-credit +15 MW generation and line upgrade."
	else:
		objective.text = "GRID STABLE: Government power contract fulfilled. Keep expanding generation and transmission."
	var nearby := player.global_position.distance_to(plant_node.global_position) < 9.0
	if not nearby:
		action_button.text = "GET CLOSER TO THE PLANT"
		action_button.disabled = true
	elif state["repairs_complete"] < state["repair_total"]:
		var working := not String(state["robot"]["working_on"]).is_empty()
		action_button.text = "ROBOT WORKING…" if working else "DISPATCH ROBOT: %s" % _next_part_name(state)
		action_button.disabled = working
	elif not state["plant_started"]:
		action_button.text = "START REPAIRED FISSION PLANT"
		action_button.disabled = false
	elif not state["upgraded"]:
		action_button.text = "INSTALL GRID UPGRADE • 250 CREDITS"
		action_button.disabled = state["credits"] < Simulation.UPGRADE_COST
	else:
		action_button.text = "GRID UPGRADE INSTALLED"
		action_button.disabled = true
	for i in range(PART_IDS.size()):
		var fixed: bool = state["repairs"][PART_IDS[i]]
		var active: bool = state["robot"]["working_on"] == PART_IDS[i]
		var color := Color("#46ef9b") if fixed else (Color("#ffe070") if active else Color("#fa594d"))
		var mat: StandardMaterial3D = repair_lamps[i].material_override
		mat.albedo_color = color
		mat.emission = color
		mat.emission_enabled = true
		repair_labels[i].text = PART_LABELS[i] + (" • FIXED" if fixed else (" • ROBOT WORKING" if active else " • BROKEN"))
	var powered := grid["delivered_mw"] > 0.0
	line_material.albedo_color = Color("#47ed9b") if powered else Color("#bd5548")
	line_material.emission = line_material.albedo_color
	robot_node.position = plant_node.position + (Vector3(4.4, 0.0, 1.8) if String(state["robot"]["working_on"]).is_empty() else Vector3(2.8, 0.0, 2.0))
	var beacon := robot_node.find_child("RobotSensor", true, false) as MeshInstance3D
	if beacon:
		var robot_material: StandardMaterial3D = beacon.material_override
		robot_material.emission = Color("#63ffbb") if not String(state["robot"]["working_on"]).is_empty() else Color("#74e8ff")

func _next_part_name(state: Dictionary) -> String:
	for i in range(PART_IDS.size()):
		if not state["repairs"][PART_IDS[i]]:
			return PART_LABELS[i]
	return "ALL REPAIRS COMPLETE"

func _interact() -> void:
	if player.global_position.distance_to(plant_node.global_position) > 9.0:
		message = "Walk closer to the damaged fission plant to give it orders."
		_update_game()
		return
	var state: Dictionary = sim.get_snapshot()
	var result: Dictionary
	if state["repairs_complete"] < state["repair_total"]:
		var target := ""
		for part_id in PART_IDS:
			if not state["repairs"][part_id]:
				target = part_id
				break
		result = sim.submit_command("dispatch_robot", target)
	elif not state["plant_started"]:
		result = sim.submit_command("start_plant")
	elif not state["upgraded"]:
		result = sim.submit_command("buy_upgrade")
	else:
		message = "The grid upgrade is already installed."
		_update_game()
		return
	message = String(result["message"])
	_update_game()

func _label(text: String, position: Vector3, size: int, color: Color) -> Label3D:
	var label := Label3D.new()
	label.text = text
	label.position = position
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = size
	label.pixel_size = 0.01
	label.modulate = color
	label.outline_size = 5
	label.outline_modulate = Color("#17211b")
	return label

func _box(node_name: String, size: Vector3, color: Color) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = size
	node.mesh = mesh
	node.material_override = _material(color, false)
	return node

func _cylinder(node_name: String, radius: float, height: float, color: Color) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = node_name
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 12
	node.mesh = mesh
	node.material_override = _material(color, false)
	return node

func _sphere(node_name: String, radius: float, color: Color, radial := 16, rings := 10) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = node_name
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = radial
	mesh.rings = rings
	node.mesh = mesh
	node.material_override = _material(color, true)
	return node

func _material(color: Color, emissive: bool) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.85
	if emissive:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = 0.65
	return material

func position_between(node: Node3D, a: Vector3, b: Vector3) -> void:
	var direction := b - a
	node.position = (a + b) * 0.5
	node.scale.y = direction.length()
	node.quaternion = Quaternion(Vector3.UP, direction.normalized())
