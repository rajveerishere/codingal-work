extends RefCounted
class_name EarthRepairSimulation

## Headless-friendly Earth repair/economy slice. No scene nodes or frame time here.
## Energy rates are MW; currency is credits. Commands apply on fixed simulation ticks.

signal event_emitted(event: Dictionary)

const FIXED_STEP_SECONDS := 1.0
const PLANT_ID := "earth_damaged_fission"
const GOVERNMENT_ID := "earth_government_grid"
const STARTING_CREDITS := 100
const BASE_GENERATION_MW := 40.0
const BASE_LINE_CAPACITY_MW := 25.0
const GOVERNMENT_DEMAND_MW := 35.0
const ROBOT_TICKS_PER_REPAIR := 2
const REPAIR_PARTS := ["reactor_coolant", "turbine", "switchyard", "transmission_cable"]
const UPGRADE_COST := 250
const UPGRADE_EXTRA_MW := 15.0
const PAYMENT_PER_MW_TICK := 2

var tick := 0
var credits := STARTING_CREDITS
var plant_started := false
var upgraded := false
var robot_component := ""
var robot_ticks_left := 0
var _pending: Array[Dictionary] = []
var _last_events: Array[Dictionary] = []
var _parts := {
	"reactor_coolant": false,
	"turbine": false,
	"switchyard": false,
	"transmission_cable": false,
}

func submit_command(command: String, target_id := "") -> Dictionary:
	match command:
		"dispatch_robot":
			if not REPAIR_PARTS.has(target_id):
				return _reject("Unknown repair job.")
			if _parts[target_id]:
				return _reject("That repair is already complete.")
			if not robot_component.is_empty() or _has_queued("dispatch_robot"):
				return _reject("The repair robot is busy.")
			_pending.append({"command": command, "target_id": target_id})
		"start_plant":
			if plant_started:
				return _reject("The plant is already running.")
			if not _all_repairs_done():
				return _reject("Repair all four marked systems before startup.")
			_pending.append({"command": command})
		"buy_upgrade":
			if not plant_started:
				return _reject("Start the plant before buying an upgrade.")
			if upgraded:
				return _reject("The grid upgrade is already installed.")
			if credits < UPGRADE_COST:
				return _reject("Not enough credits. Sell power to the government first.")
			_pending.append({"command": command})
		_:
			return _reject("Unsupported command.")
	return {"accepted": true, "message": "Command queued for the next running tick."}

func advance_tick() -> Dictionary:
	tick += 1
	_last_events.clear()
	_apply_commands()
	_advance_robot()
	var snapshot := _build_snapshot()
	var delivered: float = snapshot["grid"]["delivered_mw"]
	if delivered > 0.0:
		var payment := int(round(delivered * PAYMENT_PER_MW_TICK))
		credits += payment
		_emit("government_payment", GOVERNMENT_ID, "Government paid %d credits for delivered power." % payment)
	return _build_snapshot()

func get_snapshot() -> Dictionary:
	return _build_snapshot()

func _build_snapshot() -> Dictionary:
	var repaired := 0
	var repair_states := {}
	for part_id in REPAIR_PARTS:
		repair_states[part_id] = _parts[part_id]
		if _parts[part_id]:
			repaired += 1
	var generation := BASE_GENERATION_MW + (UPGRADE_EXTRA_MW if upgraded else 0.0) if plant_started else 0.0
	var capacity := BASE_LINE_CAPACITY_MW + (UPGRADE_EXTRA_MW if upgraded else 0.0)
	var delivered := minf(generation, capacity, GOVERNMENT_DEMAND_MW)
	if not plant_started or not _parts["transmission_cable"]:
		delivered = 0.0
	return {
		"tick": tick,
		"credits": credits,
		"plant_started": plant_started,
		"upgraded": upgraded,
		"repairs": repair_states,
		"repairs_complete": repaired,
		"repair_total": REPAIR_PARTS.size(),
		"robot": {"working_on": robot_component, "ticks_left": robot_ticks_left},
		"generation_available_mw": generation,
		"grid": {"demand_mw": GOVERNMENT_DEMAND_MW, "capacity_mw": capacity, "delivered_mw": delivered, "deficit_mw": maxf(0.0, GOVERNMENT_DEMAND_MW - delivered)},
		"events": _last_events.duplicate(true),
	}

func _apply_commands() -> void:
	var commands := _pending
	_pending = []
	for item in commands:
		match item["command"]:
			"dispatch_robot":
				robot_component = item["target_id"]
				robot_ticks_left = ROBOT_TICKS_PER_REPAIR
				_emit("robot_dispatched", robot_component, "Repair robot dispatched to %s." % _part_name(robot_component))
			"start_plant":
				plant_started = true
				_emit("plant_started", PLANT_ID, "Fission plant startup successful: 40 MW available.")
			"buy_upgrade":
				credits -= UPGRADE_COST
				upgraded = true
				_emit("grid_upgraded", PLANT_ID, "Generation and transmission capacity upgraded by 15 MW.")

func _advance_robot() -> void:
	if robot_component.is_empty():
		return
	robot_ticks_left -= 1
	if robot_ticks_left <= 0:
		_parts[robot_component] = true
		_emit("repair_complete", robot_component, "%s repaired by the maintenance robot." % _part_name(robot_component))
		robot_component = ""
		robot_ticks_left = 0

func _all_repairs_done() -> bool:
	for part_id in REPAIR_PARTS:
		if not _parts[part_id]:
			return false
	return true

func _has_queued(command: String) -> bool:
	for item in _pending:
		if item["command"] == command:
			return true
	return false

func _reject(message: String) -> Dictionary:
	return {"accepted": false, "message": message}

func _part_name(part_id: String) -> String:
	return {"reactor_coolant": "reactor cooling", "turbine": "steam turbine", "switchyard": "switchyard", "transmission_cable": "transmission cable"}.get(part_id, part_id)

func _emit(event_type: String, target_id: String, message: String) -> void:
	var event := {"type": event_type, "target_id": target_id, "tick": tick, "message": message}
	_last_events.append(event)
	event_emitted.emit(event)
