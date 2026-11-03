extends SceneTree

const Simulation = preload("res://scripts/simulation/velria_simulation.gd")
const Campaign = preload("res://scripts/simulation/campaign_data.gd")

func _initialize() -> void:
	_test_simulation_sequence()
	_test_campaign_gates()
	print("PASS: Velria simulation and campaign smoke checks")
	quit()

func _test_simulation_sequence() -> void:
	var sim = Simulation.new()
	assert(sim.get_snapshot()["consumers"][Simulation.SETTLEMENT_ID]["delivered_mw"] == 0.0)
	assert(sim.paused == false)
	sim.paused = true
	assert(sim.submit_command("restart_plant", Simulation.PLANT_ID)["accepted"])
	sim.advance_tick()
	assert(sim.get_snapshot()["tick"] == 0)
	assert(sim.get_snapshot()["consumers"][Simulation.SETTLEMENT_ID]["delivered_mw"] == 0.0)
	sim.paused = false
	sim.advance_tick()
	assert(sim.get_snapshot()["consumers"][Simulation.SETTLEMENT_ID]["delivered_mw"] == 40.0)
	assert(sim.get_snapshot()["links"][Simulation.PRIMARY_ID]["status"] == "energized")
	for i in range(Simulation.TICKS_UNTIL_PRIMARY_TRIP - 1):
		sim.advance_tick()
	assert(sim.get_snapshot()["links"][Simulation.PRIMARY_ID]["status"] == "failed")
	assert(sim.get_snapshot()["consumers"][Simulation.SETTLEMENT_ID]["delivered_mw"] == 0.0)
	assert(sim.submit_command("enable_link", Simulation.STANDBY_ID)["accepted"])
	sim.advance_tick()
	var consumer: Dictionary = sim.get_snapshot()["consumers"][Simulation.SETTLEMENT_ID]
	assert(consumer["delivered_mw"] == 25.0)
	assert(consumer["deficit_mw"] == 15.0)
	assert(consumer["service"] == "partial")

func _test_campaign_gates() -> void:
	assert(Campaign.ordered_system_names() == ["Velria System", "Solar System", "Re-Dok System", "Ortant System", "Vorten System"])
	assert(Campaign.unlocked_system_ids(0, []) == ["velria"])
	assert(Campaign.unlocked_system_ids(3, []) == ["velria", "solar"])
	assert(Campaign.unlocked_system_ids(0, ["velria_restored"]) == ["velria", "solar"])
