---
name: balance-math-progression
description: Use when assigning math operations, difficulty, enemy question types, or scene-by-scene learning progression in Math Jump. Applies to work involving multiplication, division, square root, power, factorial, enemy operation_type values, or boss math balancing.
---

# Balance Math Progression

Use one main new math concept per scene. Mix older operations as review, not as noise.

## Recommended Four-Scene Progression

Scene 1:

- Main operation: `mult`
- Purpose: basic multiplication fluency.
- Enemy mix: all `mult`.

Scene 2, Tropic:

- Main operation: `div`
- Review operation: `mult`
- Enemy mix for 6 enemies: 2 `mult`, 4 `div`.
- Avoid `fact`, `sqrt`, and `pow` in the main route.

Scene 3:

- Main operation: `sqrt`
- Optional bridge: `pow`, if power remains part of the game design.
- Enemy mix: mostly `sqrt`, with some `div` or `mult` review.

Scene 4:

- Main operation: `fact`
- Review operations: `mult`, `div`, `sqrt`.
- Keep factorial values small unless the UI and answer options are rebalanced.

Boss:

- Use mixed operations from all previous scenes.
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

- Do not introduce factorial before the player has already mastered multiplication and division.
- Keep division exact, as the current generator already does.
- Keep square roots as perfect squares unless the answer system changes.
- Keep powers optional or late-game if the formal design remains multiplication, division, root, and factorial.
- Add enemy count gradually: scene 1 should be lighter, scene 2 moderate, scene 3 harder, scene 4 hardest before the boss.
