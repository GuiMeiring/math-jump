---
name: finish-tropic-scene
description: Use when planning or implementing the final layout, pacing, enemy placement, math operations, camera limits, and QA for scene/tropic.tscn as the second vertical platform scene in Math Jump. Applies to tasks that mention finishing, balancing, resizing, platform variation, enemies, or progression for the Tropic scene.
---

# Finish Tropic Scene

Use this workflow for `scene/tropic.tscn`.

## Required Context

1. Read `AGENTS.md` and `README.md`.
2. Inspect `scene/tropic.tscn` before changing it.
3. Inspect related scripts only as needed: `scripts/player.gd`, `scripts/skeleton.gd`, `scripts/math_system.gd`, and camera/transition scripts if they are part of the task.

## Scene Role

Treat Tropic as scene 2 of 4. It should feel like a vertical climb, not a side-scrolling level.

Recommended targets for the current Tropic design:

- Playable width: 480 to 640 px, with 560 px as the default target.
- Vertical climb height: 10 viewport heights, 2080 px for the 400 x 208 project viewport.
- Platform groups: about 26 to 30 total.
- Enemies: about 9 to 11 total, normally 10.
- Math operations: mostly `div`, with `mult` as review.

Do not alter the parallax unless the user explicitly asks.

## Layout Rules

- Follow the `vertical-platform-pattern` skill when editing platform layout.
- Follow the `platform-decoration-pattern` skill when editing visual decoration.
- Keep horizontal movement purposeful. Avoid long empty ground.
- Keep platforms as one tile row high.
- Keep vertical gaps at 3 tiles or more.
- Use some 3-tile gaps so sections can be cleared with a normal jump.
- Use 4 to 5 tile gaps for double-jump moments.
- Avoid drops of 220 px or more unless the route has a safe landing, because fall damage starts there.
- Reserve 8 to 10 tile wide platforms for enemy encounters.
- Vary non-enemy traversal platforms between 2, 3, 4, and 5 tiles.
- Keep the route readable as a vertical zigue-zague.
- Make the player pass through every enemy platform when enemy encounters are part of the scene.
- Extra platforms must guide the player into enemy encounters, not provide a bypass.
- Avoid repeating a simple staircase pattern for the whole climb.

## Enemy Placement

- Place enemies on wider platforms, not on narrow jump-only ledges.
- Place enemy platforms directly on the main route.
- Space enemies so the player has recovery time after a math modal or projectile.
- For 10 enemies in Tropic, prefer 2 early/mid `mult` review enemies and 8 `div` enemies.
- Avoid `fact`, `sqrt`, and `pow` for regular Tropic enemies unless the user wants this scene to be much harder.

## Validation

Before considering the scene complete:

- Play from spawn to exit without editor shortcuts.
- Verify every jump is reachable with normal movement and double jump.
- Verify camera limits match the new width and height.
- Verify side limits prevent leaving the intended play area.
- Verify each enemy can patrol without falling or getting stuck.
- Verify every enemy opens the math modal and can be defeated.
- Verify added decorations preserve readability and do not hide enemies or jump targets.
- Verify the warning sign is only used as the interaction point for the communication balloon.
- Verify all enemies use one consistent z-index above platform decorations.
- Verify parallax remains unchanged when it was out of scope.
