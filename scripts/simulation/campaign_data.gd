extends RefCounted
class_name CampaignData

## Editable campaign gates. Systems are listed in campaign order; each gate is
## (level threshold OR achievement) and progression remains sequential.
const SYSTEMS := [
	{"id": "velria", "name": "Velria System", "level_threshold": 0, "achievement": "", "layout": "recovery_grid"},
	{"id": "solar", "name": "Solar System", "level_threshold": 3, "achievement": "velria_restored", "layout": "original_solar"},
	{"id": "re_dok", "name": "Re-Dok System", "level_threshold": 8, "achievement": "re_dok_signal", "layout": "binary_frontier"},
	{"id": "ortant", "name": "Ortant System", "level_threshold": 14, "achievement": "ortant_relay", "layout": "dust_belt"},
	{"id": "vorten", "name": "Vorten System", "level_threshold": 20, "achievement": "vorten_dyson_ready", "layout": "giant_planets_small_star", "planet_count_max": 14},
]

static func ordered_system_names() -> Array[String]:
	var names: Array[String] = []
	for system in SYSTEMS:
		names.append(system["name"])
	return names

static func unlocked_system_ids(level: int, achievements: Array[String]) -> Array[String]:
	var unlocked: Array[String] = []
	for system in SYSTEMS:
		if not unlocked.is_empty() and not _gate_satisfied(system, level, achievements):
			break
		if unlocked.is_empty() or _gate_satisfied(system, level, achievements):
			unlocked.append(system["id"])
	return unlocked

static func _gate_satisfied(system: Dictionary, level: int, achievements: Array[String]) -> bool:
	return level >= int(system["level_threshold"]) or (not String(system["achievement"]).is_empty() and achievements.has(system["achievement"]))
