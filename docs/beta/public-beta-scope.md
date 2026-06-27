# Public Beta Scope

Phase 6 definition of what public beta means for EvolutionSimGame, what it includes and excludes, and how requirements trace to Phases 7–12.

## Purpose

**Public beta** means an external Apple-platform player can install a **TestFlight** build, start a run, understand the goal without reading the repo, play through success or extinction, close and resume safely, and submit actionable feedback.

Public beta is **not**:

- A content-complete game (all eras, body plans, trait categories, or biomes from the design guide)
- A cloud-backed product (accounts, analytics, multiplayer, or custom telemetry)
- A signal to rewrite the rendering stack without measured Canvas limits

Current product stage: **post-MVP alpha** — core loop, eras, victory goals, tutorial scaffolding, and Codable save model exist; beta readiness requires hardening, persistence UX, platform QA, performance evidence, and release operations (Phases 7–12).

## Beta includes (minimum playable experience)

Based on implemented systems ([feature-inventory.md](feature-inventory.md)):

- Continuous 2D world with terrain biomes (land, water, mud, toxic, forest, swamp, desert, tundra, mountain, ice)
- Player-controlled organism with movement, energy, health, traits
- Food particles, predators with era-scaled difficulty and mass extinction events
- Automatic reproduction with safe-site gating and guided mutation choice
- Descendant AI (forage, flee), lineage handoff, extinction
- Era progression (Primordial Pool → Ecosystem Dominance) driven by fitness
- Selectable victory goals (spread biomes, population, intelligence, survive mass extinction)
- Tutorial steps, contextual tips, how-to-play, start/new-game setup
- SwiftUI Canvas rendering with overlays, organism silhouettes, terrain texture, VFX
- Accessibility identifiers on core controls; Reduce Motion hooks in renderers
- Codable `SavedSimulation` model (serialization tested; durable UX is Phase 9)

## Beta explicitly excludes

Unless separately approved and planned:

| Area | Exclusion |
|------|-----------|
| Backend | Cloud services, accounts, authentication, payments, public networking |
| Analytics | Custom telemetry, crash SDKs beyond Apple defaults, remote config |
| Multiplayer | Shared worlds, real-time or async co-play |
| Platforms | Non-Apple (Android, web-first, desktop outside macOS) |
| Content completeness | Every body plan, trait category, locomotion type, and biome from [game-design.md](../game-design.md) |
| Engine rewrite | SpriteKit/Metal migration without decision record and measured Canvas failure |
| Phase 7–12 bundling | This document does not authorize implementing balance, save UX, QA passes, or TestFlight in Phase 6 |

Feedback channel: **TestFlight / App Store Connect** only. Apple-provided crash reports and beta feedback through ASC are in scope; **custom telemetry, accounts, or third-party analytics SDKs** are not. Simulation data stays **local** on device.

## Entry criteria checklist

Each criterion maps to owner phase, primary agent, and verification gate.

| # | Criterion | Status | Owner phase | Primary agent | Verification gate | Blocking? |
|---|-----------|--------|-------------|---------------|-------------------|-----------|
| 1 | First-run flow explains movement, food, predators, terrain, reproduction, mutation, lineage handoff, and at least one victory goal | **Partial** — tutorial covers 7 mechanics; victory goals and eras weak in first-run | 8 | `/evolution-apple-platform-ui-specialist` | First-run smoke — Phase 8 | Yes |
| 2 | Local save/continue survives relaunch; incompatible save versions handled gracefully | **Not started** — `SavedSimulation` + `saveSimulation()` only; no durable UX | 9 | `/evolution-apple-platform-ui-specialist` | Save/restore test + relaunch smoke — Phase 9 | Yes |
| 3 | iPhone, iPad, macOS pass focused smoke with platform controls | **Partial** — builds green; macOS M6 only | 10 | `/evolution-apple-platform-ui-specialist` | Multi-platform smoke — Phase 10 | Yes |
| 4 | Reduce Motion, VoiceOver on core controls, non-color state cues verified | **Partial** — code hooks + identifiers; manual pass missing | 10 | `/evolution-apple-platform-ui-specialist` | Graphics QA a11y rows — Phase 10 | Yes |
| 5 | Worst-case beta population has measured performance on iPhone-class hardware | **Not started** — scenario: 40 food, 5 predators, 20 descendants per [graphics-qa-checklist.md](../graphics-qa-checklist.md) | 11 | `/evolution-verifier` | Instruments per [graphics-asset-spec.md](../graphics-asset-spec.md) — Phase 11 | Yes |
| 6 | Known issues, feedback instructions, privacy copy, release checklist exist | **Not started** | 12 | `/evolution-dev-project-manager` | Release checklist complete — Phase 12 | Yes |
| 7 | No known release-blocking crash, data-loss bug, or common-start unwinnable seed | **Partial** — Phase 7 seeded balance suite done (no unwinnable common start; all goals reachable; [pacing-targets.md](pacing-targets.md)); crash/data-loss triage dashboard still Phase 11 | 7 + 11 | `/evolution-simulation-gameplay-specialist` + `/evolution-verifier` | Seeded balance suite + blocker list — Phase 7 met, Phase 11 pending | Yes |

