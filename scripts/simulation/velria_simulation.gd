extends RefCounted
class_name VelriaSimulation

## Deterministic, scene-independent Velria fixture. All power quantities are MW.
## Commands are accepted immediately but only applied at the next unpaused tick.

signal event_emitted(event: Dictionary)

const FIXED_STEP_SECONDS := 1.0
const PLANT_ID := "velria_fission_01"
const SETTLEMENT_ID := "velria_settlement_01"
const PRIMARY_ID := "velria_line_primary"
const STANDBY_ID := "velria_line_standby"
const PLANT_OUTPUT_MW := 60.0
const SETTLEMENT_DEMAND_MW := 40.0
## The primary line trips on the tick 8 ticks after the first restoration tick.
const TICKS_UNTIL_PRIMARY_TRIP := 8

var paused := false
var speed_multiplier := 1.0
var _tick_number := 0
var _plant_online := false
var _restoration_tick := -1
var _pending_commands: Array[Dictionary] = []
var _last_events: Array[Dictionary] = []
var _links := {
	PRIMARY_ID: {"enabled": true, "failed": false, "capacity_mw": 40.0, "flow_mw": 0.0},
	STANDBY_ID: {"enabled": false, "failed": false, "capacity_mw": 25.0, "flow_mw": 0.0},
}

func submit_command(command: String, target_id: String) -> Dictionary:
	if command == "restart_plant":
		if target_id != PLANT_ID:
			return {"accepted": false, "message": "That is not a restartable plant."}
		if _plant_online or _has_queued("restart_plant", target_id):
			return {"accepted": false, "message": "The fission plant is already online or restarting."}
	elif command == "enable_link":
		if not _links.has(target_id):
			return {"accepted": false, "message": "Unknown transmission link."}
		var link: Dictionary = _links[target_id]
		if link["failed"]:
			return {"accepted": false, "message": "That line has failed and cannot be enabled."}
		if link["enabled"] or _has_queued("enable_link", target_id):
			return {"accepted": false, "message": "That line is already enabled or queued."}
	else:
		return {"accepted": false, "message": "Unsupported command."}
	_pending_commands.append({"command": command, "target_id": target_id})
	return {"accepted": true, "message": "Command accepted; it will apply on the next running simulation tick."}

func advance_tick() -> Dictionary:
	if paused:
		return get_snapshot()
	_tick_number += 1
	_last_events.clear()
	_apply_pending_commands()
	_apply_scheduled_events()
	_recalculate_delivery()
	return get_snapshot()

func get_snapshot() -> Dictionary:
	var link_snapshots := {}
	for link_id in _links:
		var link: Dictionary = _links[link_id]
		var status := "failed" if link["failed"] else ("energized" if link["flow_mw"] > 0.0 else ("idle" if link["enabled"] else "disabled"))
		link_snapshots[link_id] = {
			"status": status,
			"enabled": link["enabled"],
			"capacity_mw": link["capacity_mw"],
			"flow_mw": link["flow_mw"],
		}
	var delivered: float = _links[PRIMARY_ID]["flow_mw"] + _links[STANDBY_ID]["flow_mw"]
	return {
		"tick": _tick_number,
		"paused": paused,
		"speed_multiplier": speed_multiplier,
		"generation_available_mw": PLANT_OUTPUT_MW if _plant_online else 0.0,
		"plant_online": _plant_online,
		"links": link_snapshots,
		"consumers": {
			SETTLEMENT_ID: {
				"demand_mw": SETTLEMENT_DEMAND_MW,
				"delivered_mw": delivered,
				"deficit_mw": maxf(0.0, SETTLEMENT_DEMAND_MW - delivered),
				"service": "full" if delivered >= SETTLEMENT_DEMAND_MW else ("partial" if delivered > 0.0 else "none"),
			}
		},
		"events": _last_events.duplicate(true),
		"queued_commands": _pending_commands.size(),
	}

func _has_queued(command: String, target_id: String) -> bool:
	for item in _pending_commands:
		if item["command"] == command and item["target_id"] == target_id:
			return true
	return false

func _apply_pending_commands() -> void:
	var commands := _pending_commands
	_pending_commands = []
	for item in commands:
		if item["command"] == "restart_plant" and not _plant_online:
			_plant_online = true
			if _restoration_tick < 0:
				_restoration_tick = _tick_number
				_emit_event("plant_online", PLANT_ID, "Velria fission plant restarted: 60 MW available.")
		elif item["command"] == "enable_link" and _links.has(item["target_id"]):
			var link: Dictionary = _links[item["target_id"]]
			if not link["failed"]:
				link["enabled"] = true
				_emit_event("link_enabled", item["target_id"], "Transmission route enabled.")

func _apply_scheduled_events() -> void:
	if _restoration_tick >= 0 and not _links[PRIMARY_ID]["failed"] and _tick_number - _restoration_tick >= TICKS_UNTIL_PRIMARY_TRIP:
		_links[PRIMARY_ID]["failed"] = true
		_links[PRIMARY_ID]["enabled"] = false
		_emit_event("line_tripped", PRIMARY_ID, "Primary line tripped. Enable the standby route to restore emergency service.")

func _recalculate_delivery() -> void:
	for link_id in _links:
		_links[link_id]["flow_mw"] = 0.0
	var remaining := SETTLEMENT_DEMAND_MW
	if _plant_online:
		# Fixture-only deterministic priority: primary first, then standby. Replace this
		# function with the later dispatch module while keeping this snapshot contract.
		for link_id in [PRIMARY_ID, STANDBY_ID]:
			var link: Dictionary = _links[link_id]
			if link["enabled"] and not link["failed"] and remaining > 0.0:
				var delivered: float = minf(remaining, link["capacity_mw"], PLANT_OUTPUT_MW)
				link["flow_mw"] = delivered
				remaining -= delivered
	var service := SETTLEMENT_DEMAND_MW - remaining
	if service >= SETTLEMENT_DEMAND_MW:
		_emit_event("full_service", SETTLEMENT_ID, "Settlement restored to full service: 40 / 40 MW.")
	elif service > 0.0:
		_emit_event("partial_service", SETTLEMENT_ID, "Settlement on partial service: 25 / 40 MW; 15 MW deficit.")

func _emit_event(event_type: String, target_id: String, message: String) -> void:
	var event := {"type": event_type, "target_id": target_id, "tick": _tick_number, "message": message}
	_last_events.append(event)
	event_emitted.emit(event)
