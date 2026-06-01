---
name: balance-math-progression
description: Use when assigning math operations, difficulty, enemy question types, or scene-by-scene learning progression in Math Jump. Applies to work involving multiplication, division, square root, power, factorial, enemy operation_type values, or boss math balancing.
---

# Balance Math Progression

Use one main new math concept per scene. Mix older operations as review, not as noise.

## Recommended Two-Scene Progression

The current game progression uses only `Tropic` and `Ice`.

Tropic:

- Purpose: start easy and introduce the core operation ladder.
- Enemy mix for 10 enemies: 3 `mult`, 3 `div`, 2 `sqrt`, 2 `pow`.
- Use `mult` in the first encounters.
- Use `div` in the middle of the climb.
- Introduce `sqrt` and `pow` only near the end.
- Avoid `fact` in Tropic.

Ice:

- Purpose: review late Tropic operations and finish with the hardest operation.
- Enemy mix for 10 enemies: 1 `div`, 2 `sqrt`, 3 `pow`, 4 `fact`.
- Start with one `div` review enemy.
- Reinforce `sqrt` before increasing to `pow`.
- Use `fact` only in the upper/harder part of the scene.

Boss:

- Use mixed operations from both scenes.
- Start with review questions, then increase difficulty through phases.

## Current Code Operations

`scripts/math_system.gd` currently supports:

- `mult`
- `div`
- `sqrt`
- `pow`
- `fact`

Set the operation through each enemy's exported `operation_type`.

## Balancing Rules

- Do not introduce factorial before the player has already seen multiplication, division, square root, and power.
- Keep division exact, as the current generator already does.
- Keep square roots as perfect squares unless the answer system changes.
- Keep powers optional or late-game if the formal design remains multiplication, division, root, and factorial.
- Keep the two-scene curve readable: Tropic introduces difficulty gradually, Ice starts with review and ends with factorial.
