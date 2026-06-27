# Graphics Asset Spec

Rules for how visuals are produced and sized. This milestone is procedural-first:
the renderer draws everything from code via SwiftUI Canvas. Bitmap assets are
deferred until procedural drawing proves insufficient.

## Procedural-First Principle

- All organisms, food, predators, and terrain are drawn with Canvas primitives
  (paths, fills, strokes, gradients).
- Styling reads from
  [VisualTokens.swift](../EvolutionSimGame/Rendering/VisualTokens.swift); no
  hard-coded colors or sizes in drawing code.
- No `.xcassets` art, PNG/SVG sprites, or `.metal` shaders are introduced unless a
  later milestone documents a measured need (see
  [rendering-decision.md](rendering-decision.md)).

## Minimum On-Screen Sizes

The world is fit-to-view, so on-screen size depends on world bounds and device
width. To stay legible on the narrowest supported layout (iPhone compact width):

| Element | Minimum on-screen size | Token |
|---------|------------------------|-------|
| Organism | 1.0 pt radius floor (raised for readability in M3) | `Entity.minOrganismRadius` |
| Food mote | Keep visible at default zoom; high-contrast fill | `Entity.foodOpacity` |
| Player marker ring | 2 pt line weight, inset 2 pt from body | `Entity.playerMarkerLineWidth` |
| Overlay grid dot | 6 pt | `Overlay.gridDotSize` |

These are starting values. M3 tightens the organism floor so adaptation stays
readable when many small organisms are on screen, and M6 validates sizes against
real device widths.

## Optional Future Sprite Dimensions

If procedural drawing is later supplemented with sprites, target square,
power-of-two, `@1x/@2x/@3x` assets:

- Organism body: 64x64 base (`@2x` 128, `@3x` 192).
- Predator: 96x96 base.
- Food mote: 16x16 base.
- Terrain tiles/patterns: 128x128 tileable.

These are placeholders for planning only; no sprites are required now.

## Performance Budget v0

Initial budgets for the MVP population, validated and refined in M6.

Worst-case population (from
[SimulationTuning](../EvolutionSimCore/Sources/EvolutionSimCore/Simulation)):

- Food: up to 40 particles
- Predators: up to 5
- Descendants: up to 20
- Simulation tick: 30 Hz, up to 8x speed multiplier

Targets:

| Scenario | Target |
|----------|--------|
| iPhone, 1x speed, no debug overlay | No visible stutter during continuous play |
| iPhone, 4x speed, worst-case population | Acceptable for playtesting |
| Debug terrain-cost grid (per-cell sampling) | <= 16 ms/frame on iPhone, or auto-coarsen the grid on compact size class |
| macOS | Same visuals; may use finer overlay grids |

Constraints that protect the budget:

- Overlays use capped opacities and bounded grid resolution.
- Drawing must avoid per-frame heap allocations where practical.

## Performance Budget v1 (M6)

Motion and effects (M4/M5) introduced a continuous animation timeline, so the scene
now redraws on a clock rather than only on simulation ticks. The following measures
keep that within budget:

- The animation timeline is capped at 30 fps (`TimelineView(.animation(minimumInterval: 1/30))`)
  and is paused entirely when the simulation is paused or Reduce Motion is on.
- Rendering quality adapts to layout via `RenderQuality`:
  - Compact width (iPhone): terrain texture spacing is doubled (about a quarter of
    the texture marks) and the debug terrain-cost grid step is coarsened from 40 to
    72 world units.
  - Regular width (iPad, macOS): full detail.
- Per-biome terrain texture is the heaviest layer; it is skipped for regions smaller
  than a few points and its mark count scales with region size and quality.
- Transient effects are pruned every tick so the effect list cannot grow unbounded.
- The follow camera defaults to `zoom == 1` (no extra overdraw beyond the visible
  world).

### How to measure (verifier)

Runtime FPS and frame cost are validated on device/simulator, not in CI:

1. Run the iOS scheme on an iPhone simulator (or device), enter play, and observe the
   SwiftUI/Core Animation frame rate under continuous movement.
2. Push to the worst case: maximum population, 4x and 8x speed, with the debug
   terrain-cost overlay enabled.
3. Profile with Instruments (Animation Hitches / Time Profiler) if any stutter is
   observed; the terrain texture loop and overlay grid are the first places to coarsen
   further or to cache into a static layer.

## Determinism Boundary

Rendering is strictly downstream of the simulation:

```
EvolutionSimCore tick  ->  SimulationSnapshot (authoritative)
                                  |
                                  v
        render layer: drawing, overlays, future interpolation/VFX (non-authoritative)
```

The renderer never writes back to `SimulationController` and never introduces its
own randomness. Any future motion smoothing or VFX lives entirely in the UI layer.
