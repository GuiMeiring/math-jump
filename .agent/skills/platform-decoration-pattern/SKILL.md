---
name: platform-decoration-pattern
description: Use when adding or reviewing decorations on Math Jump platform scenes, especially scene/tropic.tscn. Applies to Decoration TileMapLayer edits, preserving Terrain platforms, decorating enemy and traversal platforms, avoiding visual clutter, and keeping decorations from hiding gameplay-critical elements.
---

# Platform Decoration Pattern

Use this pattern when decorating platform scenes.

## Core Rules

- Edit the `Decoration` TileMapLayer for visual decoration.
- Do not change the `Terrain` TileMapLayer when the task is only decoration.
- Preserve existing user-placed decorations.
- Add decorations as accents, not as visual noise.
- Keep the player path, enemies, interactive characters, and platform edges readable.
- Avoid placing large decorations over enemies, spawn points, or tight jump targets.
- Prefer decoration near platform edges, leaving the middle readable for movement and combat.
- Keep visual decoration separate from character message trigger logic.
- Keep enemies on one consistent z-index above platform decorations.

## Tropic Decoration Style

For `scene/tropic.tscn`:

- Use small plant, grass, and foliage clusters on selected platforms.
- Use trees, fences, houses, bushes, and rocks to break repetition.
- Add more decoration to long enemy platforms, but keep the enemy patrol area clear.
- Add small decorations to short traversal platforms only when they do not hide jump targets.
- Decorate start, rest, enemy, and final platforms more than tiny connector platforms.
- Keep decoration sparse enough that the platform silhouette remains obvious.

## Placement Guidelines

- Place small plants one tile above or visually aligned with the platform top according to the existing scene style.
- On enemy platforms, put decoration at left and right sides, not under the enemy spawn.
- On non-enemy platforms, use one small decoration or one short cluster.
- Put houses and large trees only on wide platforms or safe scenic areas.
- Put fences on wide platforms, never across the main landing space.
- Put rocks and bushes on edges or rest spots.
- Avoid repeating the same decoration on every platform.
- Reuse existing atlas choices already present in the scene before introducing new decoration sources.

## Validation

After editing:

- Decode or inspect the `Decoration` TileMapLayer.
- Confirm existing decorations were preserved.
- Confirm no `Terrain` platform was changed.
- Confirm enemies remain visually readable.
- Confirm all enemies use the same z-index when decoration has foreground tiles.
- Confirm decorations do not hide the route, interactive characters, or player spawn.
- Playtest visually in Godot when available.
