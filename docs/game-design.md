# EvolutionSimGame Design Guide

## Repository Context

EvolutionSimGame is at **post-MVP alpha**. Treat `README.md`, repository code,
tests, and [docs/player-guide.md](player-guide.md) as the source of truth for
**implemented** behavior. This design guide mixes implemented mechanics with
aspirational content (body plans, trait categories, future reproduction models).
Sections below that describe systems not in the player guide are **planned**, not
shipped. Public beta scope and gaps: [docs/beta/public-beta-scope.md](beta/public-beta-scope.md).

The current product direction is an interactive native Apple-platform evolution
simulator game for macOS, iPadOS, and iOS. The player should guide a fictitious
creature from a single-celled organism into a more complex, better-adapted
lineage through survival, reproduction, mutation, and strategic evolutionary
choices.

## Core Concept

The game should focus on guiding one playable lineage, not just one individual
creature. The player starts as a single-celled organism, directly controls it,
survives long enough to reproduce, and then chooses evolutionary traits for the
next generation. Over time, the player's species spreads, adapts, branches, and
competes in a changing world.

The strongest core loop is:

1. Survive moment to moment by moving, eating, fleeing, hiding, hunting, and
   reproducing.
2. Earn evolutionary pressure points through survival, food, reproduction,
   exploration, and hazard exposure.
3. Choose mutations or evolutionary traits at reproduction or generation
   milestones.
4. Watch descendants inherit tradeoffs and perform better or worse in the
   environment.
5. Adapt to terrain, predators, climate, and resource scarcity over many
   generations.

## Gameplay Pillars

- Evolution should be visible. Body shape, movement style, senses, diet,
  defenses, and habitat access should visibly change.
- Every adaptation should have a tradeoff. Fins help in water but reduce land
  mobility. Armor protects but slows movement. Larger brains improve planning
  but require more food.
- Terrain should drive strategy. Water, mud, sand, forest, ice, cliffs, caves,
  toxic pools, and open plains should reward different builds.
- The player controls individuals, but wins through lineage fitness. One
  creature can die, but the species can continue if it reproduced successfully.
- Biology should be simple enough for strong game clarity. Avoid scientific
  realism that makes choices hard to understand.

## Core Mechanics

The first durable design should include these major systems:

- Movement: swimming, crawling, slithering, walking, gliding, burrowing, and
  climbing.
- Food: microbes, plants, carrion, prey, minerals, and optional unusual sources
  such as sunlight or chemosynthesis for stranger evolutionary paths.
- Threats: predators, parasites, toxins, starvation, drought, cold, heat, and
  disease.
- Reproduction: splitting, spawning, egg laying, live birth, or colony budding,
  depending on the evolution path.
- Mutation choices: after reproduction, choose from three to five possible
  adaptations influenced by recent survival pressure.
- Fitness score: a composite of survival time, offspring count, food efficiency,
  explored biomes, and predator avoidance rather than a simple level.
- Population simulation: descendants with similar traits should spread
  semi-autonomously while the player controls a chosen representative.

## Evolution Trait Categories

Trait categories should be understandable, observable, and tied to tactical
consequences.

### Body Plan

Possible body plans include:

- Single-cell
- Colony
- Worm-like
- Fish-like
- Amphibious
- Reptilian
- Mammalian
- Avian
- Insectoid
- Cephalopod-like
- Alien or fantasy forms

### Locomotion

Possible locomotion traits include:

- Flagella
- Cilia
- Fins
- Legs
- Wings
- Claws
- Suction
- Burrowing limbs

### Diet

Possible diet traits include:

- Herbivore
- Carnivore
- Omnivore
- Filter feeder
- Scavenger
- Photosynthetic hybrid

### Defense

Possible defense traits include:

- Shell
- Spikes
- Poison
- Camouflage
- Speed
- Schooling
- Mimicry
- Regeneration

### Senses

Possible sense traits include:

- Smell
- Vibration
- Sight
- Night vision
- Heat sense
- Echolocation
- Electromagnetic sense

### Metabolism

Possible metabolism traits include:

- Fast but hungry
- Slow but efficient
- Cold-tolerant
- Heat-tolerant
- Hibernation

### Social Behavior

Possible social traits include:

- Solitary behavior
- Pair bonding
- Herd behavior
- Swarm behavior
- Cooperative hunting
- Parental care

### Reproduction Strategy

Reproduction strategy should support meaningful tradeoffs, especially many
fragile offspring versus fewer protected offspring.

## Terrain Compatibility

