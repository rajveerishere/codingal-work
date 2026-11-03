extends Node3D

const SimulationScript = preload("res://scripts/simulation/velria_simulation.gd")
const Campaign = preload("res://scripts/simulation/campaign_data.gd")

const STAR_POS := Vector3.ZERO
const PLANET_A_POS := Vector3(-7.0, 0.0, 0.0)
const PLANET_B_POS := Vector3(7.0, 0.0, 0.0)
const PLANT_POS := Vector3(-2.7, 0.0, 3.2)
const SETTLEMENT_POS := Vector3(5.1, 0.0, 3.0)
const STANDBY_WAYPOINT := Vector3(0.6, 0.0, -4.5)

var sim: RefCounted
var camera: Camera3D
var world_root: Node3D
var link_visuals: Dictionary = {}
var settlement_lights: Array[MeshInstance3D] = []
var selected_id := "velria_fission_01"
var yaw := 0.35
var pitch := 0.72
var camera_distance := 19.0
var dragging := false
var accumulator := 0.0
var current_speed := 1.0
var status_label: Label
var objective_label: Label
var tick_label: Label
var selection_title: Label
var selection_detail: Label
var action_button: Button
var pause_button: Button
var speed_button: Button
var last_notice := "Select the fission plant, then restart it."
var link_materials: Dictionary = {}

func _ready() -> void:
	sim = SimulationScript.new()
	_build_world()
	_build_hud()
	_update_camera()
	_update_presentation()
	_update_hud()

func _process(delta: float) -> void:
	if not sim.paused:
		accumulator += delta * current_speed
		while accumulator >= SimulationScript.FIXED_STEP_SECONDS:
			accumulator -= SimulationScript.FIXED_STEP_SECONDS
			sim.advance_tick()
		_update_presentation()
		_update_hud()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			if event.pressed:
				_select_at(event.position)
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera_distance = maxf(8.0, camera_distance - 1.2)
			_update_camera()
		elif event.pressed and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera_distance = minf(36.0, camera_distance + 1.2)
			_update_camera()
	elif event is InputEventMouseMotion and dragging and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		yaw -= event.relative.x * 0.008
		pitch = clampf(pitch + event.relative.y * 0.008, 0.18, 1.35)
		_update_camera()
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F:
			_refocus_selection()
		elif event.keycode == KEY_SPACE:
			_toggle_pause()

func _build_world() -> void:
	world_root = Node3D.new()
	world_root.name = "OrbitalMap"
	add_child(world_root)
	var environment := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.015, 0.025, 0.08)
	sky_material.sky_horizon_color = Color(0.035, 0.055, 0.11)
	env.sky.sky_material = sky_material
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.24, 0.28, 0.43)
	env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.environment = env
	world_root.add_child(environment)
	camera = Camera3D.new()
	camera.name = "OrbitCamera"
	camera.current = true
	camera.fov = 52.0
	world_root.add_child(camera)
	var key_light := DirectionalLight3D.new()
	key_light.rotation_degrees = Vector3(-35.0, -28.0, 0.0)
	key_light.light_energy = 1.2
	world_root.add_child(key_light)
	_add_star()
	_add_planet("velria_ash", "ASHEN", PLANET_A_POS, 1.35, Color("#9b6475"), false)
	_add_planet("velria_ocean", "PELAGIA", PLANET_B_POS, 1.7, Color("#426fa1"), true)
	_add_plant()
	_add_settlement()
	_add_orbit_ring(PLANET_A_POS, 2.2, Color(0.44, 0.48, 0.65, 0.35))
	_add_orbit_ring(PLANET_B_POS, 2.65, Color(0.44, 0.48, 0.65, 0.35))
	_add_link(SimulationScript.PRIMARY_ID, "PRIMARY • 40 MW", PLANT_POS, SETTLEMENT_POS, null)
	_add_link(SimulationScript.STANDBY_ID, "STANDBY • 25 MW", PLANT_POS, STANDBY_WAYPOINT, SETTLEMENT_POS)
	_add_stars()

func _add_star() -> void:
	var body := _selectable_body("velria_star", STAR_POS, 1.1)
	body.name = "VelriaStar"
	var core := _sphere("StarCore", 1.08, Color("#ffd27a"), 24, 16)
	body.add_child(core)
	var glow := _sphere("StarCorona", 1.28, Color(1.0, 0.48, 0.16, 0.22), 24, 16)
	body.add_child(glow)
	var light := OmniLight3D.new()
	light.light_color = Color(1.0, 0.64, 0.34)
	light.light_energy = 3.2
	light.omni_range = 28.0
	body.add_child(light)
	_add_billboard_label(body, "VELRIA • G-TYPE STAR", Vector3(0.0, 1.65, 0.0))