## Requirement traceability matrix

| Requirement | Current status | Owner phase | Primary agent | Verification gate | Blocking for beta? |
|-------------|----------------|-------------|---------------|-------------------|------------------|
| Representative seed balance suite | **Done** (Phase 7) | 7 | `/evolution-simulation-gameplay-specialist` | `swift test` seeded balance coverage — 61 tests, all four goals reachable | Yes |
| Tutorial + victory goal clarity | Partial | 8 | `/evolution-apple-platform-ui-specialist` | First-run smoke + player guide alignment | Yes |
| Durable local save/continue | Not started | 9 | `/evolution-apple-platform-ui-specialist` | Relaunch smoke + schema migration tests | Yes |
| iPhone compact layout pass | Partial | 10 | `/evolution-apple-platform-ui-specialist` | iPhone simulator smoke | Yes |
| iPad / macOS layout + lifecycle | Partial | 10 | `/evolution-apple-platform-ui-specialist` | iPad/macOS smoke + background/foreground | Yes |
| Accessibility verification | Partial | 10 | `/evolution-apple-platform-ui-specialist` | VoiceOver, Reduce Motion, grayscale filters | Yes |
| Worst-case performance evidence | Not started | 11 | `/evolution-verifier` | Instruments frame-time notes | Yes |
| Crash/data-loss triage | Not started | 11 | `/evolution-verifier` | Release-blocker dashboard | Yes |
| TestFlight packaging + privacy copy | Not started | 12 | `/evolution-dev-project-manager` | Archive install + metadata draft | Yes |
| Docs/plan alignment | **In progress (Phase 6)** | 6 | `/evolution-dev-project-manager` | Grep consistency gate | Yes (gate for further work) |

## Scope review

| Date | Result | Notes |
|------|--------|-------|
| 2026-06-27 | **PASS** (conditional) | `/evolution-code-reviewer` pre-review: Apple-platform local-only TestFlight scope; no backend/accounts/custom analytics/multiplayer; Canvas retained unless Phase 11 proves measured failure; Phases 7–12 traced not bundled. |
| 2026-06-27 | **PASS** | Post-doc review: beta artifacts are documentation-only; traceability separates implemented vs beta-ready; seed sharing is Phase 9 risk not entry criterion; release-blockers defined concretely in [risk-register.md](risk-register.md). |

**Reviewer notes (scope creep guardrails):**

- Distinguish Apple TestFlight/App Store Connect feedback from custom telemetry.
- Feature inventory describes alpha implementation; beta-ready may be Partial/No for persistence, iPhone layout, a11y, and performance.
- Seed copy/share is Phase 9 (reproducible reports), not a standalone beta entry criterion.
- Phase 11 Canvas mitigation is profiling and coarsening before any engine migration.

## Related artifacts

- [feature-inventory.md](feature-inventory.md)
- [beta-readiness-matrix.md](beta-readiness-matrix.md)
- [risk-register.md](risk-register.md)
- [Project plan Phases 6–12](../../.cursor/plans/evolutionsimgame_project_plan_5df310fe.plan.md)
