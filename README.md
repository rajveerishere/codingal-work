# Dystopia: Fueling Society — Velria checkpoint

A procedural 3D Godot 4 prototype for the **blackout → restart → recovery → line failure → reroute** scenario. This repository previously contained unrelated Python learning exercises; the game is added as a new project in new files without modifying those scripts.

## Run locally

- Engine target: **Godot 4.3 stable** (GDScript; Compatibility renderer).
- Open `project.godot` in Godot 4 and press **F6/F5** (or open the project and run the main scene).
- Windows command line from this directory: `godot.exe --path .` (if Godot is on `PATH`, use `godot --path .`).
- Headless smoke checks: `godot.exe --headless --path . --script res://tests/simulation_smoke.gd`.

## Play

Click the fission plant in the orbital map and press **RESTART PLANT**. It starts dark at **0 / 40 MW**. Commands are accepted while paused but do not apply until an unpaused tick; Space or the HUD button toggles pause. The primary line automatically trips **8 simulation ticks after the first restoration tick** (scheduled simulation time, not wall-clock time). Select the standby route and enable it. It delivers **25 / 40 MW**, explicitly reporting the **15 MW deficit**.

Drag with the right mouse button to orbit, use the wheel to zoom, click map objects to select, and press **F** to refocus the camera on the selected object. Link color is paired with telemetry status: green energized, amber idle/enabled, gray disabled, red failed. The settlement's windows light when power arrives.

## Foundation and extension points

- `scripts/simulation/velria_simulation.gd`: scene-independent fixed-tick clock, pause/speed state, validated queued commands, stable IDs, deterministic fixture dispatch, snapshot, and simulation events. The fixture prioritizes primary then standby link; replace `_recalculate_delivery()` with the future dispatch module while preserving snapshots and command contracts.
- `scripts/simulation/campaign_data.gd`: ordered editable five-system campaign gates. New campaigns unlock Velria only; subsequent entries unlock sequentially by configured level **or** achievement.
- `scripts/presentation/velria_scene.gd`: procedural meshes/materials, map selection, context actions, HUD, camera, and visual sync. Add detailed scene/UI features here without moving simulation ownership into nodes.
- `tests/simulation_smoke.gd`: headless regression checks for the scenario and sample campaign gates.

Later generation and storage modules should attach as simulation-side state/rules alongside `velria_simulation.gd`, exposing generation and stored energy (MW and MWh respectively) through the snapshot. General dispatch replaces only the fixture delivery rule. Progression/save services should consume campaign data and simulation events; Vorten Dyson construction belongs in a later system-specific scene/module.

## Handoff / verification status

Files added: `project.godot`, `scenes/velria.tscn`, `scripts/simulation/velria_simulation.gd`, `scripts/simulation/campaign_data.gd`, `scripts/presentation/velria_scene.gd`, `tests/simulation_smoke.gd`, and this README.

This environment does not provide a Windows desktop or Godot executable, so no local engine launch, parser run, or interactive playthrough has been performed. The smoke-test script is provided but remains to be run locally; acceptance checks requiring the 3D renderer, picking, camera navigation, and visuals also require a Godot playthrough. Run the commands above and report any engine errors before treating this checkpoint as verified.
