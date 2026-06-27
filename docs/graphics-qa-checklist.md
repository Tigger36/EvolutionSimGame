# Graphics QA Checklist

Living manual visual QA document through public beta. Phase 6 reconciliation: owners
and target phases added for incomplete rows; macOS M6 results preserved.

Capture screenshots for listed scenarios and record pass/fail. See
[docs/beta/feature-inventory.md](beta/feature-inventory.md) for inventory alignment.

## Build and Test Gates

Run before any visual sign-off (see [README.md](../README.md)). Verified 2026-06-27:

- [x] `cd EvolutionSimCore && swift test` passes — **46 tests**, 0 failures (determinism unchanged).
- [x] `xcodebuild -scheme EvolutionSimGame_macOS -destination 'platform=macOS' build` — BUILD SUCCEEDED.
- [x] `xcodebuild -scheme EvolutionSimGame_iOS -destination 'platform=iOS Simulator,name=iPad (A16)' build` — BUILD SUCCEEDED.

## Layout and Readability Scenarios

| Scenario | What to verify | Pass/Fail | Owner | Phase | Gate |
|----------|----------------|-----------|-------|-------|------|
| iPad landscape, default zoom | Terrain, food, predators, player, descendants all visible and distinguishable | | `/evolution-verifier` | 10 | iPad simulator smoke — Phase 10 |
| iPhone compact width | Player and predators readable; HUD/controls do not hide the world | | `/evolution-apple-platform-ui-specialist` | 10 | iPhone simulator smoke — Phase 10 |
| macOS window, resized small and large | Scene scales correctly, no clipping of entities | Pass (macOS) | — | — | M6 complete |
| Worst-case population (40 food, 5 predators, 20 descendants) | Player still findable; no unreadable clutter | | `/evolution-verifier` | 10 | Worst-case layout smoke — Phase 10 |

## Overlay Scenarios

| Scenario | What to verify | Pass/Fail | Owner | Phase | Gate |
|----------|----------------|-----------|-------|-------|------|
| Debug overlays OFF | Clean scene, no diagnostic artifacts | Pass (macOS) | — | — | M6 complete |
| Food density overlay | Heat blobs readable, do not obscure entities | | `/evolution-verifier` | 10 | Overlay toggle smoke — Phase 10 |
| Danger zones overlay | Predator rings visible, capped opacity | | `/evolution-verifier` | 10 | Overlay toggle smoke — Phase 10 |
| Terrain cost overlay | Grid renders without obscuring player; coarsens acceptably on iPhone | | `/evolution-apple-platform-ui-specialist` | 10 | iPhone overlay smoke — Phase 10 |
| Lineage overlay | Player sense radius ring visible | | `/evolution-verifier` | 10 | Overlay toggle smoke — Phase 10 |
| Biome fit overlay | Legend and grid agree; player still on top | Pass (macOS) | — | — | M6 complete |

## Accessibility Scenarios

| Scenario | What to verify | Pass/Fail | Owner | Phase | Gate |
|----------|----------------|-----------|-------|-------|------|
| Grayscale / desaturated | Player, descendant, predator, food, and terrain biomes remain distinguishable without color | | `/evolution-apple-platform-ui-specialist` | 10 | Accessibility color-filter pass — Phase 10 |
| Color filters (deuteranopia/protanopia) | Roles and key terrain still separable | | `/evolution-apple-platform-ui-specialist` | 10 | Accessibility color-filter pass — Phase 10 |
| Reduce Motion ON | No interpolation artifacts; positions stable; transient effects suppressed | | `/evolution-apple-platform-ui-specialist` | 10 | Reduce Motion smoke — Phase 10 |
| Contrast | Entities meet contrast against their terrain backgrounds | | `/evolution-graphics-specialist` | 10 | Contrast spot-check — Phase 10 |

## Gameplay Smoke

| Step | Pass/Fail | Owner | Phase | Gate |
|------|-----------|-------|-------|------|
| Move the player organism | | `/evolution-verifier` | 10 | iPad/iPhone gameplay smoke — Phase 10 |
| Eat food (energy increases) | | `/evolution-verifier` | 10 | iPad/iPhone gameplay smoke — Phase 10 |
| Flee a predator | | `/evolution-verifier` | 10 | iPad/iPhone gameplay smoke — Phase 10 |
| Reproduce at threshold | | `/evolution-verifier` | 10 | iPad/iPhone gameplay smoke — Phase 10 |
| Choose a mutation and see it reflected on the organism (M3+) | Pass (macOS) | — | — | M6 complete |
| Die and continue as a descendant | Pass (macOS, extinction path) | — | — | M6 complete |

## VFX and Performance (long-lived lineage)

| Scenario | What to verify | Pass/Fail | Owner | Phase | Gate |
|----------|----------------|-----------|-------|-------|------|
| Full VFX sequence (repro, mutation, damage, death, handoff, extinction tint) | Cues visible without obscuring state | | `/evolution-graphics-specialist` | 10 | VFX sequence smoke — Phase 10 |
| Instruments frame-time at worst-case population + high speed | Meets budget or documented fallback | | `/evolution-verifier` | 11 | Instruments per graphics-asset-spec — Phase 11 |

## Notes

Record device/simulator, OS version, and milestone for each run. Attach screenshots
to the milestone PR description.

## Verifier Handoff (M6 + Phase 6)

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

Not yet exercised here (assigned owners above): iPad/iPhone simulator layouts and
compact-width texture coarsening, accessibility color filters and Reduce Motion, the
full reproduction/damage/handoff VFX sequence on a long-lived lineage, and Instruments
frame-time measurement at worst-case population.
