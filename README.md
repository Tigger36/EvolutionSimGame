# EvolutionSimGame

An interactive native Apple-platform evolution simulator game for macOS, iPadOS, and iOS. Guide a lineage from a single-celled organism through survival, reproduction, and strategic mutation choices.

## Project Structure

```
EvolutionSimCore/          Swift package — deterministic simulation (no UI)
EvolutionSimGame/          SwiftUI multiplatform app
EvolutionSimGame.xcodeproj Generated via XcodeGen (project.yml)
docs/                      Design and architecture docs
```

## Requirements

- Xcode 15+ (tested with Xcode 27 beta)
- macOS 14+ / iOS 17+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (optional, for regenerating the Xcode project)

## Build and Test

### Simulation core (headless, deterministic)

```bash
cd EvolutionSimCore
swift test
```

### macOS app

```bash
xcodebuild -scheme EvolutionSimGame_macOS -destination 'platform=macOS' build
```

### iPad / iOS app

```bash
xcodebuild -scheme EvolutionSimGame_iOS -destination 'platform=iOS Simulator,name=iPad (A16)' build
```

### Regenerate Xcode project

```bash
xcodegen generate
```

## Architecture

- **EvolutionSimCore** — UI-free simulation with seeded RNG, fixed time steps, continuous 2D world, terrain, organisms, food, predators, traits, reproduction, contextual mutations, lineage handoff, fitness metrics, era progression, and victory goals.
- **EvolutionSimGame** — SwiftUI app rendering `SimulationSnapshot` via Canvas. iPad-first adaptive layout with side inspector; iPhone uses compact layout; macOS adds menus and keyboard shortcuts.

See [docs/game-design.md](docs/game-design.md) for product direction and [docs/rendering-decision.md](docs/rendering-decision.md) for rendering technology choice.

## Gameplay (MVP)

1. Move your organism (touch joystick / D-pad / arrow keys).
2. Eat food particles to gain energy.
3. Avoid predators; terrain affects speed, energy, and damage.
4. Reproduce when energy is sufficient and the site is safe.
5. Choose a guided mutation for your offspring.
6. If you die, control passes to a descendant.

## License

TBD
