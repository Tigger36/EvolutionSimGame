# Beta Risk Register

Phase 6 risk register for public beta. Updated as Phases 7–12 close gaps.

## Release-blocker definition

A **release blocker** is any issue that prevents a supported platform from completing the core beta loop safely, or that causes unacceptable data loss or misleading player state.

Concrete release blockers include:

1. **Crash on launch** or crash during core loop (move, eat, reproduce, mutation choice, handoff) on a supported OS/device class
2. **Save data loss** — continue after relaunch restores wrong tick, phase, player, or pending mutation; or destructive reset affects unrelated data
3. **Unwinnable default path** — tutorial preset or default new-game seed (Phase 7 named seed suite) produces unavoidable early extinction with naive play; verified by seeded balance tests
4. **Core loop unplayable** on a supported platform — controls unreadable, simulation view obscured, or keyboard/touch paths broken
5. **Blocker accessibility failure** — core controls (movement, pause, mutation choice, start game) unusable with VoiceOver or with Reduce Motion causing incorrect simulation presentation
6. **Known data corruption** — Codable round-trip or file save produces invalid state without graceful recovery UX

Non-blockers (unless escalated): cosmetic VFX, non-critical overlay polish, balance difficulty on optional victory goals, missing content from aspirational design guide.

## Severity scale

| Level | Definition |
|-------|------------|
| **Blocker** | Matches release-blocker definition; must fix or reduce beta scope before TestFlight |
| **High** | Major friction or frequent failure; workaround exists but hurts beta feedback quality |
| **Medium** | Noticeable issue; does not stop completing a run |
| **Low** | Minor polish, docs, or edge case |

## Risk register

| ID | Risk | Likelihood | Impact | Mitigation | Owner phase | Status | Evidence |
|----|------|------------|--------|------------|-------------|--------|----------|
| R1 | Plan/docs drift from implementation | Medium | High | Phase 6 reconciliation; grep gate | 6 | **Mitigated** | `AGENTS.md`, README, player guide updated; beta docs created |
| R2 | Non-deterministic sim regressions | Low | Blocker | Seeded RNG, fixed ticks, 61 core tests, replay tests | 7 | **Mitigated** | `testSameSeedSameStateAfterNTicks`; Phase 7 victory/extinction replay-from-input-log tests; verifier on sim PRs |
| R3 | Save corruption / no durable UX | High | Blocker | Phase 9 versioned saves, migration tests, corrupt-save path | 9 | Partial | Single-slot Application Support save, schema v1 envelope, corrupt/incompatible recovery, and save/restore tests implemented; interactive relaunch smoke still pending |
| R4 | iPhone compact layout second-class | Medium | High | Phase 10 compact-width smoke; graphics QA iPhone row | 10 | Open | Checklist row blank; code has compact layout |
| R5 | Canvas performance at worst-case population | Medium | High | Phase 11 Instruments; `RenderQuality` coarsening | 11 | Open | No iPhone measurements; M6 macOS only |
| R6 | Backend/analytics scope creep | Low | High | Public beta scope doc; TestFlight-only feedback | 6 + 12 | **Mitigated** | [public-beta-scope.md](public-beta-scope.md) exclusions |
| R7 | Testers cannot reproduce failures | High | Medium | Phase 9 seed display/copy/share; feedback template with seed | 9 | Partial | Seed is visible in-run with copy/share affordances; interactive pasteboard/share-sheet smoke still pending |
| R8 | Tutorial insufficient for victory goals | Medium | High | Phase 8 first-run + player guide; new-game copy | 8 | Open | Tutorial has 7 steps; no victory step |
| R9 | Accessibility unverified | Medium | Blocker | Phase 10 VoiceOver, Reduce Motion, grayscale passes | 10 | Open | Identifiers exist; manual QA blank |
| R10 | Unwinnable common-start seed | Low | Blocker | Phase 7 seed suite + primordial balance tests | 7 | **Mitigated** | `Phase7BalanceTests`: seeds 42 & 1001 viable under naive play; all four victory goals reachable; pacing in [pacing-targets.md](pacing-targets.md) |
| R11 | Mass extinction / era surprise | Medium | Medium | Contextual tips + Phase 8 copy | 8 | Partial | Era tips in code; not in player guide pre-Phase 6 |
| R12 | Engine change without evidence | Low | High | Rendering decision record; Phase 11 before rewrite | 11 | Open | SwiftUI Canvas confirmed in docs |
| R13 | Graphics QA stale test count | Low | Low | Update checklist gate (37 → 46 tests) | 6 | **Mitigated** | Checklist updated in Phase 6 |
| R14 | No release triage process | High | High | Phase 11 blocker dashboard; Phase 12 known issues | 11 + 12 | Open | No dashboard yet |
| R15 | `EvolutionSimGameTests` not in Xcode project | Medium | Medium | Wire test target in `project.yml`; run in CI | 6+ | Open | 8 contextual-tip tests exist; `xcodebuild -list` shows no app test target |

## Review cadence

- Update status when a phase verification gate passes
- Re-evaluate blockers before each TestFlight candidate (Phase 12)
- Link reproduction steps and seeds for all High and Blocker items
