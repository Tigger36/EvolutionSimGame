# Beta Pacing Targets and Balance Rationale (Phase 7)

Phase 7 (Beta Gameplay Hardening) artifact. Records the representative seed suite, the
balance/tuning changes, and the **sim-derived** pacing targets for the beta loop. All numbers
below come from deterministic headless runs in `EvolutionSimCore`, not estimates.

Source of truth: `EvolutionSimCore/Sources/EvolutionSimCore/Simulation/SimulationTuning.swift`
and the Phase 7 regression suite
`EvolutionSimCore/Tests/EvolutionSimCoreTests/Phase7BalanceTests.swift`.

## Why Phase 7 changed balance

Before Phase 7, **every seed went extinct and no victory goal was reachable**, even the gentle
tutorial preset. Headless diagnosis found two root causes:

1. **Foraging netted ~0 energy.** A player moved ~2.2 px/tick and burned ~0.23 energy/tick, so
   reaching a food particle ~150 px away cost about as much energy (≈15) as the food restored
   (15). Lineages slowly starved even with **no predators** (population capped at 3–4 and died).
2. **Difficulty escalated faster than a lineage could grow.** Composite fitness reached era 2 by
   ~tick 50 and era 5 by ~tick 500. Because success (offspring, survival, biomes) feeds the
   composite score that drives eras, a thriving lineage *accelerated* the predator escalation that
   then wiped its still-tiny (≤4) population.

The fix was an energy-economy pass (so foraging is net-positive and colonies can grow) plus a
much slower era curve (so escalation trails population growth), with victory thresholds tuned to
what the single-reproducer model can actually reach.

## Tuning changes (old → new, with player-facing intent)

| Constant | Old | New | Player-facing intent |
|----------|-----|-----|----------------------|
| `foodEnergyValue` | 15 | 22 | Each meal funds a longer foraging trip, so seeking food is a net energy *gain* instead of break-even. |
| `maxFoodParticles` | 40 | 70 | Denser food shortens the trip between meals and can sustain a growing colony, not just one organism. |
| `foodSpawnInterval` | 45 | 12 | Food replenishes fast enough to feed a colony of up to ~20, instead of starving the group. |
| `baseMetabolismDrain` | 0.15 | 0.12 | Slightly gentler baseline hunger so idle/learning moments are more forgiving. |
| `era2FitnessThreshold` | 50 | 180 | Stay in the gentle primordial era long enough to learn and start a colony. |
| `era3FitnessThreshold` | 120 | 480 | Reach amphibious pressures only after the colony is established. |
| `era4FitnessThreshold` | 250 | 950 | Unlock the full biome map as a mid/late-game milestone. |
| `era5FitnessThreshold` | 400 | 1600 | Face the toughest predators only as a genuine late-game test. |
| `populationVictoryCount` | 15 | 12 | A clearly "thriving colony" goal that skilled play can actually reach (only the player-controlled organism reproduces, so 15 simultaneous survivors was a ~1-in-30-seed fluke). |
| `intelligenceGenerationRequirement` | 10 (inline) | 5 (tuned) | Lineage generation advances only on death-and-handoff cycles; depth 5 already means many sustained survival rounds, while 10 was structurally unreachable in a normal run. |
| `intelligenceCompositeRequirement` | 500 (inline) | 1200 (tuned) | Pair the generation gate with a real fitness floor so "intelligence" still means an accomplished run. |

Logic changes kept minimal and in-scope:

- **`predatorCountOverride` is now respected across era transitions.** Previously the tutorial
  preset's "2 predators" only held at bootstrap; eras silently re-escalated the count. The
  tutorial now stays at its intended gentle predator count throughout.

`biomeSpreadVictoryCount` (6), `massExtinctionSurvivalTicks` (3000), reproduction thresholds,
predator era multipliers, and toxic terrain cost were reviewed and left unchanged.

## Representative seed suite

