# Art Direction

This document defines the visual language for EvolutionSimGame. It is the reference
for all rendering work and is paired with the design tokens in
[VisualTokens.swift](../EvolutionSimGame/Rendering/VisualTokens.swift), the asset
rules in [graphics-asset-spec.md](graphics-asset-spec.md), and the
[rendering decision](rendering-decision.md).

## Aesthetic Target: "Readable Stylized Biology"

The world reads like life under a microscope in a primordial pool that gradually
opens into distinct biomes. The priority is clarity, not realism or decoration:

- Soft organic shapes with strong silhouettes.
- A restrained palette per biome, so entities pop against terrain.
- Internal detail that communicates traits at a glance.
- Motion that reads as "alive" without distracting from cause and effect.

Adaptation must be visible. After a mutation the player should be able to see the
change on their organism without opening the inspector. This is the core product
pillar and it constrains every visual decision.

## Non-Color Encoding Rule

Color is one channel and never the only one. Every important piece of state pairs
color with at least one of: shape, outline, size, motion, iconography, or position.
This keeps the game legible for color-blind players and when terrain and entities
share a hue family. The QA pass in
[graphics-qa-checklist.md](graphics-qa-checklist.md) includes a grayscale gate to
enforce this.

## Palette Roles

Defined centrally in `VisualTokens`. Current values:

| Role | Token | Notes |
|------|-------|-------|
| World backdrop | `World.background` | Dark desaturated green-black so bright entities stand out |
| Food | `Entity.food` | Small luminous green motes |
| Predator | `Entity.predator` | Red; will gain an angular silhouette (M3) |
| Descendant | `Entity.descendant` | Cyan; same body language as player, weaker emphasis |
| Player | `Entity.player` | Yellow; strongest silhouette plus a white focus marker |
| Player marker | `Entity.playerMarker` | White ring — a non-color focus cue |

Terrain hues live under `VisualTokens.Terrain` and are listed in the terrain table
below. They are intentionally distinct in both hue and brightness so biomes remain
separable in grayscale.

## Shape Language

- **Organisms** are rounded cells. Role and traits modulate the silhouette
  (appendages, shell, sensor halo) rather than the base shape.
- **Player** carries the boldest outline and a dedicated marker ring; descendants
  share the player's body language at lower emphasis.
- **Predators** trend angular and threatening, with a facing cue derived from
  velocity (M3+).
- **Food** is small, high-contrast, and cluster-friendly.
- **Terrain** is painted regions. Later milestones add soft edges and a subtle
  per-biome pattern so regions are identifiable by texture, not just color.

## Terrain Palette and Identity

| Terrain | Hue family | Intended non-color cue (M2) |
|---------|------------|------------------------------|
| Land | Mid green | Neutral baseline, minimal texture |
| Water | Blue | Smooth gradient, ripple hint |
| Mud | Brown | Speckled / heavy texture |
| Toxic Pool | Magenta | Bubbling / hazard stipple |
| Forest | Deep green | Dense dappled pattern |
| Swamp | Muted green | Mottled, murky edges |
| Desert | Sand | Grainy, high brightness |
| Tundra | Pale blue-gray | Flat, cold, sparse |
| Mountain | Gray | Rocky, hard edges |
| Ice | Near-white | Crystalline, brightest biome |

## Trait to Visual Channel Mapping

The simulation source of truth is
[TraitSet.swift](../EvolutionSimCore/Sources/EvolutionSimCore/Traits/TraitSet.swift).
Every trait below has an intended visual channel so adaptation is observable.
Mappings marked "planned" are implemented in M3 (organisms) and M4 (motion);
they are specified here so later work has a fixed target.

| Trait | Range | Visual channel | Status |
|-------|-------|----------------|--------|
| `size` | 0–1 | Body radius (via `effectiveRadius`) | Implemented |
| `armor` | 0–1 | Heavier outline plus segmented shell plates | Implemented (M3) |
| `swimEfficiency` | 0–1 | Tail / fin appendages on the silhouette | Implemented (M3) |
| `senseRadius` | 0–1 | Faint sensory halo radius | Implemented (M3); debug ring also exists |
| `toxinResistance` | 0–1 | Tinted core membrane | Implemented (M3) |
| `speed` | 0–1 | Streamlined, elongated body along the heading | Implemented (M3); idle-motion amplitude in M4 |
| `nightVision` | 0–1 | Brighter, larger pupils | Implemented (M3) |
| `socialBehavior` | 0–1 | Dashed group halo when high | Implemented (M3) |
| `metabolism` | 0–1 | Idle "breathing" pulse rate | Implemented (M4) |
| `reproductionRate` | 0–1 | Reproduction-ready glow (shown when reproduction is safe) | Implemented (M5) |
| `parentalCare` | 0–1 | Offspring spawn cue | Partial (M5 birth burst); brightness scaling planned |

Heading is derived from `velocity`; when an organism is nearly still it defaults to
facing up. The player additionally carries a double marker ring and a forward-facing
tick (non-color focus cues). Predators use a separate angular, spiked silhouette
oriented to their heading.

Visuals must only express effects the simulation actually models. Where a visual is
an approximation of a continuous stat, note it here rather than implying precision
the mechanics do not have.

## Era Mood Notes

Eras (see
[TerrainField.swift](../EvolutionSimCore/Sources/EvolutionSimCore/World/TerrainField.swift)
`GameEra`) shift world mood through palette and backdrop, never by changing
mechanics for visual reasons:

- **Primordial Pool / Reef Shallows** — cool, wet, blue-green; tight palette.
- **Landfall** — warmer, earthier tones as land terrain dominates.
- **Biomes** — full terrain set; each biome asserts its own identity.
- **Ecosystem Dominance** — richest palette; `massExtinctionActive` applies a
  desaturated, ominous tint/vignette (M5).

## Event Feedback (M5)

Key moments in the evolution loop get brief, non-intrusive cues, detected by diffing
snapshots in the UI layer and drawn by `EffectsRenderer`:

- Reproduction: an expanding ring burst at each new offspring.
- Reproduction-ready: a soft pulsing glow around the player when it can reproduce
  safely.
- Mutation choice: a dashed, pulsing highlight around the offspring awaiting a
  mutation, plus before/after organism previews on each mutation card.
- Damage: a brief red screen flash when the player loses health.
- Lineage handoff: a focus pulse on the descendant that becomes the new player, and
  a fading puff where an organism dies.
- Mass extinction: a persistent ominous tint while `massExtinctionActive`.

Effects are cosmetic and time-based; they never affect the simulation and are
suppressed or made static under Reduce Motion.

## Layering and Hierarchy

Draw order is fixed in
[SimulationRenderer.swift](../EvolutionSimGame/Rendering/SimulationRenderer.swift):
terrain, then analysis overlays, then food, predators, descendants, and finally the
player on top. The player and predators must always remain readable above other
elements, and overlay opacity is capped so diagnostics never hide gameplay.