Terrain compatibility should be one of the main strategic systems. Terrain
should not usually be an absolute wall. Instead, it should create pressure. A
creature may be able to cross bad terrain, but should pay through reduced speed,
increased energy use, higher risk, damage, or exposure.

Example terrain pressures:

- Water: easy for fins and gills, dangerous for lungs-only land creatures.
- Land: requires structural support, lungs, and moisture control.
- Swamp: favors amphibious, poison-resistant, slow, efficient creatures.
- Forest: favors climbing, camouflage, small size, and ambush predators.
- Desert: favors water storage, burrowing, and nocturnal senses.
- Mountain or cliff: favors grip, wings, light bodies, and endurance.
- Ice or tundra: favors insulation, fat, hibernation, and pack behavior.
- Toxic zones: favor filtration organs, resistant skin, and symbiosis.

Terrain should make evolutionary choice visible. For example, a sea creature
should cross water easily, while a land-specialized creature should need a
different adaptation, a safe route, or a costly crossing attempt.

## Reproduction Model

Reproduction should be a tactical decision, not only a button press.

Recommended model:

- The creature must gather enough energy.
- The creature must find or create a safe reproduction site.
- Reproduction creates offspring with inherited traits plus small mutation
  variance.
- The player can choose one guided mutation after reproduction.
- If the current organism dies, the player continues as one descendant if the
  lineage survived.

This gives death consequence without making the game overly frustrating.

## Progression Structure

The game should use eras rather than traditional levels. Each era can introduce
new pressures, resources, terrain, predators, and trait opportunities.

Recommended era sequence:

1. Primordial Pool: single-cell survival, food, toxins, and predators.
2. Reef / Shallows: movement, senses, and simple predator-prey systems.
3. Landfall: amphibious evolution, moisture, and terrain risk.
4. Biomes: forest, swamp, desert, tundra, mountain, and ocean adaptation.
5. Ecosystem Dominance: migration, climate shifts, rival species, and
   extinction events.

The game does not need a fixed endpoint. Possible victory goals include:

- Survive a mass extinction.
- Spread to every major biome.
- Reach a target population.
- Evolve intelligence or tool use.
- Become an apex predator, keystone herbivore, or hyper-adaptable generalist.

## Player Choice Design

The initial design should avoid a giant static skill tree. Prefer contextual
choices that respond to how the player survived.

For example, after repeated water exposure, the player could be offered:

- Develop stronger fins: better swimming, worse land agility.
- Develop moisture-resistant skin: better land survival, higher energy cost.
- Develop gills: better underwater endurance, worse dry survival.
- Stay generalized: no major bonus, no major penalty.

This makes evolution feel responsive to actual play instead of arbitrary
progression.

## Apple-Platform UI Direction

The simulation view should remain visually primary. Controls and overlays should
support decision-making without obscuring important organism and environment
state.

Recommended UI elements:

- Main simulation view.
- Pause, speed, selected organism, reproduction, and mutation controls.
- Inspector panel for traits, energy, health, hunger, age, offspring, and biome
  compatibility.
- Debug and learning overlays for scent trails, food density, danger zones,
  terrain cost, and lineage state.
- On iPadOS and macOS, use side panels, pointer affordances, keyboard support,
  and larger information layouts where appropriate.
- On iPhone, use simplified overlays, readable touch targets, and compact
  controls such as a radial or bottom control surface.

The game should not make macOS, iPadOS, and iOS feel identical when
platform-specific behavior is expected. iPhone controls should be touch-friendly
and readable. iPad should use space intentionally with adaptive panels, pointer
support, and keyboard shortcuts where useful. macOS should support desktop
affordances such as menus, commands, keyboard shortcuts, toolbars, inspectors,
settings windows, pointer targets, and multiwindow assumptions when in scope.

## Recommended MVP

The first playable version should be the smallest version that proves the game
idea: the player can feel evolution through survival choices.

Recommended MVP scope:

- 2D top-down world.
- One controllable single-cell organism.
- Food particles.
- Simple predators.
- Energy, health, and reproduction.
- Seeded deterministic simulation.
- Three terrain types: water, mud, and toxic pool.
- Six to ten traits, such as speed, size, armor, toxin resistance, swim
  efficiency, reproduction rate, sense radius, and metabolism.
- Reproduction creates descendants.
- Mutation choice after reproduction.
- Basic fitness and lineage summary.

The MVP should keep simulation behavior independent from UI rendering so it can
be tested deterministically. Randomness should be explicit and seeded. Simulation
time steps should be stable and not frame-rate dependent.
