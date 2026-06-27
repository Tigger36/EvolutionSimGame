# Beta Feature Inventory

Phase 6 reconciliation artifact. Maps implemented systems to docs, source, tests, and beta readiness.

**Evidence gates (2026-06-27):**

| Gate | Result |
|------|--------|
| `swift test` (EvolutionSimCore) | **Pass** — 61 tests, 0 failures (Phase 7: +15 balance/progression/failure-recovery) |
| `ContextualTipsTests` | **Pass** — 8 tests (app test target; not in core package) |
| macOS build (`EvolutionSimGame_macOS`) | **Pass** — BUILD SUCCEEDED |
| iPad build (`EvolutionSimGame_iOS`, iPad A16 sim) | **Pass** — BUILD SUCCEEDED |
| iPhone build (`EvolutionSimGame_iOS`, iPhone Air sim) | **Pass** — BUILD SUCCEEDED (verifier 2026-06-27) |
| `EvolutionSimGameTests` | **Pass** — 21 tests, 0 failures (contextual tips, mutation gating, persistence/run management) |

---

## Inventory

| Feature / System | Implemented? | Source modules | README | Player guide | Game design | Graphics docs | Automated tests | Manual QA status | Beta-ready? | Gap / owner phase |
|------------------|-------------|----------------|--------|--------------|-------------|---------------|-----------------|------------------|-------------|-------------------|
| Movement (player + descendants) | Yes | `Systems.swift`, `SimulationController.swift`, `GameControlsViews.swift` | Partial (MVP loop only) | Aligned | Aspirational (many locomotion types) | Partial (M6 macOS entities) | `testDescendantSeeksVisibleFood`, determinism suite | Partial — macOS smoke only | Partial | Phase 10 — iPhone/iPad touch smoke |
| Food consumption / energy | Yes | `Systems.swift`, `Entities.swift` | Partial | Aligned | Aspirational (many food types) | Aligned (M6 food motes) | `testPrimordialPlayerCanConsumeNearbyFood`, reproduction tests | Partial — macOS | Partial | Phase 7 — balance tuning |
| Predators (chase, damage, social defense) | Yes | `Systems.swift`, `EraContent.swift`, `PredatorThreatPresentation.swift` | Partial | Aligned | Aspirational | Partial (M6 silhouettes) | `testPredatorDamageUsesSocialMultiplier`, era scaling tests | Partial — macOS | Partial | Phase 7 tuning; Phase 10 flee smoke |
| Predator era scaling + mass extinction | Yes | `SimulationController.swift`, `EraContent.swift`, `Systems.swift` | Missing | Missing | Aligned (aspirational eras) | Partial (extinction tint M6) | `testMassExtinctionMultipliesEraScaledSpeed`, era transition tests | Partial — extinction tint on macOS | Partial | Phase 8 — player-facing explanation; Phase 10 VFX |
| Terrain effects (MVP + era biomes) | Yes | `TerrainField.swift`, `TerrainSystem` in `TerrainField.swift` | Partial (3 types in README gameplay) | Aligned (full table) | Aspirational (more terrain) | Aligned (M6 terrain) | `testMVPterrainSampling`, `testTerrainPenalties`, damaging terrain tests | Partial — overlays macOS only | Partial | Phase 10 — overlay smoke on iPad/iPhone |
| Traits + contextual mutation offers | Yes | `TraitSet.swift`, `MutationPreview.swift`, `Systems.swift` | Partial | Aligned | Aspirational (8 categories) | Aligned (mutation cards M6) | `testMutationApplication`, `testWaterPressureBiasesOffers`, compatibility tests | Partial — mutation macOS pass | Partial | Phase 8 — tradeoff clarity pass |
| Automatic reproduction + mutation pause | Yes | `SimulationController.swift`, `Systems.swift`, `GameControlsViews.swift` | Aligned | Aligned | Aligned | Partial | `testReproductionCreatesOffspring`, `testReproductionRequiresEnergy`, safety tests | Partial — reproduce step macOS pass | Partial | Phase 8 — unsafe-site messaging |
| Lineage handoff + extinction | Yes | `SimulationController.swift`, `Systems.swift` | Partial | Aligned | Aligned | Partial (handoff VFX unverified) | `testControlTransfersToDescendant`, `testExtinctionWhenNoLivingOrganisms` | Partial — extinction macOS | Partial | Phase 8 — death/handoff copy |
| Eras + era transitions | Yes | `GameEra`, `EraContent.swift`, `SimulationController.swift` | Aligned (architecture) | Missing | Aspirational (full sequence) | Partial (era tips) | `testEraProgression`, era predator tests | Missing — no era UX QA | No | Phase 8 — eras in player guide; Phase 7 pacing |
| Victory goals | Yes | `VictoryGoal`, `Systems.swift`, `NewGameSetupView.swift` | Missing from gameplay section | Missing | Aligned (aspirational list) | Missing | `testBiomeVictory`, goal logic in `Systems.swift` | Missing | No | Phase 8 — victory goal tutorial/copy |
| Fitness / composite score | Yes | `FitnessMetrics`, `Systems.swift` | Partial | Partial (implicit) | Aligned | Missing | `testCompositeScoreIncreasesWithSurvival` | Missing | Partial | Phase 8 — inspector/HUD explanation |
| Tutorial flow | Yes | `TutorialViews.swift`, `GameViewModel.swift` | Missing | Missing | Aspirational | Missing | None (UI) | Missing — no first-run smoke | Partial | Phase 8 — first-run smoke; Phase 10 a11y |
| Contextual tips | Yes | `ContextualTipsViews.swift`, `GameCopy.swift` | Missing | Missing | Aspirational | Missing | `ContextualTipsTests` (8 tests) | Missing | Partial | Phase 8 — tip coverage for victory/death |
| How-to-play / start screen | Yes | `StartScreenView.swift`, `HowToPlayView.swift` | Partial | Partial | Aspirational UI list | Missing | a11y identifiers only | Missing | Partial | Phase 8 — victory/era copy |
| SwiftUI Canvas rendering | Yes | `Rendering/*`, `SimulationCanvasView.swift` | Aligned | Missing | Aligned | Aligned (`rendering-decision.md`) | None | Partial — macOS M6 | Partial | Phase 10/11 — iPhone perf |
| Debug overlays | Yes | `OverlayRenderer.swift`, `ContentView.swift` | Missing | Missing | Aligned | Partial (checklist rows blank) | None | Partial — biome-fit macOS pass | Partial | Phase 10 — overlay smoke all platforms |
| Visual effects (repro, mutation, damage, death, handoff, extinction) | Yes | `VisualEffect.swift`, `OrganismRenderer.swift`, `SimulationRenderer.swift` | Missing | Missing | Aligned | Aligned (M6 notes) | None | Partial — not full sequence | Partial | Phase 10/11 — VFX + Reduce Motion |
| Accessibility identifiers / labels | Yes | `GameControlsViews`, `StartScreenView`, `PredatorThreatViews`, etc. | Missing | Missing | Aligned | Partial (checklist blank) | None | Missing — VoiceOver unverified | No | Phase 10 — VoiceOver pass |
| Reduce Motion behavior | Yes | `SimulationCanvasView`, renderers (`reduceMotion` param) | Missing | Missing | Missing | Partial (checklist blank) | None | Missing | No | Phase 10 — Reduce Motion smoke |
| Codable save model (`SavedSimulation`) | Yes | `SimulationController.swift` (`SavedSimulation`) | Aligned (architecture) | Missing | N/A | N/A | `testSaveRestoreRoundTrip`, `testStateSerializationRoundTrip` | N/A | Partial (model only) | Phase 9 — durable UX |
| Durable save/load / continue UX | Yes (single active slot) | `RunPersistence.swift`, `GameViewModel.swift`, `StartScreenView.swift`, `InspectorPanelView.swift` | Aligned | Aligned | N/A | N/A | `SavedSimulationTests`, `RunPersistenceServiceTests` | Partial — interactive relaunch smoke still pending | Partial | Phase 9 smoke + lifecycle polish |
| Platform layouts (iPad / iPhone / macOS) | Partial | `ContentView.swift`, platform targets | Aligned | Missing | Aligned | Partial | None | Partial — macOS resize pass; iPad/iPhone blank | Partial | Phase 10 |
| Seed display / sharing | Yes | `GameViewModel.swift`, `InspectorPanelView.swift` | Aligned | Aligned | Missing | Missing | `RunPersistenceServiceTests` restore/seed coverage + determinism tests | Partial — copy/share interaction not manually smoked | Partial | Phase 9 smoke |
| Performance evidence (worst-case population) | No | `RenderQuality.swift` coarsening exists | Missing | Missing | Missing | Partial (how to measure) | None | Missing | No | Phase 11 — Instruments |

