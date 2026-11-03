extends SceneTree

const Simulation = preload("res://scripts/simulation/earth_repair_simulation.gd")

func _initialize() -> void:
	var sim = Simulation.new()
	assert(sim.get_snapshot()["credits"] == 100)
	assert(sim.get_snapshot()["grid"]["delivered_mw"] == 0.0)
	assert(not sim.submit_command("start_plant")["accepted"])
	for part_id in Simulation.REPAIR_PARTS:
		assert(sim.submit_command("dispatch_robot", part_id)["accepted"])
		sim.advance_tick()
		sim.advance_tick()
		assert(sim.get_snapshot()["repairs"][part_id])
	assert(sim.submit_command("start_plant")["accepted"])
	sim.advance_tick()
	assert(sim.get_snapshot()["plant_started"])
	assert(sim.get_snapshot()["grid"]["delivered_mw"] == 25.0)
	assert(sim.get_snapshot()["credits"] > 100)
	while sim.get_snapshot()["credits"] < Simulation.UPGRADE_COST:
		sim.advance_tick()
	assert(sim.submit_command("buy_upgrade")["accepted"])
	sim.advance_tick()
	assert(sim.get_snapshot()["upgraded"])
	assert(sim.get_snapshot()["grid"]["delivered_mw"] == 35.0)
	print("PASS: Earth robot repair, plant startup, government payment, and grid upgrade")
	quit()
