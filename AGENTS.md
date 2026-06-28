# EvolutionSimGame Agent Guidance

EvolutionSimGame is a native Apple-platform interactive evolution simulator game for macOS, iPadOS, and iOS. Organisms should compete, adapt, reproduce, mutate, and evolve over time in a dynamic environment.

Canonical current-state reference: `README.md`. Treat repository code, tests, and current project files as the source of truth. Planning documents may describe intended, not implemented, behavior.

## Current Project Status

The project is at **post-MVP alpha**: `EvolutionSimCore` (Swift package), `EvolutionSimGame` (SwiftUI multiplatform app), XcodeGen project, tests, and graphics docs are implemented. Core loop includes movement, food, predators, terrain, traits, reproduction, mutation choice, lineage handoff, eras, victory goals, mass extinction, tutorial scaffolding, contextual tips, Canvas rendering, and a Codable `SavedSimulation` model. **Public beta** (TestFlight, save/continue UX, platform QA, performance evidence, release ops) is tracked in Phases 7–12; see `docs/beta/`.

Prefer a native Apple stack unless the user explicitly chooses another engine or framework. Keep simulation logic independent from UI/rendering so it can be tested deterministically.

## Product Direction

Preserve these goals in all planning and implementation work:

- Build an interactive evolution simulator game for macOS, iPadOS, and iOS.
- Make adaptation visible and understandable to the player.
- Model organisms, traits, inheritance, mutation, reproduction, survival pressure, resources, and environment dynamics in a tunable way.
- Keep simulation behavior inspectable through metrics, debug overlays, selected-organism details, or similar tools when in scope.
- Support platform-appropriate interaction: touch on iPhone/iPad, pointer/keyboard/windowing on iPad/macOS, and desktop affordances on macOS.

## Architectural Invariants

Preserve these constraints unless the project direction is explicitly changed:

- Keep the simulation core testable without UI rendering.
- Use deterministic seeded simulation paths for tests, replay, balancing, and debugging when randomness is involved.
- Avoid hidden global mutable state and hidden randomness.
- Avoid frame-rate-dependent simulation behavior; simulation time steps should be explicit and stable.
- Keep organism/population/world state serializable enough for saves, snapshots, tests, and debug inspection when practical.
- Keep rendering, input, UI controls, persistence, and simulation logic separated by clear boundaries.
- Prefer simple, composable mechanics before complex biological realism.
- Keep population sizes, spatial queries, and update loops performance-aware for iPhone and iPad, not only Mac.

## Deferred Scope

Do not add these unless explicitly requested and planned:

- Cloud backend services, accounts, authentication, analytics, payments, or public networking.
- Multiplayer or shared online worlds.
- Non-Apple platform support.
- Native Android, web-first, or backend-heavy rewrites.
- Scientific-grade biological modeling that compromises game clarity or implementation momentum.
- Broad engine/framework changes without an explicit decision record.

## Agent Workflow

Before editing:

1. Inspect the current branch and run `git status --short --branch`.
2. Preserve all existing staged and unstaged changes. Never discard or revert work unless explicitly instructed.
3. If unrelated uncommitted changes exist, report them and continue only if they can be preserved safely.
4. Use focused `codex/` branches for scoped implementation work unless the task is explicitly merge/push/deploy-only.

During work:

- Read `README.md` and nearby source/docs before planning or implementing.
- Keep work narrowly scoped to the requested task.
- Avoid unrelated refactors, dependency additions, and behavior changes.
- Prefer established Apple-platform patterns and local project conventions once they exist.
- Keep the project compiling after code changes once a buildable scaffold exists.
- Do not commit, merge, or push unless explicitly requested.

When finishing:

- Report files changed, checks run, results, limitations, and merge readiness.
- Separate implemented behavior from planned or recommended follow-up work.

## Cursor Subagents

Project-specific Cursor subagents live in `.cursor/agents/`.

Use these agents when appropriate:

- `/evolution-dev-project-manager`: planning, scoping, task breakdowns, handoff prompts, model/tool recommendations, milestone sequencing, and agent coordination.
- `/evolution-simulation-gameplay-specialist`: organism behavior, traits, mutation, reproduction, selection pressure, environment dynamics, deterministic simulation loops, balancing, debug visualizations, and testable game mechanics.
- `/evolution-player-experience-specialist`: reward loops, fun factor, player goals, pacing, progression, onboarding, failure clarity, replayability, moment-to-moment satisfaction, and making the evolution simulator feel rewarding rather than only technically correct.
- `/evolution-apple-platform-ui-specialist`: SwiftUI, SpriteKit/Metal/Canvas integration decisions, macOS/iPadOS/iOS layout, touch/pointer/keyboard input, game controls, accessibility, previews, and platform-native visual polish.
- `/evolution-graphics-specialist`: art direction, organism/environment visual language, rendering quality, animation, VFX, camera polish, asset prompts, visual readability, visual QA, and graphics performance across macOS, iPadOS, and iOS.
- `/evolution-verifier`: post-implementation verification, diff inspection, focused tests/builds, deterministic simulation checks, Apple-platform runtime checks, and separation of real regressions from toolchain or simulator noise.
- `/evolution-code-reviewer`: code review for bugs, regressions, scope creep, missing tests, simulation determinism issues, Apple-platform UI/input risks, performance risks, and violations of the native evolution simulator game direction.
- `/evolution-git-handoff-specialist`: safe branch/status checks, scoped staging, commits, branch pushes, merge-to-main handoffs, beta/release branch hygiene, remote sync verification, and non-destructive git workflow troubleshooting.

When a task should be handled by a specific subagent, invoke it directly by name, such as `/evolution-simulation-gameplay-specialist design the first deterministic organism reproduction model`.