func _add_planet(object_id: String, label: String, pos: Vector3, radius: float, color: Color, rings: bool) -> void:
	var body := _selectable_body(object_id, pos, radius)
	body.name = label
	var planet := _sphere("Planet", radius, color, 28, 18)
	body.add_child(planet)
	if rings:
		var ring := MeshInstance3D.new()
		var torus := TorusMesh.new()
		torus.inner_radius = radius * 1.28
		torus.outer_radius = radius * 1.52
		ring.mesh = torus
		ring.rotation_degrees.x = 68.0
		ring.material_override = _material(Color(0.42, 0.72, 0.9, 0.52), false)
		body.add_child(ring)
	_add_billboard_label(body, label, Vector3(0.0, radius + 0.55, 0.0))

func _add_plant() -> void:
	var body := _selectable_body(SimulationScript.PLANT_ID, PLANT_POS, 0.95)
	body.name = "FissionPlant"
	var base := _box("PlantBase", Vector3(1.55, 0.58, 1.35), Color("#46546c"))
	base.position.y = 0.1
	body.add_child(base)
	var reactor := _cylinder("ReactorStack", 0.34, 1.25, Color("#71829a"))
	reactor.position = Vector3(0.0, 0.86, 0.0)
	body.add_child(reactor)
	var cap := _sphere("WarningBeacon", 0.19, Color("#ff6c5e"), 12, 8)
	cap.position = Vector3(0.0, 1.58, 0.0)
	body.add_child(cap)
	_add_billboard_label(body, "FISSION • OFFLINE", Vector3(0.0, 2.0, 0.0))

func _add_settlement() -> void:
	var body := _selectable_body(SimulationScript.SETTLEMENT_ID, SETTLEMENT_POS, 1.25)
	body.name = "Settlement"
	for i in range(7):
		var h := 0.45 + float((i * 3) % 5) * 0.16
		var building := _box("Habitat_%d" % i, Vector3(0.46, h, 0.48), Color("#233044"))
		building.position = Vector3(float(i % 3) * 0.65 - 0.65, h * 0.5, float(i / 3) * 0.7 - 0.35)
		body.add_child(building)
		var window := _box("Window_%d" % i, Vector3(0.3, 0.11, 0.025), Color("#26303b"))
		window.position = building.position + Vector3(0.0, 0.0, -0.25)
		body.add_child(window)
		settlement_lights.append(window)
	_add_billboard_label(body, "SETTLEMENT • BLACKOUT", Vector3(0.0, 2.05, 0.0))

func _add_link(link_id: String, label: String, start: Vector3, mid: Vector3, finish_variant: Variant) -> void:
	var points: Array[Vector3] = [start, mid]
	if finish_variant is Vector3:
		points.append(finish_variant)
	var midpoint := points[points.size() / 2]
	var body := _selectable_body(link_id, midpoint, 0.72)
	body.name = "Transmission_%s" % link_id
	body.set_meta("label", label)
	var segments: Array[MeshInstance3D] = []
	for i in range(points.size() - 1):
		var segment := _cylinder("CableSegment_%d" % i, 0.075 if link_id == SimulationScript.PRIMARY_ID else 0.055, 1.0, Color.WHITE)
		var a := points[i] + Vector3(0, 0.2, 0)
		var b := points[i + 1] + Vector3(0, 0.2, 0)
		var direction := b - a
		segment.position = (a + b) * 0.5
		segment.scale.y = direction.length()
		segment.quaternion = Quaternion(Vector3.UP, direction.normalized())
		world_root.add_child(segment)
		segments.append(segment)
	link_visuals[link_id] = segments
	link_materials[link_id] = _material(Color("#535d70"), true)
	_add_billboard_label(body, label, Vector3(0.0, 0.65, 0.0))

func _add_orbit_ring(center: Vector3, radius: float, color: Color) -> void:
	var node := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = radius - 0.015
	torus.outer_radius = radius + 0.015
	node.mesh = torus
	node.position = center
	node.rotation_degrees.x = 90.0
	node.material_override = _material(color, true)
	world_root.add_child(node)

func _add_stars() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 70123
	for i in range(130):
		var star := MeshInstance3D.new()
		var sphere := SphereMesh.new()
		sphere.radius = 0.025 + rng.randf() * 0.035
		sphere.height = sphere.radius * 2.0
		star.mesh = sphere
		star.position = Vector3(rng.randf_range(-32.0, 32.0), rng.randf_range(-15.0, 20.0), rng.randf_range(-28.0, 28.0))
		star.material_override = _material(Color(0.62, 0.75, 1.0), true)
		world_root.add_child(star)

