# EvolutionSimGame Agent Guidance

EvolutionSimGame is a native Apple-platform interactive evolution simulator game for macOS, iPadOS, and iOS. Organisms should compete, adapt, reproduce, mutate, and evolve over time in a dynamic environment.

Canonical current-state reference: `README.md`. Treat repository code, tests, and current project files as the source of truth. Planning documents may describe intended, not implemented, behavior.

## Current Project Status

The project is currently at seed stage. Do not assume an Xcode project, Swift package, renderer, persistence layer, or app architecture exists until it is present in the repo.

When scaffolding begins, prefer a native Apple stack unless the user explicitly chooses another engine or framework. Keep simulation logic independent from UI/rendering so it can be tested deterministically.

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
- `/evolution-apple-platform-ui-specialist`: SwiftUI, SpriteKit/Metal/Canvas integration decisions, macOS/iPadOS/iOS layout, touch/pointer/keyboard input, game controls, accessibility, previews, and platform-native visual polish.
- `/evolution-verifier`: post-implementation verification, diff inspection, focused tests/builds, deterministic simulation checks, Apple-platform runtime checks, and separation of real regressions from toolchain or simulator noise.
- `/evolution-code-reviewer`: code review for bugs, regressions, scope creep, missing tests, simulation determinism issues, Apple-platform UI/input risks, performance risks, and violations of the native evolution simulator game direction.

When a task should be handled by a specific subagent, invoke it directly by name, such as `/evolution-simulation-gameplay-specialist design the first deterministic organism reproduction model`.

## Apple-Platform UI Guidance

- Do not make macOS, iPadOS, and iOS feel identical when platform-specific behavior is expected.
- Keep iPhone controls touch-friendly and readable.
- Use iPad space intentionally with adaptive panels, pointer support, keyboard shortcuts, and resizable layouts where relevant.
- Use macOS affordances when appropriate: menus, commands, keyboard shortcuts, toolbars, inspectors, settings windows, pointer targets, and multiwindow assumptions.
- Keep the simulation view visually primary; controls and overlays should not obscure important organism/environment state.
- Preserve accessibility labels, identifiers, and test hooks for important controls.

## Simulation And Gameplay Guidance

- Make trait effects explicit and observable.
- Prefer one mechanic at a time: add it, expose it, test it, and verify its effect on outcomes.
- Centralize tuning constants enough to support balancing.
- Design for pause, step, speed control, reset, seed/world settings, selected-organism details, and debug metrics when practical.
- Test edge cases such as empty populations, overpopulation, resource exhaustion, extreme mutation rates, tiny/huge worlds, and reset behavior.

## Development And Validation

The repo does not yet define canonical build/test commands. Add exact commands here once the project is scaffolded.

Until then, choose validation based on the project shape:

- Swift Package simulation core: run `swift test` for deterministic logic.
- Xcode project/workspace: resolve schemes and destinations before running builds/tests.
- iOS/iPadOS UI changes: verify relevant simulator destinations when available.
- macOS UI changes: verify the macOS app target separately from iPhone/iPad behavior.
- Documentation-only changes: run `git diff --check` and perform targeted content review.

For simulation work, prefer deterministic unit tests with seeded randomness. For UI/gameplay work, use builds, previews, simulator checks, screenshots, or runtime inspection when the scaffold supports them.

## Code Requirements

- Use typed, readable, modular code.
- Keep files focused and named after their primary type or responsibility.
- Add tests proportional to risk and behavior surface.
- Avoid broad abstractions until duplication or complexity justifies them.
- Prefer deterministic behavior and measurable verification over subjective claims.
