---
name: Player Experience Improvement Plan
overview: Phased player-experience plan for `/evolution-player-experience-specialist`. Improves onboarding, goal visibility, failure clarity, era framing, and replay motivation without reopening Phase 7 balance or beta-blocking graphics work.
todos:
  - id: phase-a-mutation-defer
    content: "Phase A: Increase firstMutationMinimumTick to 150 (UI deferral; no sim balance change)"
    status: completed
  - id: phase-a-ready-badge
    content: "Phase A: Verify or fix tutorial step 5 \"ready badge\" reference"
    status: completed
  - id: phase-a-pressure-label
    content: "Phase A: Add dominant evolutionary pressure label to mutation choice modal"
    status: completed
  - id: phase-a-tutorial-victory
    content: "Phase A: Upgrade tutorial step 8 (Victory Goals) with per-goal action hints"
    status: completed
  - id: phase-a-descendant-hud
    content: "Phase A: Show living descendant count during tutorial step 7 (Lineage Handoff)"
    status: completed
  - id: phase-a-how-to-play-eras
    content: "Phase A: Update HowToPlayView Eras & Progression with opportunity framing"
    status: completed
  - id: phase-a-smoke-gate
    content: "Phase A gate: Run first-run smoke script v1.0 on macOS, iPad, and iPhone"
    status: pending
  - id: phase-b-goal-progress
    content: "Phase B: Add GoalProgressView to inspector Lineage section"
    status: pending
  - id: phase-b-fitness-era
    content: "Phase B: Add next-era threshold context to Fitness Score in inspector"
    status: pending
  - id: phase-b-last-survivor
    content: "Phase B: Add lastSurvivorWarning contextual tip"
    status: pending
  - id: phase-b-biomes-approaching
    content: "Phase B: Add biomesEraApproaching contextual tip (fitness ≥ 850)"
    status: pending
  - id: phase-b-descendant-survived
    content: "Phase B: Add firstDescendantSurvived contextual tip"
    status: pending
  - id: phase-b-goal-milestones
    content: "Phase B: Add per-goal first-progress contextual tips"
    status: pending
  - id: phase-b-living-count-hud
    content: "Phase B: Add transient HUD indicator when lineage living count decreases"
    status: pending
  - id: phase-b-compact-hud-chip
    content: "Phase B: Add compact goal-progress chip to main HUD (iPhone priority)"
    status: pending
  - id: phase-c-extinction-copy
    content: "Phase C: Expand extinctionMessage with era, goal progress, and strategy hint"
    status: pending
  - id: phase-c-try-again-flow
    content: "Phase C: Add Try Again / New Seed / Start Screen to extinction and victory screens"
    status: pending
  - id: phase-c-era-tips
    content: "Phase C: Rewrite era advance tips with opportunity + threat framing"
    status: pending
  - id: phase-c-biomes-celebration
    content: "Phase C: Expand Biomes era tip as chapter-unlock moment (terrain names)"
    status: pending
  - id: phase-c-biomes-terrain-tips
    content: "Phase C: Add first-contact tips for forest, swamp, desert, tundra, mountain, ice"
    status: pending
  - id: phase-c-victory-message
    content: "Phase C: Add victoryMessage and goalApproachingMessage to GameCopy"
    status: pending
  - id: phase-d-inspector-reorder
    content: "Phase D: Reorganize InspectorPanelView (goal progress + pressure near top)"
    status: pending
  - id: phase-d-iphone-hud
    content: "Phase D: iPhone compact HUD — era, goal progress, living count, energy at a glance"
    status: pending
  - id: phase-d-platform-qa
    content: "Phase D: Multi-platform smoke — macOS shortcuts, iPad inspector, iPhone layout"
    status: pending
  - id: phase-e-seed-share
    content: "Phase E: Improve seed share text with run summary (era, goal, progress)"
    status: pending
  - id: phase-e-quick-restart
    content: "Phase E: Post-run quick-start path (same goal, minimal taps to replay)"
    status: pending
  - id: phase-e-continue-summary
    content: "Phase E: Enrich Continue subtitle with era and goal progress"
    status: pending
  - id: phase-e-seed-recommendations
    content: "Phase E: Add per-goal recommended starter seeds on NewGameSetupView"
    status: pending
isProject: false
---

# Player Experience Improvement Plan — EvolutionSimGame

**Author:** `/evolution-player-experience-specialist`  
**Date:** 2026-06-27  
**Branch:** `main` (clean, no uncommitted work)  
**Scope:** Design and planning only — no code changes, no doc edits, no commits  
**Companion plan:** `.cursor/plans/graphics_upgrade_plan_8762ad7c.plan.md` (Phase 1 complete; Phase 2 = 3D upgrade, post-beta)

---

## Table of Contents

