# EvolutionSimGame Player Guide

This guide describes mechanics implemented in the **post-MVP alpha** build. The
broader design in `docs/game-design.md` includes future ideas; the rules below are
the source of truth for what players can rely on now.

## Core Loop

1. Move your organism with the D-pad, touch controls, or arrow keys.
2. Eat green food particles to refill energy.
3. Avoid red predators. Armor reduces bite damage, and high senses help you
   notice danger sooner.
4. Reproduce automatically when you have enough energy and the site is safe.
5. Choose one guided mutation for the offspring.
6. Keep the lineage alive. If the current organism dies, control transfers to a
   living descendant. If no descendants survive, the lineage is extinct.

## Reproduction

Reproduction is automatic in the current MVP. There is no mate requirement,
manual reproduce button, cooldown, or egg site selection yet.

Your organism reproduces when all of these are true:

- The simulation phase is playing.
- Your organism is alive.
- Energy is at or above its reproduction threshold.
- No predator is within 100 world units.
- The current terrain does not damage your organism after trait resistance is
  applied.

The default reproduction threshold is 60 energy. The `Reproduction Rate` trait
changes that threshold from 72 energy at the lowest value to 48 energy at the
highest value. Reproduction costs the parent 40 energy.

After reproduction:

- The offspring spawns near the parent.
- The offspring inherits the parent's traits with small random variance.
- The offspring starts with 50 energy plus up to 30 more from `Parental Care`.
- The game pauses for an adaptation choice.
- The chosen mutation applies to the offspring, not the parent.
- You keep controlling the parent until it dies.

Descendants do not reproduce by themselves in the MVP. They move on their own,
seek visible food, flee visible predators, can be hurt by terrain or predators,
can starve, and can die of old age. When the controlled parent dies, the game
hands control to a living descendant if one exists.

## Keeping Offspring Alive

The safest reproduction site is a place with nearby food, non-damaging terrain,
and no predators within the safe-site radius.

Useful ways to improve offspring survival:

- Build enough energy before reproduction so the parent is not left starving.
- Reproduce away from predators; reproduction will not fire while one is too
  close, but nearby predators can still threaten the offspring after it is born.
- Choose `Parental Care` when you want offspring to start with more energy.
- Choose `Enhanced Senses` or `Night Vision` when descendants need to detect food
  and predators sooner.
- Choose `Herd Instinct` when descendants are likely to stay near allies; nearby
  allies reduce predator damage for social organisms.
- Avoid reproducing inside toxic or high-drain terrain unless the lineage is
  adapted for it.

## Terrain Tradeoffs

Terrain affects movement speed, energy drain, and damage per tick. There are no
terrain-specific food types or food-spawn bonuses yet.

| Terrain | Default effect | Helpful traits | Strategic reason |
| --- | --- | --- | --- |
| Land | 85% speed, normal energy, no damage | Balanced swim efficiency | Baseline travel and recovery terrain. Very high swim specialization slows land movement. |
| Water | 85% speed, 90% energy drain, no damage | Swim Efficiency, Gills, Stronger Fins | Costs less energy to move through, and swim-adapted organisms become much faster there. |
| Mud | 68% speed, 130% energy drain, no damage | Smaller Size, efficient route choice | A hazard that punishes slow or large bodies; crossing it creates pressure for smaller builds. |
| Toxic Pool | 60% speed, 125% energy drain, 0.20 damage/tick at default resistance | Toxin Resistance, Toxin Filter | Dangerous without resistance; adapting lets the lineage exploit routes others cannot safely cross. |
| Forest | 85% speed, 110% energy drain, no damage | Sense Radius | Dense terrain that favors organisms with better perception. |
| Swamp | 50% speed, 140% energy drain, no damage | Swim Efficiency | High-cost mixed terrain; amphibious builds move through it more reliably. |
| Desert | 55% speed, 160% energy drain, 0.02 damage/tick | Higher Metabolism in current tuning | A harsh biome that tests energy reserves and speed. |
| Tundra | 60% speed, 130% energy drain, 0.01 damage/tick | Lower Metabolism | Cold terrain that favors slow, efficient organisms. |
| Mountain | 96% speed, 150% energy drain, no damage | Smaller Size | Energy-expensive traversal; smaller bodies climb with less penalty. |
| Ice | 75% speed, 120% energy drain, 0.015 damage/tick | Armor | Slippery, damaging terrain where armor helps grip and survival. |

## Eras and Progression

Fitness (survival time, offspring, food, biomes explored, predator near-misses,
generations) drives **era progression**:

| Era | Display name |
| --- | --- |
| 1 | Primordial Pool |
| 2 | Reef / Shallows |
| 3 | Landfall |
| 4 | Biomes |
| 5 | Ecosystem Dominance |

Higher eras increase predator count, speed, damage, and sense radius. Contextual
tips appear when you advance to a new era. The **Biomes** era unlocks the full
terrain set (forest, swamp, desert, tundra, mountain, ice) on the world map.

## Victory Goals

When starting a new game you choose one goal:

| Goal | Summary |
| --- | --- |
| Survive Mass Extinction | Survive the mass extinction event that begins around tick 2000. |
| Spread to All Biomes | Explore and adapt to at least 6 different biome types. |
| Reach Target Population | Grow your lineage to 15 living organisms. |
| Evolve Intelligence | Reach generation 10 with a fitness score of 500+. |

## Mass Extinction

When mass extinction events are enabled (default for standard new games), a
global extinction phase begins around tick 2000. During this event predators move
faster and chase more aggressively. The world tint shifts to signal heightened
danger. Surviving through the event satisfies the **Survive Mass Extinction**
victory goal.

## Tutorial and First Run

From the start screen you can:

- **Tutorial** — guided steps for move, eat, avoid predators, terrain, reproduce,
  choose mutation, and lineage handoff (tutorial preset with reduced pressure).
- **How to Play** — reference copy for the core loop.
- **New Game** — pick victory goal and mass-extinction setting.

Tutorial steps auto-advance when you complete each action (some steps use a
manual Continue button).

## Save and Continue

The simulation core supports Codable save state (`SavedSimulation`) for tests and
future persistence. **Durable save/continue after app relaunch is not yet in the
player-facing app** (planned Phase 9). Closing the app mid-run does not restore
progress today.

## Implemented vs Future

Implemented now:

- Automatic reproduction based on energy and predator distance.
- Inherited traits with mutation choices for offspring.
- Lineage handoff to descendants.
- Descendant food-seeking and predator-fleeing behavior.
- Terrain speed, energy, and damage effects (full biome set at Biomes era+).
- Social group defense from `Herd Instinct`.
- Era progression and era-scaled predator difficulty.
- Four victory goals and mass extinction events.
- Tutorial flow, contextual tips, and how-to-play screens.

Future design ideas not implemented yet:

- Manual reproduction button or explicit nest/egg placement.
- Mate finding, pair bonding, or multiple reproduction strategies.
- Terrain-specific food sources.
- Descendants reproducing independently.
- Detailed death notifications explaining exactly why each offspring died.
- Player-facing save/continue and seed sharing UI.