Fixed seeds keep balance regressions reproducible and reviewable. Defined in
`Phase7BalanceTests.SeedSuite`.

| Seed(s) | Role | Rationale |
|---------|------|-----------|
| `42` | Default new-game seed | The default `SimulationConfig`. Must be a viable common start (no early extinction). |
| `1001` | Tutorial preset seed | `SimulationConfig.tutorialSeed`. Gentle, must be a viable common start and winnable. |
| `7`, `77`, `123`, `999`, `2024` | Early/mid representatives | Span fast-food, sparse-food, and predator-heavy starts; all verified to let a naive learner clear the grace window. |
| `3, 5, 6, 9, 11` | Biome-spread winners | Verified to reach `spreadToAllBiomes` under skilled play. |
| `8, 9, 13, 15, 21` | Intelligence winners | Verified to reach `evolveIntelligence`. |
| `3, 5, 8, 9, 12` | Mass-extinction winners | Verified to reach `surviveMassExtinction` (survive to tick 3000). |
| `3, 8` | Population winners (default config) | Verified to reach `reachPopulation` even with full era-scaled predators. |

Winner lists are kept as small candidate sets so per-seed RNG variance never makes the "every goal
is winnable" guarantee flaky; the test asserts *at least one* candidate wins each goal.

## Pacing targets (sim-derived)

Milestone ticks measured on the two baseline configs: **default seed 42** and the **tutorial
preset (seed 1001)**, under scripted *smart* (flee + forage) and *naive* (forage only) players.
Simulation runs at 30 ticks/second of real time at 1× speed (the app offers up to 8× speed).

| Milestone | Seed 42 | Tutorial 1001 | Target range (representative seeds) |
|-----------|---------|---------------|--------------------------------------|
| First food eaten | tick 2 | tick 51 | ~0–70 ticks |
| First reproduction | tick 0 | tick 0 | tick 0 (founder starts above the reproduction threshold) |
| First mutation choice | tick 0 | tick 0 | tick 0 (offered with the first reproduction) |
| First era transition (→ Reef) | tick 382 | tick 245–261 | ~150–750 ticks |
| First victory **or** loss | loss ~1720 (smart) / victory 2699 (naive) | victory 1241 (naive); smart play thrives past 6000 | first outcome ~1200–3200 ticks |

Notes:

- **First reproduction/mutation at tick 0** is intentional-but-immediate: the founding organism
  spawns with full energy (100) on a safe center tile, above the reproduction threshold (60).
  *Follow-up (Phase 8 onboarding):* gate the first mutation modal behind a few ticks of play so
  the choice lands after the player has learned to move and eat. This is a UI sequencing concern,
  not a core balance lever, and is deliberately left out of Phase 7 to avoid destabilizing the
  energy economy.
- Skilled (smart) play disperses the colony while fleeing, so it can reach later eras yet peak at
  a slightly smaller simultaneous population than naive clustering — an emergent, observable
  trade-off rather than a bug.

## Failure / recovery behavior (verified)

`Phase7BalanceTests` adds deterministic coverage for the beta failure/recovery surface:

- **Starvation recovery** — a zero-energy organism that reaches food regains energy and survives.
- **Toxic start** — a lineage that begins inside a toxic pool can walk out and survive.
- **Overpopulation cap** — living descendants never exceed `maxDescendants` across a long run.
- **Mass extinction** — fires on schedule (tick 2000) and accelerates predator chase speed.
- **Descendant handoff** — control transfers to a living descendant on death (existing coverage),
  and the tutorial predator cap survives era escalation.
- **Common-start viability (R10)** — seeds 42 and 1001 never produce an unavoidable early
  extinction under naive play.
- **Reproducibility (R2)** — one victory path and one extinction path each reproduce a
  byte-for-byte-equal final state from seed + recorded input log.

## Verification

```bash
cd EvolutionSimCore && swift test
```

61 tests, 0 failures (46 pre-Phase-7 + 15 Phase 7 balance/progression/failure-recovery tests).