func _selectable_body(object_id: String, pos: Vector3, radius: float) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = pos
	body.set_meta("object_id", object_id)
	var collision := CollisionShape3D.new()
	var shape := SphereShape3D.new()
	shape.radius = radius
	collision.shape = shape
	body.add_child(collision)
	world_root.add_child(body)
	return body

func _sphere(node_name: String, radius: float, color: Color, radial := 20, rings := 12) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	node.name = node_name
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = radial
	mesh.rings = rings
	node.mesh = mesh
	node.material_override = _material(color, color.r > 0.8)
	return node

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
	mesh.radial_segments = 10
	node.mesh = mesh
	node.material_override = _material(color, false)
	return node

func _material(color: Color, emissive: bool) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.68
	if emissive:
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = 0.8
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA if color.a < 1.0 else BaseMaterial3D.TRANSPARENCY_DISABLED
	return mat

func _add_billboard_label(parent: Node3D, text: String, pos: Vector3) -> void:
	var label := Label3D.new()
	label.text = text
	label.position = pos
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = 30
	label.pixel_size = 0.007
	label.modulate = Color("#d9e8ff")
	label.outline_size = 6
	label.outline_modulate = Color("#10182b")
	parent.add_child(label)

func _build_hud() -> void:
	var layer := CanvasLayer.new()
	layer.name = "ControlHUD"
	add_child(layer)
	var header := PanelContainer.new()
	header.anchor_right = 1.0
	header.offset_bottom = 94.0
	header.add_theme_stylebox_override("panel", _panel_style(Color(0.035, 0.055, 0.09, 0.94)))
	layer.add_child(header)
	var head_row := HBoxContainer.new()
	head_row.add_theme_constant_override("separation", 20)
	header.add_child(head_row)
	var title := Label.new()
	title.text = "DYSTOPIA  /  VELRIA GRID CONTROL"
	title.add_theme_font_size_override("font_size", 23)
	title.add_theme_color_override("font_color", Color("#e9f2ff"))
	head_row.add_child(title)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head_row.add_child(spacer)
	tick_label = Label.new()
	head_row.add_child(tick_label)
	pause_button = _button("PAUSE", _toggle_pause)
	head_row.add_child(pause_button)
	speed_button = _button("SPEED 1×", _cycle_speed)
	head_row.add_child(speed_button)

	var panel := PanelContainer.new()
	panel.anchor_left = 1.0
	panel.anchor_right = 1.0
	panel.offset_left = -350.0
	panel.offset_top = 118.0
	panel.offset_right = -22.0
	panel.offset_bottom = 520.0
	panel.add_theme_stylebox_override("panel", _panel_style(Color(0.035, 0.055, 0.09, 0.93)))
	layer.add_child(panel)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 12)
	panel.add_child(stack)
	var cap := Label.new()
	cap.text = "GRID TELEMETRY"
	cap.add_theme_font_size_override("font_size", 17)
	cap.add_theme_color_override("font_color", Color("#75d9ff"))
	stack.add_child(cap)
	status_label = Label.new()
	status_label.add_theme_font_size_override("font_size", 20)
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stack.add_child(status_label)
	objective_label = Label.new()
	objective_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objective_label.custom_minimum_size.y = 86
	objective_label.add_theme_color_override("font_color", Color("#ffd27a"))
	stack.add_child(objective_label)
	var divider := HSeparator.new()
	stack.add_child(divider)
	selection_title = Label.new()
	selection_title.add_theme_font_size_override("font_size", 17)
	selection_title.add_theme_color_override("font_color", Color("#e9f2ff"))
	stack.add_child(selection_title)
	selection_detail = Label.new()
	selection_detail.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	selection_detail.custom_minimum_size.y = 52
	stack.add_child(selection_detail)
	action_button = _button("RESTART PLANT", _run_selected_action)
	stack.add_child(action_button)
	var hint := Label.new()
	hint.text = "Drag right mouse: orbit   •   Wheel: zoom\nClick object: select   •   F: refocus   •   Space: pause"
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_font_size_override("font_size", 12)
	hint.add_theme_color_override("font_color", Color("#aebbd0"))
	stack.add_child(hint)

	var notice_panel := PanelContainer.new()
	notice_panel.anchor_left = 0.0
	notice_panel.anchor_top = 1.0
	notice_panel.anchor_right = 0.58
	notice_panel.anchor_bottom = 1.0
	notice_panel.offset_left = 22.0
	notice_panel.offset_top = -76.0
	notice_panel.offset_right = 0.0
	notice_panel.offset_bottom = -18.0
	notice_panel.add_theme_stylebox_override("panel", _panel_style(Color(0.035, 0.055, 0.09, 0.9)))
	layer.add_child(notice_panel)
	var notice_row := HBoxContainer.new()
	notice_row.add_theme_constant_override("separation", 10)
	notice_panel.add_child(notice_row)
	var objective_tag := Label.new()
	objective_tag.text = "OBJECTIVE"
	objective_tag.add_theme_color_override("font_color", Color("#75d9ff"))
	notice_row.add_child(objective_tag)
	var objective_notice := Label.new()
	objective_notice.text = "Restore power to the Velria settlement."
	objective_notice.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	notice_row.add_child(objective_notice)

