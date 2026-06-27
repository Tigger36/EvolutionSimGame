# Beta Readiness Matrix

Short view of **implemented now** vs **beta-ready** for key dimensions. Detail in [feature-inventory.md](feature-inventory.md) and [public-beta-scope.md](public-beta-scope.md).

| Dimension | Implemented now (evidence) | Beta-ready? | Gap | Phase | Verification gate |
|-----------|---------------------------|-------------|-----|-------|-------------------|
| **Persistence** | `SavedSimulation` Codable; `GameViewModel.saveSimulation()`; `testSaveRestoreRoundTrip`, `testStateSerializationRoundTrip` | **No** | No continue on relaunch, no schema migration UX, no corrupt-save recovery, no seed display/share | 9 | Save/restore test + relaunch smoke |
| **Onboarding** | `TutorialViews` (7 steps), `HowToPlayView`, `StartScreenView`, contextual tips; missing victory/era in guide | **Partial** | Victory goals and eras not in player guide; no verified first-run smoke; tutorial does not mention victory goal | 8 | First-run smoke — move, eat, reproduce, mutation, handoff |
| **Progression** | Five `GameEra` values, era predator scaling, mass extinction, four `VictoryGoal` cases, fitness composite; `Phase7BalanceTests` (seed suite, all four goal paths, replay reproducibility, failure/recovery); pacing in [pacing-targets.md](pacing-targets.md) | **Yes** (sim) | Runtime/UX pacing pass and victory-goal onboarding are Phase 8; in-sim balance hardened | 7 | Seeded balance tests + common-start viability — **met** |
| **Platform support** | macOS + iPad builds pass; iPhone compact layout in code; macOS M6 graphics QA | **Partial** | iPhone/iPad runtime smoke blank; gameplay steps on iPad/iPhone unchecked; app lifecycle not verified | 10 | Multi-platform smoke (iPhone, iPad, macOS) |
| **Performance** | `RenderQuality` coarsening; Reduce Motion in renderers; macOS M6 visual pass | **No** | No Instruments evidence at worst-case population on iPhone-class hardware; checklist performance row empty | 11 | Instruments per graphics-asset-spec "How to measure" |
| **Accessibility** | Identifiers on controls; combined labels on HUD/threat; Reduce Motion code path | **No** | VoiceOver, grayscale/color filters, contrast not manually verified | 10 | Graphics QA a11y rows — Phase 10 |
| **Release operations** | README build commands; graphics QA checklist (partial) | **No** | No known-issues doc, privacy copy, TestFlight checklist, feedback template | 12 | Archive install + beta metadata draft |
| **Documentation** | README, AGENTS.md, player guide, game design, graphics QA, project plan reconciled in Phase 6 | **Partial** | Ongoing maintenance as features ship | 6+ | Grep consistency on doc changes |

## Summary

The alpha build proves the evolution loop end-to-end in code and deterministic tests. **Beta-ready** requires closing the persistence and release-ops gaps (Phases 9 and 12), proving playability and accessibility on all three platforms (Phase 10), measuring iPhone performance (Phase 11), and hardening balance and onboarding (Phases 7 and 8). None of those are blockers to *continuing development*; they are blockers to *shipping public beta*.
