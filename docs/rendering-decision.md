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

## Addendum: Graphics Upgrade Module Layout (M1)

The graphics upgrade keeps **SwiftUI Canvas** as the renderer. Drawing was extracted
from the monolithic view into a dedicated module under
[EvolutionSimGame/Rendering/](../EvolutionSimGame/Rendering/):

- `VisualTokens.swift` — single source of truth for colors, opacities, line weights,
  and minimum on-screen sizes.
- `ViewTransform.swift` — world-to-view coordinate mapping (fit-to-world for now;
  camera follow/zoom layer on here later).
- `TerrainRenderer.swift`, `EntityRenderer.swift`, `OverlayRenderer.swift` — focused
  draw routines.
- `SimulationRenderer.swift` — orchestrates draw order from the immutable snapshot.

[SimulationCanvasView.swift](../EvolutionSimGame/Views/SimulationCanvasView.swift) is
now a thin host that wires the snapshot and visual options into `SimulationRenderer`
and layers SwiftUI legend chrome on top. Its public API is unchanged.

### When to revisit SpriteKit / Metal

Canvas remains the choice unless a milestone produces measured evidence that it
cannot meet the [performance budget](graphics-asset-spec.md). Concrete triggers:

- Sustained frame cost above the iPhone budget at worst-case population and high
  speed multipliers that cannot be recovered through path caching or overlay
  coarsening.
- Entity counts grow well beyond the MVP caps (40 food / 5 predators / 20
  descendants).
- A required visual effect (dense particles, per-pixel shading) is impractical in
  Canvas.

Any such change requires updating this decision record with the measurement that
justified it.

## Addendum: Motion and Camera (M4)

Playback is smoothed entirely in the UI layer:

- `SimulationCanvasView` drives a `TimelineView(.animation)` clock (capped at 30 fps)
  and linearly interpolates entity positions between the previous and current
  snapshot (`EntityInterpolation`). The simulation tick rate and state are unchanged.
- Organisms have a subtle idle "breathing" pulse scaled by `metabolism` and
  desynchronized per organism.
- `ViewTransform` gained a follow-camera initializer (focus + zoom + edge clamp).
  Because the MVP world (800x600) fits on a single screen, the camera defaults to
  `Camera.zoom == 1` (whole world visible) to preserve awareness of off-screen
  predators. The follow/zoom path exists for larger future worlds.
- Reduce Motion (`accessibilityReduceMotion`) disables interpolation and idle
  animation and pauses the timeline, so positions are stable.

All of this is non-authoritative: the renderer never writes back to the simulation
and introduces no randomness, preserving determinism and replay.
