---
name: vertical-platform-pattern
description: Use when designing, reviewing, or editing vertical platform layouts in Math Jump, especially scene/tropic.tscn. Applies to platform count, platform height, platform spacing, jump distance, enemy-route placement, non-enemy platform length variation, and TileMap terrain layout decisions.
---

# Vertical Platform Pattern

Use this pattern for vertical climb scenes in Math Jump.

## Core Rules

- Keep platforms as one tile row high.
- Avoid excessive platform count. For a 10-screen scene, use about 26 to 30 platform groups.
- Keep the player route readable as a main vertical path, normally a loose zigue-zague.
- Make the route pass through every enemy platform when enemies are required encounters.
- Do not place skip platforms that let the player bypass enemy encounters.
- If adding extra platforms, place them so they guide the player into enemy platforms instead of allowing skips.
- Keep vertical spacing at 3 tiles or more between platform rows.
- Use some 3-tile vertical gaps so parts of the route work with a normal jump.
- Use 4 to 5 tile vertical gaps for double-jump moments.
- Avoid placing platform rows visually too close together.

## Platform Lengths

Use different platform lengths so the climb does not look repetitive.

- Enemy platforms: 8 to 10 tiles wide.
- Start platform: 12 to 16 tiles wide.
- Final platform: 10 to 14 tiles wide.
- Traversal platforms without enemies: vary between 2, 3, 4, and 5 tiles.
- Occasional rest platforms without enemies: 5 to 6 tiles.

Do not make every traversal platform long. Save wide platforms for combat, start, rest, and exit.

## Enemy Route Placement

- Put enemies only on platforms wide enough for patrol.
- Place enemy platforms directly on the main route.
- Put traversal platforms before and after each enemy platform to lead the player into the encounter.
- Verify each enemy stands on a platform tile after moving platforms.
- Use more enemies when increasing scene height. For a 10-screen Tropic scene, use about 9 to 11 enemies.

## Tropic Current Standard

For `scene/tropic.tscn` in the current design:

- Camera height: 10 screens, 2080 px for a 400 x 208 viewport.
- Platform groups: about 28.
- Enemy count: about 10.
- Math operations: mostly `div`, with some `mult` review.
- Minimum vertical gap: 3 tiles.
- Platform height: exactly one tile row.
- Non-enemy platform lengths: mix 2, 3, 4, and 5 tiles.

## Validation

After editing:

- Decode or inspect the TileMap and count platform groups.
- Confirm no platform is more than one tile row high.
- Confirm the minimum vertical gap is at least 3 tiles.
- Confirm non-enemy platforms include short lengths, not only long ledges.
- Confirm every enemy is on a platform.
- Confirm the route still requires passing through enemy platforms when that is the level goal.
- Playtest the route with normal jump and double jump.
