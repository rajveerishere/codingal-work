# Dystopia: Fueling Society — Earth grid recovery prototype

The project now boots into a walkable, procedural 3D Earth field in Godot 4.3 (Compatibility renderer). This iteration keeps the previous orbital Velria scene available at `scenes/velria.tscn`, and adds a first-person repair-and-economy opening loop.

## Run and controls

Open `project.godot` in Godot 4.3 and press **F6/F5**. Windows command: `godot.exe --path .`. Move with **WASD**, look with the mouse, **Shift** to sprint, **Space** to jump. Press **E** or click the field-order button to command the maintenance robot, start the repaired plant, or purchase a grid upgrade. **Esc** releases the mouse; click to recapture it.

Headless simulation check: `godot.exe --headless --path . --script res://tests/earth_repair_smoke.gd`.

## Opening gameplay

Explore the recovery zone: a rolling green landscape, service road, scattered trees, government grid office, damaged fission plant, and maintenance robot. Four broken plant/grid systems are marked in red. Get near the plant and dispatch the robot one repair at a time; each job takes two fixed simulation ticks. Once all four are repaired, start the plant. The government contract buys delivered electricity, credits accumulate, and a 250-credit upgrade increases generation and transmission capacity by 15 MW. Initial plant output is 40 MW; the line carries 25 MW to a 35 MW government demand, making the upgrade useful.

## Project structure and extension points

- `scripts/presentation/earth_repair_scene.gd`: procedural Earth terrain/trees/site/plant/robot, first-person movement and camera, HUD, interaction, and visual sync.
- `scripts/simulation/earth_repair_simulation.gd`: fixed-tick robot jobs, repair/start/upgrade commands, MW grid snapshot, and government contract credits; independent of scene nodes and frame rate.
- `tests/earth_repair_smoke.gd`: headless regression for repair jobs, startup, payment, and upgrade.
- `scenes/velria.tscn` and `scripts/presentation/velria_scene.gd`: previous orbital prototype remains available and can be restored as the main scene by changing `run/main_scene`.

Next additions: terrain chunks/biomes and collision-aware navigation; multiple repair robots with assigned maintenance routes; plant inspection/minigames and failure states; additional settlements, plants, grid topology, contracts, upgrades, save/progression. Keep dispatch, generation, storage and money rules in simulation scripts, and keep their snapshots independent of the 3D presentation.

## Verification

The project and automated smoke script are provided. This environment has no local Windows desktop or Godot executable, so I have not run Godot's parser, the headless test, or a playthrough. Please run the commands above in Godot 4.3 and report engine errors before treating the scene as verified. First-person traversal, procedural visuals and interaction need an in-engine playtest.