func _panel_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color(0.26, 0.42, 0.62, 0.9)
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 15.0
	style.content_margin_right = 15.0
	style.content_margin_top = 12.0
	style.content_margin_bottom = 12.0
	return style

func _button(text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(140, 38)
	button.pressed.connect(callback)
	return button

func _select_at(screen_position: Vector2) -> void:
	var origin := camera.project_ray_origin(screen_position)
	var end := origin + camera.project_ray_normal(screen_position) * 100.0
	var query := PhysicsRayQueryParameters3D.create(origin, end)
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return
	var collider: Object = hit["collider"]
	if collider is Node and collider.has_meta("object_id"):
		selected_id = String(collider.get_meta("object_id"))
		last_notice = "Selected %s." % _display_name(selected_id)
		_update_hud()

func _run_selected_action() -> void:
	var command := ""
	if selected_id == SimulationScript.PLANT_ID:
		command = "restart_plant"
	elif selected_id == SimulationScript.PRIMARY_ID or selected_id == SimulationScript.STANDBY_ID:
		command = "enable_link"
	else:
		last_notice = "Select the plant or a transmission link to issue a grid command."
		_update_hud()
		return
	var result: Dictionary = sim.submit_command(command, selected_id)
	last_notice = String(result["message"])
	_update_hud()

func _toggle_pause() -> void:
	sim.paused = not sim.paused
	if not sim.paused:
		accumulator = 0.0
	_update_hud()

func _cycle_speed() -> void:
	var speeds := [1.0, 2.0, 4.0]
	var index := speeds.find(current_speed)
	current_speed = speeds[(index + 1) % speeds.size()]
	sim.speed_multiplier = current_speed
	_update_hud()

func _refocus_selection() -> void:
	var targets := {
		SimulationScript.PLANT_ID: PLANT_POS,
		SimulationScript.SETTLEMENT_ID: SETTLEMENT_POS,
		SimulationScript.PRIMARY_ID: (PLANT_POS + SETTLEMENT_POS) * 0.5,
		SimulationScript.STANDBY_ID: STANDBY_WAYPOINT,
		"velria_star": STAR_POS,
		"velria_ash": PLANET_A_POS,
		"velria_ocean": PLANET_B_POS,
	}
	camera.look_at(targets.get(selected_id, STAR_POS), Vector3.UP)
	yaw = atan2(camera.position.x, camera.position.z)
	_update_camera()

func _update_camera() -> void:
	if not is_instance_valid(camera):
		return
	var focus := Vector3.ZERO
	var offset := Vector3(sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch)) * camera_distance
	camera.position = focus + offset
	camera.look_at(focus, Vector3.UP)

func _update_presentation() -> void:
	var snapshot: Dictionary = sim.get_snapshot()
	for link_id in link_visuals:
		var state: Dictionary = snapshot["links"][link_id]
		var color := Color("#39e58c") if state["status"] == "energized" else (Color("#ff4f62") if state["status"] == "failed" else (Color("#f0aa4f") if state["enabled"] else Color("#566178")))
		var mat: StandardMaterial3D = link_materials[link_id]
		mat.albedo_color = color
		mat.emission = color
		mat.emission_enabled = true
		mat.emission_energy_multiplier = 1.35 if state["status"] == "energized" else 0.45
		for segment in link_visuals[link_id]:
			segment.material_override = mat
	for i in range(settlement_lights.size()):
		var window := settlement_lights[i]
		var lit := snapshot["consumers"][SimulationScript.SETTLEMENT_ID]["delivered_mw"] > 0.0
		var lit_color := Color("#ffe18a") if lit else Color("#26303b")
		var window_material: StandardMaterial3D = window.material_override
		window_material.albedo_color = lit_color
		window_material.emission_enabled = lit
		window_material.emission = lit_color
		window_material.emission_energy_multiplier = 1.6
	var plant := world_root.find_child("FissionPlant", true, false)
	if plant:
		var beacon := plant.find_child("WarningBeacon", true, false) as MeshInstance3D
		var label := plant.find_child("Label3D", true, false) as Label3D
		if beacon:
			beacon.material_override = _material(Color("#43f0a2") if snapshot["plant_online"] else Color("#ff6c5e"), true)
		if label:
			label.text = "FISSION • ONLINE" if snapshot["plant_online"] else "FISSION • OFFLINE"

