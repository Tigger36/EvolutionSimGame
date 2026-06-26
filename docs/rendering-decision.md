# Rendering Technology Decision

## Decision

Use **SwiftUI Canvas** for the MVP simulation view, with an adapter layer that renders from `SimulationSnapshot`.

## Options Considered

| Option | Pros | Cons |
|--------|------|------|
| SwiftUI Canvas | Native SwiftUI integration, simple snapshot rendering, good for iPad adaptive layouts, no extra framework | Manual draw calls, less built-in sprite animation |
| SpriteKit | Built-in sprites, actions, physics | Heavier coupling risk, separate scene lifecycle from SwiftUI |
| Metal | Maximum performance | Overkill for MVP organism count, high implementation cost |

## Rationale

1. MVP entity counts are low (≤40 food, ≤5 predators, ≤20 descendants).
2. The plan requires a clean sim↔UI boundary via immutable snapshots — Canvas maps directly to snapshot-driven redraw.
3. iPad-first adaptive layouts are SwiftUI-native; Canvas embeds cleanly in the primary simulation view.
4. SpriteKit can be revisited post-MVP if entity counts or effects demand it.

## Adapter Pattern

```
SimulationController → SimulationSnapshot → SimulationCanvasView (Canvas draw)
PlayerInput ← movement controls / keyboard / pointer
```

## Verification

- iPad simulator smoke test: terrain, organisms, food, predators visible
- Stable redraw from snapshot updates at 30 FPS sim tick rate