0. [Todo List](#todo-list)
1. [Executive Summary](#1-executive-summary)
2. [Current-State Player Journey Audit](#2-current-state-player-journey-audit)
3. [Diagnosis by Reward Loop](#3-diagnosis-by-reward-loop)
4. [Prioritized Improvement Themes](#4-prioritized-improvement-themes)
5. [Phased Roadmap](#5-phased-roadmap)
6. [Quick Wins vs. Strategic Bets](#6-quick-wins-vs-strategic-bets)
7. [Metrics and Evidence Plan](#7-metrics-and-evidence-plan)
8. [Handoff Package](#8-handoff-package)

---

## Todo List

Track implementation progress here. Cursor plan UI reads the YAML `todos` in frontmatter; this section mirrors that list for human review.

### Phase A — First-Run Clarity (beta entry criterion #1)

- [ ] **phase-a-mutation-defer** — Increase `firstMutationMinimumTick` to 150
- [ ] **phase-a-ready-badge** — Verify or fix tutorial step 5 "ready badge" reference
- [ ] **phase-a-pressure-label** — Add dominant pressure label to mutation modal
- [ ] **phase-a-tutorial-victory** — Upgrade tutorial step 8 with per-goal action hints
- [ ] **phase-a-descendant-hud** — Show living descendant count during tutorial step 7
- [ ] **phase-a-how-to-play-eras** — Update HowToPlayView Eras & Progression copy
- [ ] **phase-a-smoke-gate** — Run first-run smoke script v1.0 (§7) on macOS, iPad, iPhone

### Phase B — Goal Progress and Milestone Visibility

- [ ] **phase-b-goal-progress** — Add `GoalProgressView` to inspector
- [ ] **phase-b-fitness-era** — Add next-era threshold to Fitness Score row
- [ ] **phase-b-last-survivor** — Add `lastSurvivorWarning` contextual tip
- [ ] **phase-b-biomes-approaching** — Add `biomesEraApproaching` tip (fitness ≥ 850)
- [ ] **phase-b-descendant-survived** — Add `firstDescendantSurvived` tip
- [ ] **phase-b-goal-milestones** — Add per-goal first-progress tips
- [ ] **phase-b-living-count-hud** — Transient HUD when living count decreases
- [ ] **phase-b-compact-hud-chip** — Compact goal-progress chip on main HUD

### Phase C — Failure Teaches + Era Chapter Moments

- [ ] **phase-c-extinction-copy** — Expand `extinctionMessage` with cause and strategy
- [ ] **phase-c-try-again-flow** — Try Again / New Seed / Start Screen on game-over screens
- [ ] **phase-c-era-tips** — Rewrite era advance tips (opportunity + threat)
- [ ] **phase-c-biomes-celebration** — Biomes era chapter-unlock messaging
- [ ] **phase-c-biomes-terrain-tips** — First-contact tips for six Biomes-era terrains
- [ ] **phase-c-victory-message** — Add `victoryMessage` and `goalApproachingMessage`

### Phase D — Platform Feel + Inspector Polish

- [ ] **phase-d-inspector-reorder** — Reorganize inspector section order
- [ ] **phase-d-iphone-hud** — iPhone compact HUD (era, goal, living count, energy)
- [ ] **phase-d-platform-qa** — Multi-platform smoke and macOS shortcut verification

### Phase E — Replayability and Post-Run Experience

- [ ] **phase-e-seed-share** — Run-summary seed share text
- [ ] **phase-e-quick-restart** — Post-run quick-start (same goal, ≤2 taps)
- [ ] **phase-e-continue-summary** — Enrich Continue subtitle with era and progress
- [ ] **phase-e-seed-recommendations** — Per-goal recommended seeds on new-game setup

---

## 1. Executive Summary

### Current Player Experience

EvolutionSimGame's core simulation loop is end-to-end functional and deterministically balanced after Phase 7. A player can move, eat, encounter predators, reproduce automatically, choose a guided mutation, survive lineage handoff, advance through five eras, pursue one of four victory goals, and save/continue across sessions. The Phase 7 balance pass confirmed all four goals are reachable on representative seeds and no common starts produce unavoidable early extinction.

However, the **player-facing layer — the feedback, framing, and legibility of these mechanics — lags significantly behind the simulation itself.** A new player landing in the game today will encounter the mutation choice modal before they have moved or eaten (tick-0 reproduction), will have no idea how close they are to their chosen victory goal, will not understand why their organism died or what to do differently, and will have no contextual landmarks when eras change. The game is mechanically ready for beta but experientially unready for a first-time player who has not read the code.

### Top Problems Limiting Fun, Clarity, and Replay Motivation

1. **The first mutation choice arrives before any survival context.** The founding organism spawns with 100 energy (above the 60-energy reproduction threshold), so reproduction fires at tick 0. Even with the 60-tick UI deferral (`firstMutationMinimumTick = 60`), the choice appears in the first two seconds of play — before the player understands what terrain they are in, what predators look like, or what any trait does in practice. The choice feels arbitrary rather than earned.

2. **Victory goal progress is invisible during play.** The inspector shows "Victory Goal: Spread to All Biomes" as a label, but there is no progress indicator anywhere in the HUD or inspector showing "2/6 biomes explored" or "5/12 organisms" or "fitness 420/1200." The player cannot tell whether they are on track, stalled, or nearly done.

3. **Death and extinction have no diagnostic value.** The extinction message (`GameCopy.extinctionMessage`) reports total born and generation number, but says nothing about the likely cause (starvation, predation, toxic terrain, old age) or what to try next. Individual descendant deaths are completely silent — there is no tip, counter, or explanation when an offspring dies.

4. **Era transitions feel like difficulty spikes, not story chapters.** Era advance contextual tips describe predator escalation ("Predators are more alert and a bit faster...") but do not acknowledge what the era means: a narrative milestone, new terrain unlocks (especially the Biomes era), new strategic opportunities, or what adaptations become more valuable. Players may experience era transitions as punishment rather than progression.

5. **The mutation choice's connection to actual survival behavior is not surfaced in the mutation UI.** The inspector shows evolutionary pressure (water, predator, food scarcity, exploration, toxic), and the contextual tip `.firstMutation` says "Recent survival pressure shapes which adaptations appear." But the mutation card modal itself does not show which pressure is dominant or why specific options appeared. The player cannot connect their play behavior to the options they are seeing.

### Top Highest-Leverage Improvements

1. **Gate the first mutation behind meaningful survival play (move + eat + survive threat once).** This one change transforms the first mutation from an arbitrary tooltip-reading exercise into a genuine decision rooted in what the player just experienced. Affects the short loop, medium loop entry, and first-run retention.

2. **Add a visible victory goal progress row to the HUD/inspector.** This is a mechanical hook that makes every surviving organism, every biome entered, and every generation feel like progress toward something. Affects medium and long loop satisfaction and "one more run" motivation.

3. **Upgrade death and extinction screens to explain causes and suggest next-run strategies.** Even a single sentence — "Your lineage was wiped out by predators near the Reef transition. Try choosing Armor or Enhanced Senses early." — transforms failure from a dead end into a learning moment. Affects replay motivation more than any other single change.

4. **Reframe era transitions as "Chapter Unlocked" moments, not just warnings.** Add a brief celebration + new-opportunity framing alongside the escalation warning. The Biomes era unlock deserves particular attention as the midgame pivot point.

5. **Show dominant evolutionary pressure on the mutation card.** One line — "Your lineage has been under heavy predator pressure" — contextualizes the three options and teaches the game's core feedback loop: play style → pressure → mutation options → outcomes.

---

## 2. Current-State Player Journey Audit

### First 15 Minutes (Step-by-Step)

| # | Moment | What happens today | Player likely feels | Gap / Friction |
|---|--------|--------------------|---------------------|----------------|
| 1 | **App launch** | Start screen with title, 4 loop bullets, Tutorial / New Game / How to Play buttons | Curious; may not read the bullets | Bullets are accurate but abstract ("Reproduce automatically at safe, high-energy moments"). No visual hook. No indication of era, goals, or world scope. |
| 2 | **Start Tutorial tapped** | Tutorial step 1 ("Move Your Organism") appears over a live simulation. Tick loop is running. | Engaged; wants to move | Good. Step title and message are clear. "Step 1 of 8" counter is helpful. |
| 3 | **First movement** | Player moves >25 units from start; step auto-advances to "Gather Energy" | Satisfied; immediate feedback | Works well. Completion threshold (25 units) is low enough to feel instant. |
| 4 | **First food eaten (tick ~2–51)** | Step 2 auto-completes when energy rises > baseline+5 | Satisfying energy increase | Works. BUT: the founding organism already has 100/100 energy, so moving toward food may not visually change the energy bar much. Player may not notice the effect. |
| 5 | **Tick 0: reproduction fires** | Sim reproduces immediately at tick 0 (100 energy ≥ 60 threshold). The mutation deferral holds the modal for 60 UI timer callbacks (≈2 real seconds at 1× speed). | **Confused / jarred** if mutation fires mid-tutorial; deferred until step 6, but the reproduction VFX appears immediately | **Critical gap.** Reproduction fires before the player has moved or eaten. The offspring spawns at tick 0. If in tutorial mode, mutation is gated behind the `chooseMutation` step — this is correctly handled. In **normal play** (skipped tutorial), the modal fires after 60 ticks (2 seconds), before the player has any context. |
| 6 | **Avoid Predators (step 3)** | Manual Continue required. Message is read-only — no action completion. | Passive; may skip without seeing a predator | No completion check based on actual predator encounter or near-miss. Weak teaching moment. |
| 7 | **Terrain Basics (step 4)** | Completes when player enters any non-land terrain | Good — action-driven | The biome chip is mentioned but the player may not know where to look. |
| 8 | **Reproduce (step 5)** | Completes when `snapshot.phase == .awaitingMutationChoice` or `totalBorn > 0` | Passive wait — reproduction is automatic | Player is not taught *why* reproduction fired now (energy + safe site). The "ready badge" mentioned in the message may not be clearly visible. |
| 9 | **Choose an Adaptation (step 6)** | Mutation modal appears; player picks one | Can feel exciting if options are understood | No context for why these three options appear or what "dominant pressure" is. Stats shown but tradeoffs unclear for a first-time player. |
| 10 | **Lineage Handoff (step 7)** | Manual Continue; no action required | Reads the concept | Never demonstrated unless the tutorial organism actually dies. Since the tutorial uses seed 1001 with reduced predators, death is unlikely during this step. The player is told about handoff but does not experience it. |
| 11 | **Victory Goals (step 8)** | Lists all four goals; mentions tutorial uses seed 1001 with population goal | Informed but not activated | **R8 gap.** Player sees goal names but has no idea how to pursue any goal. No "what to watch for" or "your current progress is…" framing. Transition to new game setup feels disconnected. |
| 12 | **New Game Setup** | Victory goal picker, seed, mass extinction toggle | Goal names readable; descriptions are accurate but terse | Goals described individually but not comparatively. New player cannot know which goal suits their play style. No difficulty guidance. The mass extinction toggle has good explanatory text. |
| 13 | **Game starts (standard run)** | Organism spawns at center, 100 energy, tick 0 | Motivated | **Same tick-0 issue.** First mutation modal fires in 2 seconds. Player hasn't moved yet. |
| 14 | **First minutes of play** | Move, eat, avoid predators | Generally fun if the player finds food quickly | No contextual landmark for "you are now in the Primordial Pool era, here's what that means." Era is visible in inspector but not explained at game start. |
| 15 | **First contextual tips** | Terrain tips fire on first water/toxic/mud entry. `firstReproductionReady` and `firstUnsafeReproductionBlocked` fire appropriately. | Helpful; tip banners are well-written | Tips are one-shot (shown once per UserDefaults flag). A player who dismisses them quickly may not read them. |
| 16 | **First offspring born + mutation** | Offspring spawns; mutation choice delayed 60 ticks on first occurrence | Satisfying in most cases | Still early in the run. Player has survival context now but the "why this option appeared" is not explained. |
| 17 | **First offspring dies** | `.firstOffspringLoss` tip fires | Helpful — actionable advice | Works, but the tip says "Reproduce near food, away from predators, on non-damaging terrain" — the player already knows this from tutorial. More useful: "Your offspring died to [X]. Next time: [Y]." Cause is not surfaced. |
| 18 | **Era → Reef/Shallows (tick ~245–382 on baseline seeds)** | Era advance contextual tip fires: "Predators are more alert and a bit faster as shallow waters grow crowded." | Warned but not excited | Purely a threat escalation message. No acknowledgment that the player did something to earn this. No new-opportunity framing. |
| 19 | **Victory goal: no visible progress** | Inspector shows goal name in Lineage section | Forgotten | **Core gap.** By mid-run, the player may have forgotten what goal they chose or may not know how close they are. |
| 20 | **Extinction / victory** | `extinctionMessage` or victory modal | Extinction: hollow ("generation X, Y offspring"). Victory: unclear what feedback exists | **Major gap.** No cause analysis for extinction. Victory state not audited in detail from source — likely also thin. |

### Typical Run Arc

| Phase | What happens | Player likely feels | Gap |
|-------|-------------|---------------------|-----|
| **Early (ticks 0–250)** | Primordial era, 1–3 predators at 35% aggression grace window, food plentiful (70 particles, respawn every 12 ticks), first reproduction tick 0, era transitions to Reef at ~tick 245–382 | Learning; occasionally surprised by first predator or terrain | Tick-0 mutation; no goal progress; era transition feels like a difficulty spike |
| **Mid (ticks 250–1200)** | Reef and Landfall eras; colony can grow to 4–8 organisms; terrain complexity increases; all biome types arrive at Biomes era (~tick ~950 fitness threshold) | Engaging if lineage is growing; stressful if colony is thin | No celebration for milestones; Biomes era unlocks full terrain set but no UX fanfare; goal progress invisible |
| **Late (ticks 1200–2000)** | Ecosystem Dominance; mass extinction fires at tick 2000; hardest predator scaling | Tense; exciting if colony is strong | Era 5 can feel suddenly lethal; mass extinction tip is good but fires at the moment of the event, not as a warning |
| **Victory / near-victory** | Victory condition met (biomes, population, intelligence, or tick 3000 mass extinction survival) | Unclear — victory presentation not examined in source | Victory goal description in inspector is terse; no "you're close!" momentum building |
| **Extinction / replay** | `extinctionMessage`: generation + total born count | Deflated; no actionable insight | No cause analysis; "Start a new run to try a different strategy" with no hint of what strategy |

---

## 3. Diagnosis by Reward Loop

### 3.1 Short Loop (Moment-to-Moment)

**What works:**
- Movement is responsive and input-clear (D-pad, joystick, arrow keys).
- Food particles are visible and plentiful after Phase 7 tuning (22 energy/particle, 70 max, 12-tick respawn). Foraging is now net-positive.
- Predators have a grace window (`primordialGraceTicks = 240`, 35% aggression at tick 0 ramping to full). First-timers are not immediately overwhelmed.
- Terrain entry banners fire correctly and disappear after 2.5 seconds. Biome chip updates.
- `FeedbackBanner` (green capsule) confirms mutations and seed copies.

**What feels flat or opaque:**
- **Energy bar baseline issue:** At game start, energy is at 100/100. A player who eats food immediately sees no change (already full). The first food meal that matters visibly is the *second* or third. This weakens the "eat food = energy rises" feedback loop in the first 30 seconds.
- **No visual indication that the organism is about to reproduce.** The "ready badge" mentioned in the tutorial step 5 message (`TutorialViews.swift` line 40: "Watch for the ready badge") — does this badge exist in the current build? The feature-inventory lists "automatic reproduction + mutation pause" as implemented but there is no explicit reference to a "ready badge" UI element in `InspectorPanelView` or `ContentView`. This warrants verification.
- **Predator threat is told, not shown.** The first time a predator approaches, the player has no warning except their own visual awareness. The `senseRadius` trait is explained in the inspector, but new players do not know to look there.
- **No short-loop win celebration.** Eating food, hitting a high energy streak, or successfully evading a predator produces no positive feedback — no sound cue, brief particle effect, or banner. Only mutations and seed copies use the `FeedbackBanner`. (Note: VFX system includes reproduction/damage/death but not "predator evaded" or "food streak.")

> ⚠️ **DOC INCONSISTENCY:** `TutorialViews.swift` line 40 references "Watch for the ready badge" as a UI element the player should observe, but no "reproduction ready badge" HUD element is visible in `InspectorPanelView` or `ContentView` source scans. If this badge is rendered by the Canvas/overlay system, it is undocumented in the player guide. If it does not exist, the tutorial step message contains inaccurate instructions. **Verification required before Phase 8 first-run smoke.**

**Why the short loop is "mostly okay but needs polish:**
The mechanics are sound and the Phase 7 balance means survival is achievable. But there are no positive feedback moments for survival skill — no "close call" celebration, no streak reward for sustained energy, no audio/haptic hook (these are out of scope here). The loop works but doesn't yet *feel* alive.

---

### 3.2 Medium Loop (Adaptation)

**What works:**
- Automatic reproduction with safe-site gating is mechanically clear and well-documented.
- The 60-tick deferral (`firstMutationMinimumTick`) correctly delays the first mutation modal in standard play, giving the player a short survival window first.
- Contextual mutation offers are pressure-biased (`testWaterPressureBiasesOffers` passes). This is a strong design pillar.
- `mutationCostSummary` provides per-option tradeoff copy. `mutationAccessibilityLabel` fully describes stat changes and biome impact.
- Lineage handoff fires correctly; `.firstLineageHandoff` tip explains the concept well.
- `BiomeCompatibilityRow` in the inspector is excellent — it shows per-terrain speed, energy drain, and damage with color-coded values.

**What feels flat or opaque:**
- **The mutation choice arrives disconnected from why.** The player is shown three options and told "Recent survival pressure shapes which adaptations appear" (only in the inspector and the `.firstMutation` tip). But on the mutation card UI itself, there is no "dominant pressure this run: predator avoidance" or similar framing. The player making their second and third mutations cannot understand the feedback loop unless they read the inspector during play.
- **Tick-0 reproduction breaks medium loop entry.** The founding organism spawns above the reproduction threshold (100 energy ≥ 60). The first offspring exists before the player understands the world. While the 60-tick deferral improves this, the mutation still fires within 2 seconds of game start in normal play. The player has not yet had a near-miss, explored terrain, or invested any survival effort when they are asked to make their first evolutionary choice.
  - Source: `pacing-targets.md` lines 80–92: "First reproduction/mutation at tick 0 is intentional-but-immediate... *Follow-up (Phase 8 onboarding): gate the first mutation modal behind a few ticks of play so the choice lands after the player has learned to move and eat.*"
- **Tradeoff comprehension during mutation choice is low.** Stats are shown as percentage bars with numerical deltas (`MutationPreview.formattedTraitDeltas`). For a new player, "Speed +8%" vs. "Armor +12%, Speed −5%" requires understanding of what the current organism's baseline speed *means* in practice. No scenario framing ("better in water," "safer vs. predators in the Reef era") is shown in the card UI.
- **Post-mutation feedback is a 3-second green capsule.** "Offspring adapted: Enhanced Senses" appears briefly. The player then continues as the parent. The offspring is alive somewhere but hard to track. There is no "offspring is now over there" visual hook or "your mutation will pay off when..." framing.
- **No "first successful descendant" milestone.** The game tracks `totalBorn` and fires `.firstOffspringLoss` if an offspring dies, but there is no positive counterpart: a tip, milestone, or celebration for when an offspring *survives* to a meaningful age or successfully forages. This asymmetry means the medium loop sends more negative signals (offspring died) than positive ones (offspring thriving!).

---

### 3.3 Long Loop (Progression / Replay)

**What works:**
- Five eras are implemented and era-advance contextual tips exist for all four forward transitions (Reef, Landfall, Biomes, Ecosystem Dominance).
- Mass extinction fires on schedule (tick 2000) with a tip and world-tint shift.
- Four distinct victory goals provide meaningful run variation: biome spread (exploration playstyle), population (colony management), intelligence (deep generational play), and mass extinction survival (endurance).
- Phase 7 balance verified all four are reachable on representative seeds.
- Seed display, copy, and share supports replay and feedback.

**What feels flat, opaque, or arbitrary:**

**Goal progress invisibility is the central long-loop failure.** The player chose a goal at new game setup (e.g., "Spread to All Biomes"), but during play the only reference to it is:
  - `LabeledContent("Victory Goal", value: snapshot.victoryGoal.displayName)` in the inspector Lineage section.
  - `LabeledContent("Biomes Explored", value: "\(snapshot.fitness.biomesExplored.count)")` in the same section.
  - No combined progress readout: "2/6 biomes explored" vs. "Spread to All Biomes."
  - No in-HUD progress ring, milestone pop, or "you are halfway there" contextual tip.
  - For the evolveIntelligence goal: generation is shown (`LabeledContent("Generation", value: "\(player.generation)")`), composite fitness is shown, but the thresholds (gen 5 + fitness 1200) are nowhere displayed.
  - For the reachPopulation goal: `LabeledContent("Living", value: "\(snapshot.lineage.livingCount)")` is shown, but "12" as the target is never displayed in the HUD or inspector during play.

**Era transitions lack earned-milestone framing.** Every era transition message focuses on predator escalation. The Biomes era (era 4) is particularly under-served: it unlocks the full terrain set (forest, swamp, desert, tundra, mountain, ice) — a genuinely exciting moment — but the era tip (`eraAdvanceLandfall` → `eraAdvanceBiomes`) says only: "Predators are faster, more numerous, and harder to evade across diverse biomes." The new biomes, new strategic opportunities, and new adaptation paths are not mentioned.

**Fitness/composite score meaning is opaque.** The inspector shows `LabeledContent("Fitness Score", value: String(format: "%.0f", snapshot.fitness.compositeScore))` but nowhere shows the era thresholds (era 2: 180, era 3: 480, era 4: 950, era 5: 1600) or goal thresholds alongside the current score. A player with fitness 420 has no idea they are 60 points from era 3 or that the evolveIntelligence goal requires 1200.

**Extinction messaging has no actionable analysis.** `GameCopy.extinctionMessage` (lines 56–61):
- If totalBorn == 0: "Your lineage died out before reproducing. Gather energy, avoid predators, and reproduce at a safe site to continue the lineage."
- Otherwise: "Every descendant has died. Your lineage reached generation [gen] with [n] offspring born. Start a new run to try a different strategy."

The second message is the more common outcome. It contains no information about what killed the lineage, what era they reached, how close they were to their goal, or what specific strategy to try. This is a missed retention moment.

**"One more run" motivation is weakly scaffolded.** After extinction, the path back to gameplay is: dismiss extinction → return to start screen → new game setup → configure → start. No "replay this seed" shortcut, no "try the same goal with different mutations" path, no summary of what went well. The seed is visible in-run (Phase 9 delivered this), but post-extinction there is no "your seed was 42 — replay it?" affordance.

---

## 4. Prioritized Improvement Themes

### Theme A: First-Run Tutorial Sequencing and the Tick-0 Mutation

**Player question answered:** "What am I supposed to do first? Why is this choice appearing right now?"  
**Loop:** Short loop entry + medium loop first impression  
**Evidence:** `pacing-targets.md` lines 80–92; `GameViewModel.swift` lines 91–93 (`firstMutationMinimumTick = 60`); `TutorialViews.swift` step 6 copy  

**Problem:** The founding organism spawns at 100 energy (above the 60-energy reproduction threshold). Reproduction fires at tick 0. In the tutorial, the mutation modal is correctly gated behind step 6 (`chooseMutation`). In **standard play**, the modal appears after a 60-tick (~2 second) deferral — before the player has had a meaningful survival interaction.

`pacing-targets.md` explicitly flags this: "*Follow-up (Phase 8 onboarding): gate the first mutation modal behind a few ticks of play so the choice lands after the player has learned to move and eat.*"

Additionally, the tutorialStep 5 ("Reproduce") message says "Watch for the ready badge" — but no "ready badge" HUD element is confirmed in current source files. This may confuse players who look for it.

**Recommendations:**

1. **Increase `firstMutationMinimumTick` from 60 to ~150 ticks (5 real seconds at 1×).** The current 60-tick deferral is too short. 150 ticks ensures the player has moved, eaten at least one food (first food: tick ~2–51 on baseline seeds), and had a chance to see a predator before the mutation choice fires. This is a pure UI-sequencing change with no balance impact (documented in `pacing-targets.md`). Verify that the sim does not accumulate phantom reproduction events during deferral. Implement and test with seed 42 and seed 1001.

2. **For the tutorial**, add an explicit intermediate teaching step between "Reproduce" and "Choose an Adaptation": **show the mutation card and explain *why* those three options appeared.** One sentence: "Your recent movement and food-seeking shaped these options. Pick one — it applies to your offspring, not you." This converts the choice from a stat comparison into a cause-and-effect moment.

3. **Fix or verify the "ready badge" reference.** Either confirm it exists (Canvas overlay element) and document it in the player guide, or remove the phrase from `TutorialViews` step 5 message and replace with a description of what the HUD actually shows (e.g., "The reproduction status in the inspector changes to 'Automatic when play resumes' when you are ready.").

4. **Tutorial step 7 ("Lineage Continues") should demonstrate handoff when possible.** Since the tutorial uses seed 1001 with gentle predators, natural death is unlikely in the handoff step. Consider: briefly showing the handoff concept via a one-sentence HUD note when the player has living descendants ("You now have 1 descendant alive — if you die, they continue your lineage.") rather than just a text step the player reads and continues.

**Tradeoffs:** Increasing the deferral to 150 ticks means the player controls a parent organism that has already reproduced without their awareness of the choice yet — this is slightly odd narratively but better than premature choice. The sim state is unaffected. The 60-tick deferral gap exists specifically because Phase 7 excluded it; this is the right Phase 8 task.

**Simulation depth vs. fun:** No tradeoff here — this is pure UX sequencing with no balance impact.  
**Platform scope:** Applies uniformly across macOS, iPad, iPhone.

---

### Theme B: Victory Goal Progress Feedback

**Player question answered:** "Am I making progress toward my goal? How close am I? What should I be doing right now?"  
**Loop:** Long loop (primary) + medium loop (reinforcement)  
**Evidence:** `InspectorPanelView.swift` lines 86–93 (goal shown as label only); `SimulationTuning.swift` lines 97–111 (victory constants); `feature-inventory.md` row "Victory goals" — "Missing" from README gameplay section, "Missing" from player guide, "Missing" from manual QA

**Problem:** The current inspector shows:
```
Victory Goal: Spread to All Biomes
Biomes Explored: 2
```

These are two separate unlabeled data points with no connection to the goal threshold. The player cannot tell that they need 6 biomes (`biomeSpreadVictoryCount = 6`). The evolveIntelligence goal shows generation (1, 2, 3...) and composite fitness separately with no "5/5 generations needed" or "420/1200 fitness needed" framing.

**Recommendations:**

1. **Add a "Goal Progress" row to the inspector's Lineage section.** Show a formatted string calculated from the current snapshot and goal:
   - `spreadToAllBiomes`: "Biomes: 2 of 6 explored" + a small progress bar
   - `reachPopulation`: "Population: 5 of 12 living" + a small progress bar
   - `evolveIntelligence`: "Generation: 3 of 5 • Fitness: 842 / 1200" + dual progress
   - `surviveMassExtinction`: "Tick: 1,240 / 3,000" (if mass extinction active) or "Mass extinction begins around tick 2000"

2. **Add a milestone contextual tip for "halfway to victory."** When progress crosses 50% for any goal, fire a one-shot tip: "You're halfway to your goal. Keep adapting." This reinforces that the goal is achievable and the player is on track.

3. **Add a "victory approaching" contextual tip at ~80% progress.** One sentence for each goal type to create a surge of motivation in the late game.

4. **Show era thresholds in the inspector alongside fitness score.** Add a small note below the Fitness Score row: "Next era at: 480" (or "Era 5 reached" when at max). This contextualizes a number that currently has no anchor.

**Tradeoffs:** Inspector already has many sections; adding goal progress and era threshold may create visual noise. Mitigation: keep the goal progress row compact (one labeled value + small ProgressView, similar to existing `CompatibilityBar`). The additional inspector density is appropriate — the inspector is the deep-dive panel, not the primary HUD. For iPhone compact layout, the inspector needs platform-specific evaluation (defer to `/evolution-apple-platform-ui-specialist`).

**Graphics dependency:** Goal progress could also be added to the primary HUD (a compact goal chip in the game view). This crosses into graphics/UI territory and should be coordinated with `/evolution-apple-platform-ui-specialist`. The inspector version is PX-only work.

---

### Theme C: Mutation Choice as a Meaningful Decision

**Player question answered:** "Why am I being offered these specific options? What do they mean for my survival situation right now? Which should I pick?"  
**Loop:** Medium loop (adaptation)  
**Evidence:** `ContextualTipsViews.swift` lines 59–60 (`.firstMutation` tip); `InspectorPanelView.swift` lines 133–143 (evolutionary pressure section); `GameCopy.swift` lines 85–113 (mutation accessibility + cost copy)

**Problem:** The mutation card modal shows three options with stat changes and biome impact, but does not surface:
1. Which pressure is currently dominant (predator, water, food scarcity, etc.)
2. Why the specific options appeared (the link between pressure and offer is described in the inspector but not in the modal)
3. A comparative recommendation framing for new players

The existing infrastructure is excellent: `snapshot.pressure.dominantPressureLabel` exists, `mutationCostSummary` is computed, biome impact is computed. The gap is in surface presentation.

**Recommendations:**

1. **Add a one-line "pressure context" to the mutation card.** Show the dominant pressure using the existing `dominantPressureLabel` from the snapshot: "Recent pressure: Predator encounters" or "Recent pressure: Water exposure." This is already calculated; it just needs to be surfaced in the mutation modal UI. Implementation: pass `snapshot.pressure.dominantPressureLabel` to the mutation view and display it as a subtitle line.

2. **Improve `mutationCostSummary` copy for first-time players.** The current fallback case uses the option's description string, which can be verbose and technical. Audit each common mutation option and write a 10-word max tradeoff summary:
   - "Better in water, slower on land."
   - "Harder to catch, needs more food."
   - "Safer near allies, slight energy cost."
   - "Lower energy to reproduce, slower energy gain."

3. **Add a "first mutation" tutorial step explanation.** When the player reaches the `chooseMutation` tutorial step, a brief overlay note (inside the `TutorialCalloutView`) should say: "Your survival experience shaped these options — choosing an adaptation that matches your pressure gives the best results."

4. **In the HowToPlayView**, the "Evolution Choices" section already describes pressure-driven offers. The connection between inspecting pressure in the inspector and understanding why options appear in the card modal could be made explicit with one sentence: "You can see your current evolutionary pressures in the Inspector panel while playing."

**Tradeoffs:** Adding the pressure line to the mutation card adds ~1 line to a modal that is already information-dense. This is justified because it teaches the core game mechanic. The line is UI copy, not simulation logic — no risk of behavior change. Coordinate UI layout with `/evolution-apple-platform-ui-specialist` to ensure the modal remains clean on iPhone compact.

---

### Theme D: Failure Teaches — Death, Extinction, and "Try This Next"

**Player question answered:** "Why did I fail? What caused my lineage to die? What should I do differently in the next run?"  
**Loop:** Medium loop (individual deaths) + long loop replay motivation  
**Evidence:** `GameCopy.swift` lines 56–61 (`extinctionMessage`); `docs/player-guide.md` lines 183: "Future: Detailed death notifications explaining exactly why each offspring died"; `feature-inventory.md` row "Lineage handoff + extinction" — "Phase 8 — death/handoff copy"

**Problem:** The current extinction screen reports generation and offspring count but provides no causal analysis. "Every descendant has died. Your lineage reached generation 2 with 4 offspring born. Start a new run to try a different strategy." — contains no information about what killed them, what era they reached, how close they were to their victory goal, or what was working.

Individual descendant deaths are completely silent — no counter, no tip, no notification. The `.firstOffspringLoss` tip fires once on the first immediate death (offspring born and died in the same birth-tick-window), but subsequent descendant deaths throughout the run produce no player feedback.

**Recommendations:**

1. **Upgrade `extinctionMessage` to include run context.** Expand the static function to accept more `SimulationSnapshot` fields and generate a one-paragraph "run recap":
   - Era reached: "You reached the Reef / Shallows era."
   - Likely cause (approximate): derive from era and known kill sources: "In the Reef era, predator aggression increases significantly. Lineages often struggle when offspring are born in unprotected terrain."
   - Goal progress: "You explored 2 of 6 biomes toward the Spread to All Biomes goal."
   - Suggested next approach: One concrete, actionable sentence tied to the likely cause.
   - **Importantly:** Causal analysis cannot be perfect without descendant death tracking (a future feature). Frame it as guidance, not a definitive diagnosis: "Predators were active at Reef level — consider prioritizing Armor or Enhanced Senses early."

2. **Add "era reached" and "goal progress" to the extinction screen.** Even without causal analysis, showing "You reached Era 3: Landfall — 3 of 5 eras" and "Goal: 2/6 biomes" gives the player a benchmark for their next attempt.

3. **Add a "living descendants at risk" contextual tip.** When `lineage.livingCount == 1` (down to last survivor), fire a one-shot tip: "You have one living organism left. Reach food and stay away from hazards to keep the lineage going." This converts a silent countdown to extinction into a tense, actionable moment.

4. **Add a brief "descendant lost" transient counter to the HUD.** Not a full death notification (that is marked as a future feature in `docs/player-guide.md`), but when `livingCount` drops during play, show a brief HUD indicator (e.g., "Lineage: 3 → 2" for 2 seconds) so the player knows something happened. This requires no cause data.

5. **Add "New Run (same goal)" and "Replay Seed" shortcuts from the extinction screen.** Currently the player must navigate back to start screen → new game setup. A "Try Again" button that re-launches with the same victory goal and seed, and a "New Seed, Same Goal" button, would dramatically reduce friction for replayability. This is a UI flow change — defer layout to `/evolution-apple-platform-ui-specialist`.

**Tradeoffs:** True causal analysis (why each organism died) requires tracking kill causes per organism — this is noted as a future feature in `docs/player-guide.md`. The plan above avoids implementing that tracking and instead uses era + goal-progress context for guidance. This is an honest, achievable improvement without simulation changes. Flag in copy that it is approximate ("Predators were the likely cause in this era") to avoid misleading the player with false precision.

**Graphics dependency:** Extinction screen layout and "Try Again" button placement should coordinate with `/evolution-apple-platform-ui-specialist`. The copy and logic can be authored by PX agent.

---

### Theme E: Era Transitions as Chapter Moments

**Player question answered:** "What just changed? What does this era mean for my lineage? What opportunities and threats are new?"  
**Loop:** Long loop (progression) + short loop (threat awareness)  
**Evidence:** `GameCopy.swift` lines 21–41 (era advance tips — all focus on predator escalation); `ContextualTipsViews.swift` lines 14–17 (era advance tips); `docs/player-guide.md` lines 86–101 (era names and biome unlock); `feature-inventory.md` row "Eras + era transitions" — "Phase 8 — eras in player guide"

**Problem:** Every era advance tip in `GameCopy.eraAdvanceTipMessage` is a predator escalation warning. The format is:
- Reef: "Predators are more alert and a bit faster..."
- Landfall: "More predators roam the world..."
- Biomes: "Predators are faster, more numerous, and harder to evade..."
- Ecosystem Dominance: "Peak predator pressure..."

This is accurate but one-dimensional. Era transitions should feel like story chapters with new pressures **and** new opportunities. The Biomes era is particularly under-served — it unlocks the entire full terrain set (forest, swamp, desert, tundra, mountain, ice), which is a major strategic expansion. This is mentioned nowhere in the tip.

**Recommendations:**

1. **Restructure era advance tip messages to have two parts: "What's new" and "Watch out."** Example format:
   - Reef/Shallows: "Your lineage has expanded into shallow waters. The ecosystem is crowding — predators are more alert. Swim traits and sense radius help here."
   - Landfall: "Land is now accessible. Crawling terrain and moisture survival create new pressures. More predators roam. Amphibious builds thrive."
   - **Biomes** (most important): "The full world is open — forest, swamp, desert, tundra, mountain, and ice are now active. Each biome rewards different traits. Predators are faster. Explore and adapt widely to spread your lineage."
   - Ecosystem Dominance: "Your lineage has reached apex conditions. Predators are at peak strength. A colony built on diverse adaptations survives where a single lineage type cannot."

2. **Add an "era celebration" VFX or brief screen tint** to distinguish transitions as story beats, not just warning deliveries. This is a graphics/UI item — flag as dependency on `/evolution-graphics-specialist` (Phase 2/M6 VFX system exists and includes event VFX).

3. **Add era names and descriptions to the HowToPlayView** (they are missing from the existing "Eras & Progression" section) with the opportunity framing, not just the threat framing.

4. **Add "Biomes era approaching" one-shot tip when fitness score is within 100 points of era 4 threshold (950).** Something like: "Fitness is approaching the Biomes era — the full terrain set unlocks soon. Traits that help on land and water will matter." This gives the player advance warning to make strategic mutation choices before the unlock.

**Tradeoffs:** Longer tip messages may not fit the `ContextualTipBanner` layout without truncation or text size reduction. Consider a larger tip presentation format for era transitions, or a distinct "chapter card" presentation. Defer layout to `/evolution-apple-platform-ui-specialist`. Copy can be authored now.

**Graphics dependency:** Era "chapter card" treatment would benefit from era-specific color or art treatment (relevant to Graphics Phase 2 milestones M8+). For Phase 8, text-only is acceptable.

---

### Theme F: Milestone Celebration and Contextual Tip Coverage Gaps

**Player question answered:** "Is this going well? Did I do something noteworthy?"  
**Loop:** Short loop (positive feedback) + medium loop (progress acknowledgment)  
**Evidence:** `ContextualTipsViews.swift` (14 tips defined); `ContextualTipsManager.tipFor()` — no tips for positive milestones; `feature-inventory.md` row "Contextual tips" — "Phase 8 — tip coverage for victory/death"

**Gap analysis of existing tips vs. needed coverage:**

| Tip ID | Exists? | Covers? |
|--------|---------|---------|
| firstWater, firstToxic, firstMud, firstDamagingTerrain | Yes | Terrain first-contact — good coverage |
| firstReproductionReady, firstUnsafeReproductionBlocked | Yes | Reproduction mechanics — good |
| firstMutation | Yes | First mutation context — adequate |
| firstOffspringLoss | Yes | Negative milestone — good |
| firstLineageHandoff | Yes | Lineage transfer — good |
| massExtinctionBegins | Yes | Major threat — good |
| eraAdvance (4 tips) | Yes | All threat-framing; no opportunity framing — see Theme E |
| **First descendant survival (survived >N ticks)** | **Missing** | Positive milestone |
| **Victory goal: first progress** | **Missing** | First biome entered, first population growth, etc. |
| **Victory goal: halfway** | **Missing** | Retention + pacing signal |
| **Last organism alive (1 left)** | **Missing** | Tense warning — see Theme D |
| **Era approaching (fitness near threshold)** | **Missing** | Strategic preparation |
| **First generation handoff** | Partial (firstLineageHandoff) | Covers the concept; does not celebrate the milestone |
| **Forest/Swamp/Desert/Tundra/Mountain/Ice first entry** | **Missing** | Only water, toxic, mud covered in MVP set |

**Recommendations:**

1. **Add `.lastSurvivorWarning` tip.** Fire when `lineage.livingCount == 1` after having had more than 1. Copy: "Your last organism is alive. Survival now determines whether your lineage continues."

2. **Add `.biomesEraApproaching` tip.** Fire when fitness is within 100 of the era 4 threshold. Copy: "You're approaching the Biomes era — the full terrain set unlocks soon. Diversifying adaptations now will help."

3. **Add `.firstDescendantSurvived` tip.** Fire when an offspring survives for 100+ ticks after birth (track this via `totalBorn` delta + living count maintenance). Copy: "A descendant is thriving! Offspring that survive long enough can spread the lineage far."

4. **Add victory goal first-progress tips** (per goal):
   - `spreadToAllBiomes` + first new biome: "First new biome explored toward your goal. 1/6 — 5 more to spread."
   - `reachPopulation` + first population above 3: "Colony growing — 3 living organisms toward your goal of 12."
   - `evolveIntelligence` + generation 2: "Lineage reaching generation 2. Intelligence goal requires generation 5 + fitness 1200."
   - `surviveMassExtinction` + tick 1000: "Strong start. Mass extinction begins around tick 2000. Build population and traits now."

5. **Add terrain tips for the Biomes-era terrains** (forest, swamp, desert, tundra, mountain, ice) similar to the existing water/toxic/mud tips. These biomes are only accessible at era 4+, so tips should fire when the player enters them after the Biomes era transition.

**Tradeoffs:** Adding ~6–8 new contextual tips is well within the existing `ContextualTipsManager` pattern. Each is a `UserDefaults`-backed one-shot tip. The primary risk is tip overlap or queuing issues (multiple tips firing close together). The existing `eraAdvanceTipCoordinator` queue pattern should be extended to handle tip priority gracefully.

---

### Theme G: Inspector and HUD Comprehension Without Clutter

**Player question answered:** "What do these numbers mean? Am I doing well? What should I pay attention to?"  
**Loop:** Short loop (situational awareness) + medium loop (trait understanding) + long loop (goal tracking)  
**Evidence:** `InspectorPanelView.swift` (full read); `GameViewModel.swift` lines 53–63 (HUD state); `docs/beta/beta-readiness-matrix.md` row "Onboarding" gap

**What works well:**
- `BiomeCompatibilityRow` with expandable speed/energy/damage breakdown is excellent.
- `PressureRow` showing dominant pressure with highlight is a good idea, though it's buried below many other sections.
- Reproduction section explains the threshold, cost, and safe radius numerically.
- `TraitRow` shows percentage bars with description — clear and scannable.

**What is opaque:**
- **Fitness Score: 847** — no context. No era threshold reference. No goal threshold reference. Players do not know if 847 is good or bad without reading `SimulationTuning.swift`.
- **Victory Goal** appears only as a label in the Lineage section with no progress (see Theme B).
- **Evolutionary Pressure section** is at the bottom of a very long inspector list. New players are unlikely to scroll to it and understand its significance before their first mutation choice.
- **"Organism" section title** — showing just traits and generation. The concept of "your organism represents your lineage's current champion" is not reinforced here.
- **Living Descendants: `max(0, snapshot.lineage.livingCount - 1)`** — this subtraction (subtracting 1 for the player) is invisible to the player. They see "Living Descendants: 2" but "Living: 3." Why the difference? A tooltip or caption would help: "Living descendants (excluding the organism you control)."

**Recommendations:**

1. **Add goal progress to the inspector as a labeled row** (see Theme B — this theme reinforces it from the inspector angle).

2. **Add era threshold context to the Fitness Score row.** Change from:
   

```
   Fitness Score: 847
   

```
   to:
   

```
   Fitness Score: 847 (next era: 950)
   

```
   or use the existing caption text style to add `"Era 3 unlocks at 480 • Era 4 at 950"` below the fitness score value.

3. **Move or duplicate the Evolutionary Pressure section higher in the inspector.** Currently it is the last section. Placing it immediately after "Organism" (or creating a compact version in the Organism section) would help new players understand the mutation connection before their first choice fires.

4. **Clarify the Living vs. Living Descendants display.** Add a caption: "Descendants are the organisms your lineage has produced. You control one; the rest seek food and flee independently."

5. **Add a "What this means for your goal" caption under the Victory Goal row**, derived from `GameCopy.victoryGoalDescription`. The description is already rendered in the "Run Management" section (InspectorPanelView line 127) — this creates duplication. Consolidate into the Lineage section with goal progress.

**Tradeoffs:** Inspector reorganization (moving Evolutionary Pressure section) could conflict with the existing layout. Prefer additive changes (adding captions, expanding existing rows) over restructuring, which requires UI layout work from `/evolution-apple-platform-ui-specialist`. Copy-only changes (captions, era threshold context strings) can be done within `GameCopy.swift` by this agent.

---

### Theme H: Pacing Feel vs. Sim-Derived Targets

**Reference:** `pacing-targets.md`; `SimulationTuning.swift`

This theme is an **assessment of known pacing gaps**, not a recommendation to change Phase 7 balance constants. Any balance adjustments should be a separate handoff to `/evolution-simulation-gameplay-specialist`.

**First food (tick 2–51 on baseline seeds):** Seed 42 eats food at tick ~2, tutorial seed 1001 at tick ~51. This 50-tick spread means some seeds feel very different in the first 3 seconds (1.7 seconds real time). A player on a slow-food seed may not see any energy change and wonder if food is working. This is not a balance problem but a **feedback problem**: the energy bar should clearly show near-zero movement toward food even if the first food is 51 ticks away.

**Era transitions (tick 245–750 for first era):** These are fast by real-time standards (8–25 real seconds at 1× speed). Players in the tutorial or early standard runs may advance to Reef/Shallows before they understand Primordial Pool mechanics. The grace window (`primordialGraceTicks = 240`) partially mitigates this. But if a player is a fast learner (eats quickly, reproduces quickly), they could advance to era 2 while still in the tutorial. The tutorial's era-awareness is zero — there's no acknowledgment that "your fitness is growing" during the tutorial.

**Mass extinction (tick 2000):** At 1× speed, tick 2000 = ~66 real seconds. At common play speeds (2×–4×), this is 17–33 seconds. For the `surviveMassExtinction` goal, this is achievable but tight. Players on fast speed may not notice the world-tint shift. **PX recommendation:** Ensure the mass extinction tip banner is shown prominently (not easily dismissable) and the world-tint shift is visually obvious even at 4× speed. This is a graphics concern; coordinate with `/evolution-graphics-specialist`.

**Victory timing (tick 1200–3200):** First victory or loss happens at tick 1200–3200 depending on play style. At 1× speed, a typical loss at tick 1720 = ~57 real seconds. A full run including tutorial could take 5–10 minutes of real time at 2×. This is a reasonable session length for mobile but may feel short on macOS. The lack of goal progress feedback means the final 200–500 ticks before victory or loss often feel either unexpectedly sudden (victory) or frustratingly abrupt (loss). Building momentum in this window is a high-value PX improvement.

> ⚠️ **DOC INCONSISTENCY:** `pacing-targets.md` line 78 shows "First food eaten: tick 2 (seed 42)" but the note on line 86 says "Simulation runs at 30 ticks/second." At 30 ticks/second, tick 2 is 67 milliseconds after game start. The player cannot have moved or taken any meaningful action in 67ms. This suggests the first food on seed 42 is eaten by the **descendant AI**, not the player — unless the player happens to spawn on top of a food particle. This matters for first-food feedback design: the player's *own* first food may be significantly later than tick 2. Recommend verifying whether tick-2 food consumption is player-controlled or AI-controlled in headless test runs.

---

### Theme I: Platform-Specific Feel

**Player question answered:** "Does this game feel native and comfortable on my device?"  
**Loop:** All loops (usability prerequisite)  
**Evidence:** `docs/beta/risk-register.md` R4 (iPhone compact layout second-class); `docs/beta/beta-readiness-matrix.md` Platform row (Partial — iPhone/iPad smoke blank)  
**Agent boundary:** Implementation is primarily `/evolution-apple-platform-ui-specialist`; PX role is to identify what the player experience gap is.

**iPhone:** The inspector panel (`InspectorPanelView`) is designed for iPad/macOS with a side panel layout. On iPhone compact width, this likely becomes a modal or sheet. The depth of the inspector (10+ sections) may overwhelm a phone screen. For iPhone: **the goal progress row and "last survivor" warning are highest priority** — these need to be visible even if the full inspector is not open. A compact HUD chip showing goal progress (e.g., "2/6 biomes") on the main game view is the iPhone-appropriate solution.

**iPad:** The inspector side panel is appropriate. Goal progress and era threshold context add value without layout changes. The mutation card on iPad should show the dominant pressure line clearly.

**macOS:** Keyboard shortcuts for speed control (1×, 2×, 4×, 8× — presumably cmd+1 etc.) should be verified. The era transition and extinction screens should use appropriate macOS window sizing.

**Defer to `/evolution-apple-platform-ui-specialist`** for: compact HUD layout, iPhone control surfaces, iPad inspector panel integration, macOS keyboard shortcut verification, and any layout changes to existing views.

**PX deliverable for this theme:** Write copy, strings, and layout requirements for the compact HUD goal progress chip. Define what information must be visible on iPhone at all times during play (current organism energy bar, living count, current era, goal progress).

---

## 5. Phased Roadmap

### Phase A: First-Run Clarity (Beta Entry Criterion #1)

**Objective:** A new player can complete the tutorial, understand what their chosen victory goal means, and make a first meaningful mutation choice with survival context. Addresses beta entry criterion #1: "First-run flow explains movement, food, predators, terrain, reproduction, mutation, lineage handoff, and at least one victory goal."

**Scope — concrete changes:**

1. **Increase `firstMutationMinimumTick`** from 60 to 150 in `GameViewModel.swift` (or make it a `SimulationTuning` constant for testability).
2. **Verify or fix "ready badge" reference** in `TutorialViews.swift` step 5 message.
3. **Add dominant pressure display to the mutation modal.** Pass `snapshot.pressure.dominantPressureLabel` to the mutation choice view and display as a subtitle: "Recent pressure: [X]."
4. **Upgrade tutorial step 8 (Victory Goals) message** to include one concrete "what to do for this goal" hint per goal type:
   - Spread to All Biomes: "Move into new terrain types and adapt to them."
   - Reach Population: "Reproduce often and protect offspring from predators."
   - Evolve Intelligence: "Survive through multiple lineage generations — depth matters more than speed."
   - Survive Mass Extinction: "Build a colony strong enough to weather a predator surge."
5. **Add living descendant count to tutorial HUD** when the player reaches step 7 ("Lineage Continues"): a brief inline note showing "Descendants: 1."
6. **Update `HowToPlayView` "Eras & Progression" section** to include opportunity text (new biomes, new trait relevance per era) alongside the existing predator escalation text.

**Likely files:**
- `EvolutionSimGame/ViewModels/GameViewModel.swift` (line 93: `firstMutationMinimumTick`)
- `EvolutionSimGame/Views/TutorialViews.swift` (step 5 and step 8 messages)
- `EvolutionSimGame/Views/HowToPlayView.swift` (Eras & Progression section)
- `EvolutionSimGame/GameCopy.swift` (new helper functions for per-goal "what to do" text)
- Mutation choice view (path TBD — not visible in source scan above; likely in `EvolutionSimGame/Views/` or a `MutationChoiceView.swift`)

**Primary implementing agent:** `/evolution-player-experience-specialist` (copy, `GameCopy.swift` helpers, `firstMutationMinimumTick` constant change) + `/evolution-apple-platform-ui-specialist` (pressure display layout in mutation modal)

**Prerequisites:** Verify "ready badge" existence. Locate `MutationChoiceView.swift` or equivalent.

**Success criteria:**
- A new player completes the tutorial and enters new game setup knowing which goal they want to pursue and roughly what to do.
- First mutation choice fires at ≥150 ticks in standard play.
- The dominant pressure label is visible on the mutation modal.
- First-run smoke test passes: tutorial → goal selection → 5 minutes of play → first mutation understood.

**Verification:**
- Run first-run smoke script (see §7) on macOS and iPhone simulator.
- `cd EvolutionSimCore && swift test` to confirm no balance regression (no sim changes in this phase).
- Manual QA: check that mutation modal correctly shows dominant pressure on seeds 42 and 1001.

**Non-goals for this phase:** Victory goal progress HUD, era transition copy overhaul, extinction screen improvements, new contextual tips.

---

### Phase B: Goal Progress and Milestone Visibility

**Objective:** During a standard run, the player can always see how close they are to their victory goal and receive positive/negative milestone feedback at key moments.

**Scope — concrete changes:**

1. **Add `GoalProgressView` component to the inspector's Lineage section.** Shows formatted goal progress per victory goal type (see Theme B recommendations). Requires computing progress from `SimulationSnapshot` fields.
2. **Add era threshold context to Fitness Score display** in the inspector ("Next era: 950").
3. **Add `lastSurvivorWarning` contextual tip** to `ContextualTipsViews.swift` and trigger logic in `GameViewModel.updateContextualTips()`.
4. **Add `biomesEraApproaching` contextual tip** (fire at fitness ≥ 850, i.e., within 100 of era 4 threshold 950).
5. **Add `firstDescendantSurvived` contextual tip** (fire when an offspring survives 100+ ticks after birth).
6. **Add per-goal first-progress contextual tips** (`.spreadFirstBiome`, `.populationGrowing`, `.intelligenceGeneration2`, `.extinctionOnTrack`) — one-shot, fired once per run on first meaningful progress toward each goal.
7. **Add "living count changed" transient HUD indicator** — when `livingCount` decreases during play, show "Lineage: N → N−1" briefly via the existing `FeedbackBanner`.
8. **Add compact goal progress chip to the main HUD** (requires `/evolution-apple-platform-ui-specialist` for layout; PX defines content and thresholds).

**Likely files:**
- `EvolutionSimGame/Views/InspectorPanelView.swift` (new `GoalProgressView` component, fitness era context)
- `EvolutionSimGame/Views/ContextualTipsViews.swift` (new tip cases)
- `EvolutionSimGame/ViewModels/GameViewModel.swift` (new tip trigger logic in `updateContextualTips`)
- `EvolutionSimGame/GameCopy.swift` (new goal progress formatter, tip messages)
- `EvolutionSimGame/Views/ContentView.swift` or HUD view (living-count change indicator)

**Primary implementing agent:** `/evolution-player-experience-specialist` (copy, tip logic, inspector progress row logic) + `/evolution-apple-platform-ui-specialist` (compact HUD goal chip layout)

**Prerequisites:** Phase A complete. Confirm `SimulationSnapshot` exposes `fitness.biomesExplored`, `lineage.livingCount`, `playerOrganism.generation`, and `fitness.compositeScore` (these appear to be present based on `InspectorPanelView` source reads).

**Success criteria:**
- Inspector shows "2/6 biomes" or "5/12 organisms" clearly at any point in a run.
- "Last survivor" tip fires when lineage drops to 1.
- "Biomes era approaching" tip fires before era 4 transition on seed 3 (a biome-spread winner).
- `ContextualTipsTests` passes with new tip cases covered.

**Verification:**
- `cd EvolutionSimCore && swift test` (no balance change expected).
- Run `EvolutionSimGameTests` — add tests for new tip trigger conditions.
- First-run smoke: play to era 3 on seed 42 and verify goal progress is visible.
- Manual: play to `spreadToAllBiomes` win on seed 3 and verify progress milestones fire.

**Non-goals:** Era transition copy overhaul (Phase C), extinction screen (Phase C), iPhone compact layout deep work (Phase D).

---

### Phase C: Failure Teaches + Era Chapter Moments

**Objective:** When the player fails or transitions eras, they receive meaningful narrative context, a clear cause or opportunity framing, and an actionable path forward.

**Scope — concrete changes:**

1. **Upgrade `GameCopy.extinctionMessage`** to accept era, goal progress, and era-context data. Produce a 3–4 sentence recap:
   - Era reached
   - Goal progress
   - Era-appropriate "likely challenge" framing
   - One concrete "try next time" suggestion
2. **Add "Try Again" and "New Seed, Same Goal" affordances to the extinction/game-over screen.** These are UI flow changes — define the buttons and copy here; layout is `/evolution-apple-platform-ui-specialist`.
3. **Restructure all four era advance tip messages** in `GameCopy.eraAdvanceTipMessage` to include opportunity + threat framing (see Theme E recommendations).
4. **Add Biomes era celebration:** extend the era 4 tip to be a larger "chapter unlock" card or expanded message that specifically calls out the six new terrain types unlocking.
5. **Add terrain first-contact tips for Biomes-era terrains**: `.firstForest`, `.firstSwamp`, `.firstDesert`, `.firstTundra`, `.firstMountain`, `.firstIce` — similar to existing `.firstWater`, `.firstToxic`, `.firstMud`. Fire only when the Biomes era is active (era 4+).
6. **Add `GameCopy.victoryMessage`** static function for the victory screen (analogous to `extinctionMessage`). Include era reached, total generations, biomes explored, and a congratulatory framing specific to the goal type.
7. **Add `GameCopy.goalApproachingMessage`** for the "80% to victory" contextual tips.

**Likely files:**
- `EvolutionSimGame/GameCopy.swift` (extinctionMessage expansion, victoryMessage, era tip rewrites, Biomes-era terrain tips)
- `EvolutionSimGame/Views/ContextualTipsViews.swift` (new terrain tip cases)
- `EvolutionSimGame/ViewModels/GameViewModel.swift` (new tip trigger logic for Biomes-era terrain, new tip trigger for "approaching victory")
- Game-over / victory presentation view (path TBD)

**Primary implementing agent:** `/evolution-player-experience-specialist` (copy, logic) + `/evolution-apple-platform-ui-specialist` (extinction screen layout, Try Again flow)

**Prerequisites:** Phase B complete. Locate the victory/game-over presentation view (not confirmed in source scan — may be a sheet in `ContentView.swift` driven by `snapshot.phase == .extinct || .victory`).

> ⚠️ **DOC INCONSISTENCY:** The `feature-inventory.md` row for "Contextual tips" notes "Phase 8 — tip coverage for victory/death" as the gap. However, the victory screen view itself is not listed in the player-facing file list in the mission brief, and `GameViewModel.snapshot.phase == .victory` is referenced but no `VictoryView` or equivalent is surfaced in `EvolutionSimGame/Views/`. This view should be located and read before Phase C implementation to understand the current state of victory presentation. This is a verification prerequisite, not a blocking concern.

**Success criteria:**
- Extinction screen for seed 42 early loss shows era reached, goal progress, and a suggested strategy in ≤4 sentences.
- Era 4 (Biomes) tip mentions new terrain types by name.
- "Try Again" button on extinction screen starts a new run with the same goal and seed.
- Forest/swamp/desert/tundra terrain first-contact tips fire when playing on a Biomes-era seed with appropriate terrain entry.

**Verification:**
- Run seed 3 to era 4 manually; confirm Biomes era tip is expanded.
- Run seed 7 to extinction; confirm extinction message shows era, goal, and suggestion.
- `cd EvolutionSimCore && swift test` (no balance change).
- Add `ContextualTipsTests` coverage for Biomes-era terrain tips.

**Non-goals:** Platform-specific HUD work, performance, accessibility.

---

### Phase D: Platform Feel + Inspector Polish

**Objective:** The game feels native and readable on all three platforms; the inspector is reorganized for comprehension flow; iPhone compact HUD shows essential live information.

**Scope — concrete changes:**

1. **Reorganize `InspectorPanelView`** section order:
   - Organism (energy, health, age, generation, offspring — as now)
   - **[New] Goal Progress** (moved from Lineage bottom to near-top)
   - Evolutionary Pressure (moved up — key context for mutation)
   - Traits
   - Biome Compatibility
   - Lineage (living count, era, fitness with era threshold)
   - Reproduction
   - Save & Run
   - Run Management
   - Debug Overlays (hidden unless `showDebugOverlays`)
2. **Compact iPhone HUD chip** showing goal progress, living count, era, energy/health at a glance (layout by `/evolution-apple-platform-ui-specialist`; content defined in this phase).
3. **macOS keyboard shortcut verification:** speed controls, pause, inspector toggle — confirm all mapped and functional.
4. **iPad inspector polish:** verify all new rows from Phases A–C render correctly in the side panel layout.
5. **"Living Descendants" display clarification** (caption: "not counting the organism you control").

**Likely files:**
- `EvolutionSimGame/Views/InspectorPanelView.swift` (section reorder, captions)
- `EvolutionSimGame/Views/ContentView.swift` (iPhone HUD chip placement)
- macOS keyboard shortcut configuration (TBD file)

**Primary implementing agent:** `/evolution-apple-platform-ui-specialist` (layout, platform-specific), with copy and content requirements from `/evolution-player-experience-specialist`

**Prerequisites:** Phases A–C complete (all new content must exist before reorganization).

**Success criteria:**
- On iPhone (Air sim), a player can see current era, goal progress, and living count without opening the inspector.
- On iPad, inspector side panel shows goal progress near the top and evolutionary pressure before traits.
- On macOS, speed control shortcuts and pause shortcut are functional.

**Verification:**
- Multi-platform smoke: iPhone simulator, iPad simulator, macOS.
- First-run smoke on iPhone and iPad using the Phase A smoke script.

**Non-goals:** Accessibility (Phase 10), performance (Phase 11), 3D graphics (post-beta).

---

### Phase E: Replayability and Post-Run Experience

**Objective:** After a win or loss, the player is motivated to start another run with a clear next goal and minimal friction.

**Scope — concrete changes:**

1. **"Try Again" and "New Seed, Same Goal" shortcuts from extinction/victory screens** (copy and flow defined in Phase C; layout confirmed in this phase).
2. **Seed share text improvement.** Current: "EvolutionSimGame seed: 42." Proposed: "EvolutionSimGame seed 42 — Era 3, Biomes goal — try to beat my score!" Include run summary in the share text.
3. **Start screen "New Game" flow**: after extinction/victory, offer a quick-start path that pre-selects the same goal, allowing one-tap restart without re-navigating setup. This is a flow change.
4. **"Previous run summary" on start screen** when a `savedRunSummary` is available: show era reached, goal progress, and seed alongside the Continue subtitle. (The Continue subtitle currently shows "Seed 42 • Tick 1240 • Playing • Spread to All Biomes" — add era and goal progress.)
5. **Suggest a different seed based on victory goal.** On the new game setup screen, add a "Recommended starter seeds for [goal]" hint using the Phase 7 seed suite data from `pacing-targets.md`.

**Likely files:**
- `EvolutionSimGame/Views/StartScreenView.swift` (Continue subtitle, post-run flow)
- `EvolutionSimGame/Views/NewGameSetupView.swift` (seed recommendation copy)
- `EvolutionSimGame/GameCopy.swift` (share text, seed hints)
- `EvolutionSimGame/ViewModels/GameViewModel.swift` (post-run navigation flow)

**Primary implementing agent:** `/evolution-player-experience-specialist` (copy, flow design) + `/evolution-apple-platform-ui-specialist` (flow implementation)

**Prerequisites:** Phase C (extinction/victory screen content exists).

**Success criteria:**
- After extinction on seed 42, player can tap "Try Again" to start a new run with same seed and goal in ≤2 taps.
- New game setup shows "Good seeds for Spread to All Biomes: 3, 5, 6, 9, 11" (or equivalent friendly copy).
- Share seed text includes run summary.

**Verification:**
- Manual flow test: extinction → try again → playing in ≤2 taps on all three platforms.
- Seed recommendation text verified against `pacing-targets.md` seed suite.

**Non-goals:** Cloud save, social features, analytics.

---

## 6. Quick Wins vs. Strategic Bets

### Quick Wins (≤1–2 days each, high ROI, low regression risk)

| # | Change | Files | Agent | Effort | Impact |
|---|--------|-------|-------|--------|--------|
| QW1 | Increase `firstMutationMinimumTick` from 60 to 150 | `GameViewModel.swift` line 93 | PX or UI specialist | 30 min | High — first mutation lands with context |
| QW2 | Add dominant pressure label to mutation modal (copy + pass-through) | `GameCopy.swift`, mutation view | PX + UI specialist | 1 day | High — teaches core feedback loop |
| QW3 | Fix/verify "ready badge" reference in tutorial step 5 | `TutorialViews.swift` line 40 | PX | 1 hour | Medium — removes confusion |
| QW4 | Upgrade tutorial step 8 (Victory Goals) copy per goal | `TutorialViews.swift`, `GameCopy.swift` | PX | 2 hours | High — connects tutorial to first run goal |
| QW5 | Add era threshold context to Fitness Score in inspector | `InspectorPanelView.swift` | PX or UI specialist | 1 hour | Medium — makes fitness legible |
| QW6 | Add `lastSurvivorWarning` contextual tip | `ContextualTipsViews.swift`, `GameViewModel.swift` | PX | 2 hours | High — tense milestone, prevents surprise extinction |
| QW7 | Add "Living Descendants" clarification caption in inspector | `InspectorPanelView.swift` | PX | 30 min | Low — reduces confusion |
| QW8 | Upgrade extinction message to include era and goal progress | `GameCopy.swift` | PX | 2 hours | High — transforms failure from dead end to learning moment |
| QW9 | Rewrite era advance tip messages (opportunity + threat) | `GameCopy.swift` lines 21–41 | PX | 2 hours | High — era transitions feel like story beats |
| QW10 | Add "Biomes era approaching" tip (fitness >850) | `ContextualTipsViews.swift`, `GameViewModel.swift` | PX | 2 hours | Medium — strategic preparation window |

**Total estimated effort for all quick wins: ~3–4 days.**  
All quick wins are copy/logic changes with no simulation balance impact. They can be shipped as a single PR ahead of Phase A implementation work.

---

### Strategic Bets (multi-session, cross-specialist, higher risk/reward)

| # | Change | Why strategic | Cross-specialist dependencies | Risk |
|---|--------|---------------|-------------------------------|------|
| SB1 | **Victory goal progress row in inspector + compact HUD chip for iPhone** | Highest single impact on long-loop motivation; requires layout work on 3 platforms | `/evolution-apple-platform-ui-specialist` for layout | Medium — inspector reorganization can break layout |
| SB2 | **"Try Again" and "New Seed, Same Goal" post-extinction/victory shortcuts** | Core replayability change; requires new app flow states | `/evolution-apple-platform-ui-specialist` for flow; `GameViewModel.swift` navigation changes | Medium — app phase logic change |
| SB3 | **Biomes era "chapter card" — expanded tip with terrain unlock names** | Makes era 4 feel like a midgame pivot; could become a mini-cinematic | `/evolution-graphics-specialist` for visual treatment; PX for copy | Low (copy only) to High (if animated) |
| SB4 | **Per-goal first-progress contextual tips (5 new tips)** | Converts goal selection into an active tracking experience | None — PX can own fully | Low — additive tip cases |
| SB5 | **Mutation modal dominant pressure + scenario framing** | Teaches the core game mechanic directly in the choice moment; layout-sensitive | `/evolution-apple-platform-ui-specialist` for layout in modal | Low — copy + pass-through change |
| SB6 | **Seed recommendation on new game setup screen** | Direct use of Phase 7 seed suite data; helps new players find winnable starts | None — PX can own copy; UI specialist for layout | Low |
| SB7 | **`victoryMessage` for victory screen with run recap** | Victory currently has unknown/thin presentation; could include "you survived X eras, adapted Y times" | Locate and verify victory screen view first | Medium — unknown view state |
| SB8 | **"Last organism alive" tense warning + descendant death counter** | Transforms silent extinction countdown into a tense game moment | UI specialist for HUD indicator | Low — additive tip + counter |

---

## 7. Metrics and Evidence Plan

### Verifiable Signals (Pairing Claims with Evidence)

| Claim | Verifiable Signal | How to Measure |
|-------|-----------------|----------------|
| First mutation fires later (≥150 ticks) | Sim tick count when mutation modal presents | Headless test: count `deferredMutationPresentationTicks` ticks on seeds 42 and 1001 |
| Goal progress is visible in inspector | Inspector renders `GoalProgressView` with correct values | Manual QA on seed 3 (biome spread), seed 8 (population) |
| Era transition tips are longer and include opportunity text | `GameCopy.eraAdvanceTipMessage` returns multi-sentence string | Unit test: assert string length > 80 chars and contains biome name for era 4 |
| Extinction message includes era and goal progress | `GameCopy.extinctionMessage` returns era + progress | Unit test with mock snapshot (era 3, 2/6 biomes) |
| `lastSurvivorWarning` tip fires at livingCount == 1 | `ContextualTipsTests` coverage | Add test case |
| No balance regression from `firstMutationMinimumTick` change | All 61 core tests + 21 app tests pass | `cd EvolutionSimCore && swift test && xcodebuild test` |
| Tutorial completion improved by step 8 copy upgrade | First-run smoke: tester can name their chosen goal after tutorial | Manual QA checklist item |
| "What to do for this goal" copy is accurate vs. pacing data | Compare goal hints to `pacing-targets.md` verified seed paths | Cross-reference review |

### Minimal First-Run Smoke Script

This script is designed for manual execution by `/evolution-verifier` or `/evolution-apple-platform-ui-specialist` on macOS, iPad, and iPhone simulators. Target duration: ~10 minutes per platform.

---

**First-Run Smoke Script v1.0**  
Platform: macOS (primary), then iPad (A16 sim), then iPhone Air sim  
Seed: 1001 (tutorial preset)  
Speed: 1×  

**Step 1 — Launch**  
[ ] App launches to start screen  
[ ] "Start Tutorial" button is prominent  
[ ] "New Game" and "How to Play" buttons visible  
[ ] No saved run present (first launch) → "Continue" button absent  

**Step 2 — Tutorial: Move**  
[ ] Tap "Start Tutorial"  
[ ] Tutorial callout appears: "Move Your Organism" step 1/8  
[ ] Move organism >25 units from start  
[ ] Step auto-advances to "Gather Energy"  
[ ] No mutation modal has appeared yet  

**Step 3 — Tutorial: Eat Food**  
[ ] Move toward green food particles  
[ ] Energy bar visibly increases when food is eaten  
[ ] Step auto-completes  

**Step 4 — Tutorial: Avoid Predators**  
[ ] Step 3/8 "Avoid Predators" appears with Continue button  
[ ] At least one red predator is visible on screen  
[ ] Player can dismiss with Continue  

**Step 5 — Tutorial: Terrain**  
[ ] Step 4/8 "Explore Terrain" appears  
[ ] Move into non-land terrain region  
[ ] Biome chip in HUD updates  
[ ] Step auto-completes  

**Step 6 — Tutorial: Reproduce**  
[ ] Step 5/8 "Reproduce" message visible  
[ ] **CHECK:** Does the "ready badge" mentioned in step 5 text actually appear in the HUD? YES / NO / UNCLEAR  
[ ] Wait for reproduction: `totalBorn > 0` or mutation modal awaited  
[ ] Step auto-completes (no mutation modal yet)  

**Step 7 — Tutorial: Choose Mutation**  
[ ] Step 6/8 "Choose an Adaptation" appears  
[ ] Mutation modal appears with 3 options  
[ ] **CHECK:** Is dominant pressure label visible on the modal? YES / NO (Phase A requirement)  
[ ] Each option shows stat changes and biome impact  
[ ] Select a mutation  
[ ] Green feedback banner: "Offspring adapted: [X]"  
[ ] Step auto-completes  

**Step 8 — Tutorial: Lineage Handoff**  
[ ] Step 7/8 "Lineage Continues" message appears  
[ ] Continue button visible  
[ ] **CHECK:** Is living descendant count visible anywhere? YES / NO (Phase A requirement)  
[ ] Tap Continue  

**Step 9 — Tutorial: Victory Goals**  
[ ] Step 8/8 "Victory Goals" appears  
[ ] All four goal names visible in message  
[ ] **CHECK (Phase A):** Does each goal have a "what to do" hint? YES / NO  
[ ] Tap Continue  

**Step 10 — New Game Setup**  
[ ] New game setup screen appears  
[ ] Victory goal picker shows selected goal  
[ ] Victory goal description visible below picker  
[ ] Seed stepper and random seed toggle present  
[ ] Mass extinction toggle and explanation present  
[ ] **CHECK (Phase E):** Are seed recommendations visible for the selected goal? YES / NO  
[ ] Tap "Start Game"  

**Step 11 — Standard Play: First 3 Minutes**  
[ ] Organism spawns, moves  
[ ] **CHECK:** Mutation modal does NOT appear immediately (≤5 seconds at 1×) without prior movement  
[ ] First contextual tip fires on first non-land terrain entry  
[ ] Inspector opens: goal, fitness, era, evolutionary pressure visible  
[ ] **CHECK (Phase B):** Goal progress row shows current count vs. target? YES / NO  
[ ] **CHECK (Phase B):** Fitness row shows "Next era: [X]"? YES / NO  

**Step 12 — First Mutation (Standard Play)**  
[ ] Mutation modal eventually fires (after ≥150 ticks / ≥5 real seconds at 1×)  
[ ] **CHECK (Phase A):** Dominant pressure label visible? YES / NO  
[ ] Select mutation  
[ ] Feedback banner appears  

**Step 13 — Era Transition (if reached)**  
[ ] Era advance tip appears  
[ ] **CHECK (Phase C):** Tip includes opportunity text, not just threat? YES / NO  
[ ] Inspector era label updates  
[ ] **CHECK (Phase B):** "Next era:" in fitness row updates? YES / NO  

**Step 14 — Extinction (if reached)**  
[ ] Extinction message appears  
[ ] **CHECK (Phase C):** Includes era reached, goal progress, and suggested strategy? YES / NO  
[ ] **CHECK (Phase E):** "Try Again" button visible? YES / NO  
[ ] Return to start screen  

**Pass criteria:** All [ ] checked, all Phase A/B/C/E items YES for their respective phase gates.

---

### Seeded Milestone Timing Checks

For regression protection, verify the following against `pacing-targets.md` after any PX phase implementation:

| Check | Seed | Expected | Tolerance |
|-------|------|----------|-----------|
| First mutation modal (standard play) | 42 | ≥150 ticks | ±10 ticks |
| First era transition | 42 | ~tick 382 | ±50 ticks |
| First era transition | 1001 | ~tick 245–261 | ±30 ticks |
| Mass extinction fires | 42 | tick 2000 | ±0 ticks (deterministic) |
| Victory (biome spread) | 3 | <tick 6000 | N/A (just must complete) |

---

## 8. Handoff Package

### Task Stubs for Implementing Agents

---

```
## Task: Increase firstMutationMinimumTick to 150 and add SimulationTuning constant
Agent: /evolution-player-experience-specialist (with review by /evolution-simulation-gameplay-specialist)
Priority: P1
Phase: A
Files: EvolutionSimGame/ViewModels/GameViewModel.swift (line 93),
       EvolutionSimCore/Sources/EvolutionSimCore/Simulation/SimulationTuning.swift (new constant)
Input: Current value is 60 (line 93 GameViewModel). Per pacing-targets.md lines 85-92,
       this is an intentional Phase 8 onboarding task. The change is UI-side only; sim ticks
       continue advancing during deferral via stepDuringDeferredMutationPresentation.
       New value of 150 = 5 real seconds at 1x speed (30 ticks/sec).
       Consider making it a SimulationTuning constant for testability.
Output: firstMutationMinimumTick = 150. Mutation modal in standard play fires after ≥150
        timer callbacks. All 61 core + 21 app tests pass.
Success check: Run seed 42 standard play; confirm mutation modal does not appear within 5 seconds.
               swift test passes. EvolutionSimGameTests passes.
```

---

```
## Task: Add dominant evolutionary pressure label to mutation choice modal
Agent: /evolution-apple-platform-ui-specialist
Priority: P1
Phase: A
Files: Mutation choice view (locate — likely EvolutionSimGame/Views/ — not found in source scan),
       EvolutionSimGame/GameCopy.swift (add helper if needed),
       EvolutionSimGame/ViewModels/GameViewModel.swift (confirm pressure passed to view)
Input: snapshot.pressure.dominantPressureLabel is computed in EvolutionSimCore.
       The mutation choice modal is triggered when shouldPresentMutationChoice is true (GameViewModel
       line 110). The view needs the dominant pressure label passed through.
       Desired display: a subtitle line in the modal header — "Recent pressure: Predator encounters"
       or "Recent pressure: Water exposure." Keep compact for iPhone modal.
       The inspector already shows this data; this surfaces it at the decision moment.
Output: Mutation modal displays dominant pressure label. All platform builds pass.
        Label updates correctly across multiple reproduction events in the same run.
Success check: Play seed 42 standard run; mutation modal shows non-empty pressure label.
               Verify on iPhone (compact), iPad (side panel), macOS.
```

---

```
## Task: Verify "ready badge" in tutorial step 5 and fix message if badge doesn't exist
Agent: /evolution-player-experience-specialist
Priority: P1
Phase: A
Files: EvolutionSimGame/Views/TutorialViews.swift (line 40: "Watch for the ready badge"),
       EvolutionSimGame/Views/ContentView.swift or canvas views (search for reproduction ready badge UI)
Input: TutorialViews.swift step .reproduce message (line 40) says "Watch for the ready badge."
       Source scan of InspectorPanelView and GameViewModel does not confirm a HUD badge element.
       Task: (1) Search EvolutionSimGame for "ready badge" or reproduction-ready HUD element.
       (2) If it exists: document it in player-guide.md. (3) If it does not exist: update tutorial
       step 5 message to describe what the player can actually observe (inspector status row
       "Automatic when play resumes" or the HUD biome chip). Do not create the badge — fix the copy.
Output: Tutorial step 5 message accurately describes an observable UI element.
        Player-guide.md updated if badge exists.
Success check: First-run smoke step 6 — "ready badge" question answered YES (if badge) or CLEARED (if copy fixed).
```

---

```
## Task: Upgrade tutorial step 8 (Victory Goals) copy to include per-goal action hints
Agent: /evolution-player-experience-specialist
Priority: P1
Phase: A
Files: EvolutionSimGame/Views/TutorialViews.swift (step .victoryGoals message, line 46-47),
       EvolutionSimGame/GameCopy.swift (add victoryGoalActionHint(_:) helper)
Input: Current step 8 message lists goal names and mentions seed 1001 preset. It does not tell
       the player what to do for any goal. Add a GameCopy.victoryGoalActionHint helper that returns
       a 1-sentence "what to do" per goal:
       - spreadToAllBiomes: "Move into new terrain types; each adapts your lineage differently."
       - reachPopulation: "Reproduce often and protect offspring from predators and hazards."
       - evolveIntelligence: "Survive across many lineage generations; depth matters more than speed."
       - surviveMassExtinction: "Build a colony strong enough to survive a predator surge at tick 2000."
       Update TutorialViews step 8 message to show the hint for the tutorial preset goal.
       (Tutorial uses populationGoal preset from SimulationConfig.tutorialPreset().)
Output: Step 8 tutorial message includes per-goal action hint for population goal.
        victoryGoalActionHint() callable from NewGameSetupView in Phase A follow-up.
Success check: First-run smoke step 9 — tester can articulate what to do for their chosen goal after tutorial.
```

---

```
## Task: Add GoalProgressView component to InspectorPanelView Lineage section
Agent: /evolution-apple-platform-ui-specialist
Priority: P1
Phase: B
Files: EvolutionSimGame/Views/InspectorPanelView.swift,
       EvolutionSimGame/GameCopy.swift (add goalProgressString(_:snapshot:) helper)
Input: PX-defined content:
  - spreadToAllBiomes: "Biomes: N of 6 explored" + ProgressView(value: Double(count)/6.0)
  - reachPopulation: "Population: N of 12 living" + ProgressView(value: Double(living)/12.0)
  - evolveIntelligence: "Generation: N of 5 • Fitness: X / 1200"
    Two ProgressViews or a compound display
  - surviveMassExtinction: if massExtinctionActive → "Tick: X / 3000"; else "Mass extinction
    begins ~tick 2000. Build colony now."
  Source values: snapshot.fitness.biomesExplored.count, snapshot.lineage.livingCount,
  snapshot.playerOrganism?.generation, snapshot.fitness.compositeScore, snapshot.massExtinctionActive,
  snapshot.currentTick (verify field name).
  Place as first row in the Lineage section (before Living/Total Born rows).
  Match existing CompatibilityBar visual style.
Output: Inspector Lineage section shows formatted goal progress.
        Verified correct on macOS and iPad; iPhone review deferred to Phase D.
Success check: Play seed 3 to biome spread; inspector shows "Biomes: 3 of 6 explored" at correct count.
               Play seed 8 to population; inspector shows "Population: 7 of 12 living" during run.
```

---

```
## Task: Add lastSurvivorWarning, biomesEraApproaching, and firstDescendantSurvived contextual tips
Agent: /evolution-player-experience-specialist
Priority: P2
Phase: B
Files: EvolutionSimGame/Views/ContextualTipsViews.swift (new ContextualTip cases),
       EvolutionSimGame/ViewModels/GameViewModel.swift (updateContextualTips trigger logic),
       EvolutionSimGame/GameCopy.swift (tip message strings)
Input: Three new tips:
  1. .lastSurvivorWarning — fire when lineage.livingCount == 1 AND previousLivingCount > 1.
     Message: "Your last organism is alive. Survive to keep your lineage going."
  2. .biomesEraApproaching — fire when fitness.compositeScore >= 850 (within 100 of era4 threshold 950)
     and era is currently .landfall or earlier. One-shot.
     Message: "The Biomes era is approaching — the full terrain set unlocks soon. Diversifying traits now will help."
  3. .firstDescendantSurvived — fire when an offspring that was born N ticks ago is still alive (N >= 100).
     Requires tracking: store birth tick of living descendants or check age in snapshot.
     (If descendant age is not in SimulationSnapshot, simplify: fire when totalBorn > 1 AND
     livingCount >= 2 AND tip not yet shown.) Message: "A descendant is surviving! Healthy offspring
     spread the lineage and contribute to population goals."
Output: Three new ContextualTip cases. trigger logic in updateContextualTips. ContextualTipsTests
        updated with coverage for each new tip. All app tests pass.
Success check: Play seed 42; lineage drops to 1 → lastSurvivorWarning fires.
               Play seed 42 to fitness 860 → biomesEraApproaching fires.
               ContextualTipsTests green.
```

---

```
## Task: Expand extinctionMessage and add per-goal summary to GameCopy
Agent: /evolution-player-experience-specialist
Priority: P1
Phase: C
Files: EvolutionSimGame/GameCopy.swift (extinctionMessage signature expansion + implementation),
       Game-over / extinction presentation view (locate first)
Input: Current extinctionMessage(totalBorn:generation:) is 2-line static. Expand signature to:
  extinctionMessage(totalBorn: Int, generation: Int, era: GameEra, goalProgress: String,
                    suggestedStrategy: String) -> String
  Derive goalProgress string from a new goalProgressString(_:snapshot:) helper (shared with inspector,
  see GoalProgressView task). suggestedStrategy: one sentence derived from era + (optionally) goal type.
  Era-based strategy hints:
  - .primordialPool: "In the Primordial era, energy management is key — eat before you reproduce."
  - .reefShallows: "Reef predators are faster. Prioritize Enhanced Senses or Armor in early mutations."
  - .landfall: "Landfall brings terrain variety. Reproduce on land terrain to avoid hazard-site blocking."
  - .biomes: "The Biomes era spans many terrain types. A lineage adapted to water AND land survives longer."
  - .ecosystemDominance: "Ecosystem Dominance requires a large colony. Population and Herd Instinct help survive the predator peak."
  Output format: "You reached [era]. [Goal progress]. [Strategy hint]. Start a new run — [seed recommendation]."
Output: extinctionMessage returns 3-4 sentence recap. Callers updated. All tests pass.
Success check: Unit test: extinctionMessage(totalBorn:5, generation:2, era:.reefShallows,
               goalProgress:"2 of 6 biomes", suggestedStrategy:"...") returns string containing
               "Reef" and "2 of 6 biomes".
```

---

```
## Task: Rewrite era advance tip messages with opportunity + threat framing
Agent: /evolution-player-experience-specialist
Priority: P2
Phase: C
Files: EvolutionSimGame/GameCopy.swift (eraAdvanceTipMessage lines 21-41),
       EvolutionSimCore/Sources/EvolutionSimCore/EraContent.swift (verify era descriptions)
Input: All four era advance tip messages currently focus exclusively on predator escalation.
  Rewrite each to include: (1) what the player earned, (2) what is new/unlocked, (3) what to watch for.
  Target length: 2-3 sentences per tip (current: 1 sentence).
  Biomes era must mention: "forest, swamp, desert, tundra, mountain, and ice terrain types are now active."
  Verify that EraContent.eraDescription() is consistent with new messages; update if inconsistent.
  The ContextualTipBanner layout (HStack, caption font) may need review for 3-sentence messages —
  flag if layout coordination is needed for /evolution-apple-platform-ui-specialist.
Output: Four rewritten era tip messages. ContextualTipsTests updated to assert non-trivial content.
        EraContent.eraDescription updated if inconsistent.
Success check: Play seed 42 past first era transition; verify new Reef tip message includes both
               opportunity and threat text. Manual QA passes.
```

---

```
## Task: Add Biomes-era terrain first-contact contextual tips (forest, swamp, desert, tundra, mountain, ice)
Agent: /evolution-player-experience-specialist
Priority: P2
Phase: C
Files: EvolutionSimGame/Views/ContextualTipsViews.swift (6 new tip cases),
       EvolutionSimGame/ViewModels/GameViewModel.swift (tipFor: extend switch for new terrains),
       EvolutionSimGame/GameCopy.swift (tip messages, can use TerrainSystem.playerFacingSummary pattern)
Input: Existing pattern: .firstWater, .firstToxic, .firstMud trigger on first entry to those terrain types.
  Add equivalent for: .firstForest, .firstSwamp, .firstDesert, .firstTundra, .firstMountain, .firstIce.
  These terrains only appear in era 4+ (Biomes). Tips should mention the key trait that helps in that terrain
  (from player-guide.md terrain table) in one sentence:
  - Forest: "Dense terrain — Enhanced Senses detect food and predators faster here."
  - Swamp: "High-cost mixed terrain — Swim Efficiency helps cross reliably."
  - Desert: "Harsh energy drain. A high-Metabolism organism struggles here; lower Metabolism helps."
  - Tundra: "Cold terrain with slow damage. Lower Metabolism and Armor help."
  - Mountain: "Energy-expensive climb. Smaller organisms cross with less penalty."
  - Ice: "Slippery and damaging. Armor reduces ice damage over time."
  Fire condition: era is .biomes or .ecosystemDominance AND player enters the terrain for the first time.
Output: 6 new tip cases. ContextualTipsTests coverage for at least 2 new terrain tips. All tests pass.
Success check: Play seed 3 to Biomes era; enter forest — firstForest tip fires. Enter desert — firstDesert fires.
```

---

```
## Task: Add GoalProgress-aware "Try Again" shortcut to extinction and victory presentation
Agent: /evolution-apple-platform-ui-specialist
Priority: P2
Phase: C / E
Files: Extinction/victory presentation view (locate — GameViewModel triggers
       snapshot.phase == .extinct / .victory),
       EvolutionSimGame/ViewModels/GameViewModel.swift (new confirmTryAgain() action),
       EvolutionSimGame/Views/StartScreenView.swift (post-run flow)
Input: PX-defined requirements:
  Extinction screen must offer:
  1. "Try Again" — start new run with same seed and same victory goal. Calls
     viewModel.startGame(config: SimulationConfig(seed: currentSeed, victoryGoal: currentGoal...)).
  2. "New Seed, Same Goal" — go to NewGameSetupView with goal pre-selected, seed randomized.
  3. "Start Screen" — existing return path.
  Victory screen must offer:
  1. "New Run" — go to NewGameSetupView.
  2. "Start Screen".
  Share text should include run summary (see Phase E seed share task).
  Both screens must show: era reached, goal result (achieved / progress), seed used.
Output: Extinction and victory screens have Try Again and New Seed buttons.
        All three platforms render correctly.
        App state is consistent after "Try Again" (same as startGame flow).
Success check: Play seed 42 to extinction; tap "Try Again" → new run starts with seed 42, same goal.
               All platform builds pass. No navigation state corruption.
```

---

```
## Task: First-run smoke script execution (Phase A gate)
Agent: /evolution-verifier
Priority: P1
Phase: A (verification gate)
Files: This plan document (§7 smoke script), built app targets
Input: Execute the First-Run Smoke Script v1.0 (Section 7 of this plan) on:
  1. macOS (EvolutionSimGame_macOS)
  2. iPad A16 simulator (EvolutionSimGame_iOS)
  3. iPhone Air simulator (EvolutionSimGame_iOS compact)
  For Phase A: verify checkboxes marked [CHECK (Phase A)] in script.
  Use seed 1001 (tutorial preset) for all platform runs.
  Report: platform, pass/fail per step, screenshots of mutation modal (with/without pressure label),
  tutorial step 8 display, and extinction message if reached.
Output: Smoke report with YES/NO for each Phase A check item. List of any regressions or layout issues.
Success check: All Phase A check items return YES on macOS. At least NO unexpected crashes on iPad/iPhone.
```

---

*End of Handoff Package.*

---

## Appendix: Source Cross-Reference

All claims in this plan are grounded in the following sources. References are to the versions read on 2026-06-27.

| Source | Key sections used |
|--------|------------------|
| `AGENTS.md` | Reward loop framing (§ Player Experience And Reward Guidance), architectural invariants |
| `README.md` | Core loop summary, Phase 9 save/continue confirmation |
| `docs/player-guide.md` | Reproduction mechanics, terrain table, era names, victory goals, future features list |
| `docs/game-design.md` | Distinguishing aspirational vs. shipped systems |
| `docs/beta/pacing-targets.md` | Tick-0 mutation issue, milestone timing, Phase 7 tuning rationale |
| `docs/beta/public-beta-scope.md` | Beta entry criterion #1 (first-run clarity), partial-status table |
| `docs/beta/feature-inventory.md` | Phase 8 gap inventory, contextual tip coverage, tutorial/victory missing items |
| `docs/beta/risk-register.md` | R4 (iPhone layout), R8 (tutorial/victory), R11 (era surprise) |
| `docs/beta/beta-readiness-matrix.md` | Onboarding partial status |
| `EvolutionSimGame/GameCopy.swift` | All player-facing copy strings |
| `EvolutionSimGame/Views/TutorialViews.swift` | Tutorial steps, completion conditions, "ready badge" reference |
| `EvolutionSimGame/Views/ContextualTipsViews.swift` | Full tip inventory, trigger conditions |
| `EvolutionSimGame/Views/HowToPlayView.swift` | Reference copy for player guide cross-check |
| `EvolutionSimGame/Views/StartScreenView.swift` | Start screen flow, Continue subtitle |
| `EvolutionSimGame/Views/NewGameSetupView.swift` | Goal picker, seed, mass extinction copy |
| `EvolutionSimGame/Views/InspectorPanelView.swift` | All displayed fields, section order |
| `EvolutionSimGame/ViewModels/GameViewModel.swift` | Tutorial/mutation state machine, tip dispatch, `firstMutationMinimumTick` |
| `EvolutionSimCore/Sources/EvolutionSimCore/Simulation/SimulationTuning.swift` | All balance constants (reference only — not modified) |
| `.cursor/plans/graphics_upgrade_plan_8762ad7c.plan.md` | Phase 1 complete (2D Canvas), Phase 2 3D (post-beta) — coordination boundary |

---

*Plan authored by `/evolution-player-experience-specialist`, 2026-06-27. Ready for agent handoff — see §8 for task stubs.*
