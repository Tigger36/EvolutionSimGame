# Graphics QA Checklist

Manual visual QA for each graphics milestone. Capture screenshots for the listed
scenarios and record pass/fail. This is the v0 checklist established in M1; M6
completes it with measured results.

## Build and Test Gates

Run before any visual sign-off (see [README.md](../README.md)). Verified at the end
of the M1–M6 graphics work:

- [x] `cd EvolutionSimCore && swift test` passes — 37 tests, 0 failures (determinism unchanged).
- [x] `xcodebuild -scheme EvolutionSimGame_macOS -destination 'platform=macOS' build` — BUILD SUCCEEDED.
- [x] `xcodebuild -scheme EvolutionSimGame_iOS -destination 'platform=iOS Simulator,name=iPad (A16)' build` — BUILD SUCCEEDED.

## Layout and Readability Scenarios

| Scenario | What to verify | Pass/Fail |
|----------|----------------|-----------|
| iPad landscape, default zoom | Terrain, food, predators, player, descendants all visible and distinguishable | |
| iPhone compact width | Player and predators readable; HUD/controls do not hide the world | |
| macOS window, resized small and large | Scene scales correctly, no clipping of entities | Pass (macOS) |
| Worst-case population (40 food, 5 predators, 20 descendants) | Player still findable; no unreadable clutter | |

## Overlay Scenarios

| Scenario | What to verify | Pass/Fail |
|----------|----------------|-----------|
| Debug overlays OFF | Clean scene, no diagnostic artifacts | Pass (macOS) |
| Food density overlay | Heat blobs readable, do not obscure entities | |
| Danger zones overlay | Predator rings visible, capped opacity | |
| Terrain cost overlay | Grid renders without obscuring player; coarsens acceptably on iPhone | |
| Lineage overlay | Player sense radius ring visible | |
| Biome fit overlay | Legend and grid agree; player still on top | Pass (macOS) |

## Accessibility Scenarios

| Scenario | What to verify | Pass/Fail |
|----------|----------------|-----------|
| Grayscale / desaturated | Player, descendant, predator, food, and terrain biomes remain distinguishable without color | |
| Color filters (deuteranopia/protanopia) | Roles and key terrain still separable | |
| Reduce Motion ON | No interpolation artifacts; positions stable (M4+) | |
| Contrast | Entities meet contrast against their terrain backgrounds | |

## Gameplay Smoke

| Step | Pass/Fail |
|------|-----------|
| Move the player organism | |
| Eat food (energy increases) | |
| Flee a predator | |
| Reproduce at threshold | |
| Choose a mutation and see it reflected on the organism (M3+) | Pass (macOS) |
| Die and continue as a descendant | Pass (macOS, extinction path) |

## Notes

Record device/simulator, OS version, and milestone for each run. Attach screenshots
to the milestone PR description.

## Verifier Handoff (M6)

Automated gates (builds + `swift test`) pass and are safe to rely on in CI. The
remaining scenarios in this checklist are runtime/visual and should be captured by
`/evolution-verifier` on a simulator or device, because rendered Canvas output cannot
be asserted in headless CI here.

Exact steps:

1. Launch the iPad simulator build, start a game, and capture iPad landscape at
   default zoom (expected: terrain biomes distinguishable by color and texture;
   player has a yellow body, double ring, and forward tick; predators are angular and
   red; food are luminous green motes).
2. Launch an iPhone simulator build (compact width) and capture the same (expected:
   coarser terrain texture, but all roles still readable; HUD/controls do not hide the
   world).
3. Toggle each debug overlay and confirm it renders with capped opacity and keeps the
   player/predators readable on top.
4. Enable Settings > Accessibility > Reduce Motion and confirm organisms stop pulsing,
   positions do not interpolate, and transient effects are suppressed.
5. Enable a grayscale color filter and confirm player, descendant, predator, food, and
   the biomes remain distinguishable (silhouette, texture, and markers carry the
   information, not color alone).
6. Trigger the loop events and confirm cues: reproduction ring burst and ready glow,
   mutation highlight + before/after card previews, damage flash, death puff, lineage
   handoff focus pulse, and the mass-extinction tint.
7. For performance, follow "How to measure" in
   [graphics-asset-spec.md](graphics-asset-spec.md) and note any stutter at worst-case
   population and high speed multipliers.

## Runtime Verification Results — macOS (M6)

Run on the macOS Debug build (Built-in Liquid Retina XDR, 1728×1117 pt). Captured the
running app across start screen, mutation choice, live simulation, and extinction.
Confirmed:

- **Terrain (M2):** Land base with faint grid; Water renders blue with ripple texture;
  Mud renders brown with a stipple texture; soft-edged biome circles read clearly. The
  terrain legend shows the correct glyphs (Land / Water / Mud / Toxic Pool).
- **Entities (M3):** Player is a yellow body with a white double ring and a forward
  facing/sense tick; predators are angular red star silhouettes; food are small luminous
  green motes. All roles are distinguishable simultaneously.
- **Inspector (M3):** The organism thumbnail renders next to the trait bars and reflects
  the active traits.
- **Mutation previews (M5):** The "Choose an Adaptation" cards each show before → after
  organism thumbnails with the trait/biome deltas (e.g. Night Vision, Herd Instinct,
  Stay Generalized, Moisture-Resistant Skin).
- **Overlays:** Biome-fit overlay grid and its legend agree, with the player drawn on
  top; debug-overlays-off produces a clean scene.
- **Extinction (M5):** The mass-extinction tint darkens/reddens the world behind the
  "Extinction" overlay.
- **Window scaling:** Resizing the window kept the scene correct with no entity clipping.

Not yet exercised here (left for `/evolution-verifier`): iPad/iPhone simulator layouts
and compact-width texture coarsening, accessibility color filters and Reduce Motion, the
full reproduction/damage/handoff VFX sequence on a long-lived lineage, and Instruments
frame-time measurement at worst-case population.