## Apple-Platform UI Guidance

- Do not make macOS, iPadOS, and iOS feel identical when platform-specific behavior is expected.
- Keep iPhone controls touch-friendly and readable.
- Use iPad space intentionally with adaptive panels, pointer support, keyboard shortcuts, and resizable layouts where relevant.
- Use macOS affordances when appropriate: menus, commands, keyboard shortcuts, toolbars, inspectors, settings windows, pointer targets, and multiwindow assumptions.
- Keep the simulation view visually primary; controls and overlays should not obscure important organism/environment state.
- Preserve accessibility labels, identifiers, and test hooks for important controls.

## Graphics And Visual Direction Guidance

- Make adaptation visible through organism shape, size, motion, color, texture, behavior cues, overlays, or selected-organism detail.
- Keep organism, resource, terrain, hazard, and population state readable across zoom levels, population densities, and device sizes.
- Do not rely on color alone for important state; pair color with shape, motion, iconography, labels, or inspector details when practical.
- Prefer a coherent visual language over disconnected effects, particles, gradients, or decorative polish.
- Keep rendering, camera, animation, and visual effects performance-aware for iPhone and iPad, not only macOS.
- Avoid visual effects that obscure simulation state or make cause and effect harder to understand.
- Document important rendering technology decisions when choosing between SwiftUI Canvas, SpriteKit, Metal, SceneKit, or hybrid approaches.

## Simulation And Gameplay Guidance

- Make trait effects explicit and observable.
- Prefer one mechanic at a time: add it, expose it, test it, and verify its effect on outcomes.
- Centralize tuning constants enough to support balancing.
- Design for pause, step, speed control, reset, seed/world settings, selected-organism details, and debug metrics when practical.
- Test edge cases such as empty populations, overpopulation, resource exhaustion, extreme mutation rates, tiny/huge worlds, and reset behavior.

## Player Experience And Reward Guidance

- Make the simulator rewarding to play, not only correct to observe.
- Preserve a clear short loop of move, forage, avoid danger, recover, and survive.
- Preserve a clear medium loop of reproduce, choose or receive mutation, hand off lineage control, and see adaptation change outcomes.
- Preserve a clear long loop of era progression, species spread, victory goals, extinction pressure, replayable seeds, and emergent lineage stories.
- Make goals, progress, success, danger, and failure causes visible enough that players understand what happened and what to try next.
- Reward observation and adaptation rather than hidden min-maxing, arbitrary points, grind, daily rewards, or engagement tricks disconnected from the simulation.
- Treat onboarding, contextual tips, milestone feedback, and failure explanations as part of game design, not just UI copy.
- Pair subjective "fun" judgments with evidence when practical: seeded pacing, first-run smoke notes, screenshots, manual QA observations, or deterministic tests.

## Development And Validation

Canonical commands are in [README.md](README.md):

- `cd EvolutionSimCore && swift test` — deterministic simulation tests (46 tests as of Phase 6).
- `xcodebuild -scheme EvolutionSimGame_macOS -destination 'platform=macOS' build`
- `xcodebuild -scheme EvolutionSimGame_iOS -destination 'platform=iOS Simulator,name=iPad (A16)' build`

For iOS/iPadOS UI changes, verify relevant simulator destinations when available. For macOS UI changes, verify the macOS app target separately from iPhone/iPad behavior. Documentation-only changes: run `git diff --check` and targeted content review.

For simulation work, prefer deterministic unit tests with seeded randomness. For UI/gameplay work, use builds, previews, simulator checks, screenshots, or runtime inspection. Graphics manual QA: [docs/graphics-qa-checklist.md](docs/graphics-qa-checklist.md). Beta scope and readiness: [docs/beta/](docs/beta/).

## Code Requirements

- Use typed, readable, modular code.
- Keep files focused and named after their primary type or responsibility.
- Add tests proportional to risk and behavior surface.
- Avoid broad abstractions until duplication or complexity justifies them.
- Prefer deterministic behavior and measurable verification over subjective claims.

## Cursor Cloud specific instructions

The Cursor Cloud VM is **Linux (Ubuntu 24.04, x86_64), not macOS**. This changes what can be validated here:

- **In scope on Linux:** `EvolutionSimCore` — the headless, deterministic simulation Swift package. It imports only `Foundation`/`XCTest`, so it builds and tests with the open-source Swift toolchain.
- **Out of scope on Linux (require macOS + Xcode, do not attempt here):** the `EvolutionSimGame` SwiftUI app, `xcodebuild` (the `EvolutionSimGame_macOS` / `EvolutionSimGame_iOS` schemes), the `EvolutionSimGameTests` target, and `xcodegen generate`. Verify those on an Apple host.

Toolchain notes:

- The open-source Swift toolchain (6.1.x) is preinstalled at `/usr/local/swift`, with `swift`/`swiftc` symlinked into `/usr/local/bin` (on `PATH` for non-interactive shells). No `nvm`/profile sourcing is needed.
- Commands (see `README.md` for the canonical list): build with `swift build` and test with `swift test`, both run from inside `EvolutionSimCore/`.
- There is no SwiftLint config; the Swift compiler (`swift build`, clean with no warnings) is the static check.
- The package has **no external dependencies**, so `swift package resolve` is effectively a no-op (this is what the startup update script runs).

Running/demoing the engine headlessly (no UI): create a throwaway SwiftPM executable that adds `EvolutionSimCore` as a path dependency and drives `SimulationController` (`init` → `step(input:)` → `snapshot()`), e.g. steering the player toward food to exercise movement, eating, reproduction, mutation choices, era progression, determinism, and save/restore.