func _update_hud() -> void:
	if not is_instance_valid(status_label):
		return
	var snapshot: Dictionary = sim.get_snapshot()
	var consumer: Dictionary = snapshot["consumers"][SimulationScript.SETTLEMENT_ID]
	var delivered := int(consumer["delivered_mw"])
	var demand := int(consumer["demand_mw"])
	var service_text := "FULL SERVICE" if consumer["service"] == "full" else ("PARTIAL SERVICE" if consumer["service"] == "partial" else "BLACKOUT")
	status_label.text = "%s\nSETTLEMENT  %d / %d MW   •   DEFICIT %d MW\nGENERATION  %d MW AVAILABLE" % [service_text, delivered, demand, int(consumer["deficit_mw"]), int(snapshot["generation_available_mw"])]
	if consumer["service"] == "partial":
		objective_label.text = "EMERGENCY OBJECTIVE\nRestore 25 MW on the standby route. The remaining 15 MW deficit shows why the grid needs more capacity."
	elif snapshot["links"][SimulationScript.PRIMARY_ID]["status"] == "failed":
		objective_label.text = "PRIMARY LINE FAILED\nSelect the standby link and enable it to restore emergency service."
	elif consumer["service"] == "full":
		objective_label.text = "OBJECTIVE COMPLETE\nFull service is restored. The scheduled primary-line trip is still ahead—prepare the standby route."
	else:
		objective_label.text = "RESTORE FULL SERVICE\nSelect the fission plant on the map and restart it. Power is delivered on the next running tick."
	tick_label.text = "TICK %04d   •   %s   •   %.0f×" % [snapshot["tick"], "PAUSED" if sim.paused else "RUNNING", current_speed]
	pause_button.text = "RESUME" if sim.paused else "PAUSE"
	speed_button.text = "SPEED %.0f×" % current_speed
	selection_title.text = _display_name(selected_id)
	selection_detail.text = _selection_description(snapshot)
	if selected_id == SimulationScript.PLANT_ID:
		action_button.text = "RESTART PLANT" if not snapshot["plant_online"] else "PLANT ONLINE"
		action_button.disabled = snapshot["plant_online"]
	elif selected_id == SimulationScript.PRIMARY_ID or selected_id == SimulationScript.STANDBY_ID:
		var link: Dictionary = snapshot["links"][selected_id]
		action_button.text = "ENABLE ROUTE" if not link["enabled"] and not link["status"] == "failed" else ("LINE FAILED" if link["status"] == "failed" else "ROUTE ENABLED")
		action_button.disabled = link["enabled"] or link["status"] == "failed"
	else:
		action_button.text = "SELECT GRID OBJECT"
		action_button.disabled = true

func _selection_description(snapshot: Dictionary) -> String:
	if selected_id == SimulationScript.PLANT_ID:
		return "Fission plant • 60 MW\nStatus: %s" % ("ONLINE" if snapshot["plant_online"] else "OFFLINE")
	if selected_id == SimulationScript.SETTLEMENT_ID:
		var consumer: Dictionary = snapshot["consumers"][SimulationScript.SETTLEMENT_ID]
		return "Settlement demand: 40 MW\nDelivered: %d MW" % int(consumer["delivered_mw"])
	if snapshot["links"].has(selected_id):
		var link: Dictionary = snapshot["links"][selected_id]
		return "Capacity: %d MW • Flow: %d MW\nStatus: %s" % [int(link["capacity_mw"]), int(link["flow_mw"]), String(link["status"]).to_upper()]
	return "Orbital object • Select the plant or a link to issue grid commands."

func _display_name(object_id: String) -> String:
	var names := {
		SimulationScript.PLANT_ID: "Velria Fission Plant",
		SimulationScript.SETTLEMENT_ID: "Velria Settlement",
		SimulationScript.PRIMARY_ID: "Primary Transmission Link",
		SimulationScript.STANDBY_ID: "Standby Transmission Link",
		"velria_star": "Velria Star",
		"velria_ash": "Ashen Planet",
		"velria_ocean": "Pelagia Planet",
	}
	return String(names.get(object_id, object_id))