**Doc status key:** Aligned = matches implementation; Partial = incomplete or MVP-only; Missing = not documented; Contradicts = doc claims differ from code.

---

## Test coverage summary

### EvolutionSimCore (61 tests)

| Suite / area | Tests | Notes |
|--------------|-------|-------|
| Determinism / serialization | `testDeterministicSequence`, `testSameSeedSameStateAfterNTicks`, `testSnapshotRoundTrip`, `testStateSerializationRoundTrip`, `testSaveRestoreRoundTrip` | Seeded replay and Codable round-trip |
| Terrain | 4 tests | MVP + penalties, swim adaptation |
| Traits / mutations | 6+ tests | Application, inheritance, pressure bias, compatibility |
| Reproduction | 6+ tests | Energy gate, offspring, parental care, safety, bounds |
| Descendants / lineage | 4 tests | Food seek, flee, handoff, extinction |
| Eras / predators | 10+ tests | Progression, scaling, mass extinction, primordial balance |
| Victory | `testBiomeVictory` | Goal logic unit test |
| Primordial balance | 6+ tests | Early survival, grace ramp, food consumption |
| Phase 7 balance/progression | `Phase7BalanceTests` (15 tests) | Seed suite + common-start viability, all four goal paths, victory/extinction replay reproducibility, energy economy, starvation/toxic/overpopulation/mass-extinction/tutorial-cap; see [pacing-targets.md](pacing-targets.md) |

### EvolutionSimGameTests (8 tests)

`ContextualTipsTests` — era advance tips, persistence, coordinator, `GameCopy` integration.

---

## Related artifacts

- [public-beta-scope.md](public-beta-scope.md) — beta boundary and entry criteria
- [pacing-targets.md](pacing-targets.md) — Phase 7 seed suite, tuning rationale, and pacing targets
- [beta-readiness-matrix.md](beta-readiness-matrix.md) — implemented vs beta-ready dimensions
- [risk-register.md](risk-register.md) — prioritized risks and release blockers
- [graphics-qa-checklist.md](../graphics-qa-checklist.md) — manual visual QA with owners
