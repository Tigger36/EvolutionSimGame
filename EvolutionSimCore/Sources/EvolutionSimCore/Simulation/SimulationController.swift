import Foundation

public struct PlayerInput: Codable, Equatable, Sendable {
    public var movementDirection: Vector2

    public init(movementDirection: Vector2 = .zero) {
        self.movementDirection = movementDirection
    }
}

public enum SimulationPhase: String, Codable, Sendable {
    case playing
    case awaitingMutationChoice
    case extinct
    case victory
}

public struct SimulationConfig: Codable, Equatable, Sendable {
    public static let tutorialSeed: UInt64 = 1001

    public var seed: UInt64
    public var bounds: WorldBounds
    public var era: GameEra
    public var victoryGoal: VictoryGoal
    public var enableMassExtinctionEvents: Bool
    public var predatorCountOverride: Int?

    public init(
        seed: UInt64 = 42,
        bounds: WorldBounds = .standard,
        era: GameEra = .primordialPool,
        victoryGoal: VictoryGoal = .spreadToAllBiomes,
        enableMassExtinctionEvents: Bool = true,
        predatorCountOverride: Int? = nil
    ) {
        self.seed = seed
        self.bounds = bounds
        self.era = era
        self.victoryGoal = victoryGoal
        self.enableMassExtinctionEvents = enableMassExtinctionEvents
        self.predatorCountOverride = predatorCountOverride
    }

    public static func tutorialPreset() -> SimulationConfig {
        SimulationConfig(
            seed: tutorialSeed,
            victoryGoal: .reachPopulation,
            enableMassExtinctionEvents: false,
            predatorCountOverride: 2
        )
    }
}

public struct SimulationState: Codable, Equatable, Sendable {
    public var config: SimulationConfig
    public var rng: SeededRNG
    public var idGenerator: EntityIDGenerator
    public var tick: Int
    public var terrain: TerrainField
    public var organisms: [Organism]
    public var food: [FoodParticle]
    public var predators: [Predator]
    public var playerOrganismID: EntityID?
    public var pressure: PressureState
    public var fitness: FitnessMetrics
    public var phase: SimulationPhase
    public var pendingMutationOffers: [MutationOption]
    public var pendingMutationTargetID: EntityID?
    public var exploredCells: Set<String>
    public var massExtinctionActive: Bool
    public var massExtinctionStartTick: Int?
    public var isPaused: Bool
    public var speedMultiplier: Double

    public init(config: SimulationConfig) {
        self.config = config
        self.rng = SeededRNG(seed: config.seed)
        self.idGenerator = EntityIDGenerator()
        self.tick = 0
        self.terrain = config.era.rawValue >= GameEra.biomes.rawValue
            ? TerrainField.eraExpandedLayout(bounds: config.bounds, era: config.era)
            : TerrainField.mvpLayout(bounds: config.bounds)
        self.organisms = []
        self.food = []
        self.predators = []
        self.playerOrganismID = nil
        self.pressure = PressureState()
        self.fitness = FitnessMetrics()
        self.phase = .playing
        self.pendingMutationOffers = []
        self.pendingMutationTargetID = nil
        self.exploredCells = []
        self.massExtinctionActive = false
        self.massExtinctionStartTick = nil
        self.isPaused = false
        self.speedMultiplier = 1.0
    }

    public var playerOrganism: Organism? {
        guard let id = playerOrganismID else { return nil }
        return organisms.first { $0.id == id && $0.isAlive }
    }

    public var livingOrganisms: [Organism] {
        organisms.filter { $0.isAlive }
    }

    public var lineageSummary: LineageSummary {
        let living = livingOrganisms
        let lineageID = living.first?.lineageID ?? 1
        let maxGen = living.map(\.generation).max() ?? 1
        let avgTraits = living.first?.traits ?? .default
        return LineageSummary(
            lineageID: lineageID,
            generation: maxGen,
            livingCount: living.count,
            totalBorn: fitness.totalOffspring,
            fitness: fitness,
            dominantTraits: avgTraits
        )
    }

    public func terrain(at position: Vector2) -> TerrainType {
        terrain.terrain(at: position)
    }

    public func biomeCompatibility(for organism: Organism) -> [TerrainType: Double] {
        Dictionary(uniqueKeysWithValues: TerrainType.allCases.map { terrain in
            (terrain, TerrainSystem.biomeCompatibility(traits: organism.traits, terrain: terrain))
        })
    }
}

public struct SimulationSnapshot: Codable, Equatable, Sendable {
    public let tick: Int
    public let phase: SimulationPhase
    public let organisms: [Organism]
    public let food: [FoodParticle]
    public let predators: [Predator]
    public let terrain: TerrainField
    public let bounds: WorldBounds
    public let playerOrganismID: EntityID?
    public let fitness: FitnessMetrics
    public let lineage: LineageSummary
    public let pressure: PressureState
    public let pendingMutationOffers: [MutationOption]
    public let pendingMutationTargetID: EntityID?
    public let playerCanReproduceSafely: Bool
    public let era: GameEra
    public let victoryGoal: VictoryGoal
    public let isPaused: Bool
    public let speedMultiplier: Double
    public let massExtinctionActive: Bool

    public init(from state: SimulationState) {
        tick = state.tick
        phase = state.phase
        organisms = state.organisms
        food = state.food
        predators = state.predators
        terrain = state.terrain
        bounds = state.config.bounds
        playerOrganismID = state.playerOrganismID
        fitness = state.fitness
        lineage = state.lineageSummary
        pressure = state.pressure
        pendingMutationOffers = state.pendingMutationOffers
        pendingMutationTargetID = state.pendingMutationTargetID
        if let player = state.playerOrganism {
            let terrainType = state.terrain(at: player.position)
            playerCanReproduceSafely = player.canReproduce
                && ReproductionSystem.isSafeSite(
                    position: player.position,
                    predators: state.predators,
                    terrain: terrainType,
                    traits: player.traits
                )
        } else {
            playerCanReproduceSafely = false
        }
        era = state.config.era
        victoryGoal = state.config.victoryGoal
        isPaused = state.isPaused
        speedMultiplier = state.speedMultiplier
        massExtinctionActive = state.massExtinctionActive
    }

    public var playerOrganism: Organism? {
        guard let id = playerOrganismID else { return nil }
        return organisms.first { $0.id == id && $0.isAlive }
    }

    public var playerCurrentTerrain: TerrainType? {
        guard let player = playerOrganism else { return nil }
        return terrain.terrain(at: player.position)
    }

    public var pendingMutationTargetTraits: TraitSet? {
        guard let targetID = pendingMutationTargetID else { return nil }
        return organisms.first { $0.id == targetID }?.traits
    }

    public func activeTerrainsForLegend() -> [TerrainType] {
        var types = Set(terrain.regions.map(\.type))
        types.insert(terrain.defaultType)
        return TerrainType.allCases.filter { types.contains($0) }
    }
}

public final class SimulationController: @unchecked Sendable {
    public private(set) var state: SimulationState

    public init(config: SimulationConfig = SimulationConfig()) {
        self.state = SimulationState(config: config)
        bootstrapWorld()
    }

    public init(state: SimulationState) {
        self.state = state
    }

    public func snapshot() -> SimulationSnapshot {
        SimulationSnapshot(from: state)
    }

    public func reset(config: SimulationConfig? = nil) {
        if let config {
            state = SimulationState(config: config)
        } else {
            state = SimulationState(config: state.config)
        }
        bootstrapWorld()
    }

    public func setPaused(_ paused: Bool) {
        state.isPaused = paused
    }

    public func setSpeedMultiplier(_ multiplier: Double) {
        state.speedMultiplier = min(8, max(0.25, multiplier))
    }

    public func setSeed(_ seed: UInt64) {
        var config = state.config
        config.seed = seed
        reset(config: config)
    }

    /// Deterministically samples a spawn point at least `minDistance` from `anchor`.
    /// Uses bounded rejection sampling; if no sample qualifies it pushes the last candidate
    /// out to the buffer ring (clamped to bounds) so spawning stays deterministic and never
    /// places a predator on top of the player.
    static func spawnPosition(
        awayFrom anchor: Vector2,
        minDistance: Double,
        bounds: WorldBounds,
        rng: inout SeededRNG
    ) -> Vector2 {
        let maxAttempts = 20
        var candidate = bounds.randomPoint(rng: &rng)
        var attempts = 1
        while candidate.distance(to: anchor) < minDistance && attempts < maxAttempts {
            candidate = bounds.randomPoint(rng: &rng)
            attempts += 1
        }
        if candidate.distance(to: anchor) < minDistance {
            let raw = (candidate - anchor).normalized
            let direction = raw == .zero ? Vector2(x: 1, y: 0) : raw
            candidate = (anchor + direction * minDistance).clamped(to: bounds)
        }
        return candidate
    }

    /// Predator aggression scalar for the current tick. During the primordial grace window this
    /// ramps linearly from `primordialGraceMinAggressionFraction` to 1.0, scaling chase speed and
    /// bite damage so the earliest ticks are learnable. Always 1.0 outside primordial/grace.
    func currentPredatorAggression() -> Double {
        guard state.config.era == .primordialPool else { return 1.0 }
        let grace = SimulationTuning.primordialGraceTicks
        guard grace > 0, state.tick < grace else { return 1.0 }
        let minFraction = SimulationTuning.primordialGraceMinAggressionFraction
        let progress = Double(state.tick) / Double(grace)
        return minFraction + (1.0 - minFraction) * progress
    }

    private func bootstrapWorld() {
        let startPos = state.config.bounds.center
        let playerID = state.idGenerator.next()
        let player = Organism(
            id: playerID,
            position: startPos,
            isPlayerControlled: true,
            generation: 1,
            lineageID: 1
        )
        state.organisms = [player]
        state.playerOrganismID = playerID

        var rng = state.rng
        var idGenerator = state.idGenerator
        var food = state.food

        for _ in 0..<SimulationTuning.maxFoodParticles / 2 {
            FoodSystem.spawnIfNeeded(
                food: &food,
                rng: &rng,
                idGenerator: &idGenerator,
                bounds: state.config.bounds,
                tick: 0
            )
        }

        let predatorCount = state.config.predatorCountOverride
            ?? EraContent.predatorCount(for: state.config.era)
        for _ in 0..<predatorCount {
            let pos = Self.spawnPosition(
                awayFrom: startPos,
                minDistance: SimulationTuning.predatorSpawnMinDistanceFromPlayer,
                bounds: state.config.bounds,
                rng: &rng
            )
            let era = state.config.era
            state.predators.append(
                Predator(
                    id: idGenerator.next(),
                    position: pos,
                    speed: EraContent.predatorSpeed(for: era),
                    senseRadius: EraContent.predatorSenseRadius(for: era),
                    damage: EraContent.predatorDamage(for: era)
                )
            )
        }

        state.rng = rng
        state.idGenerator = idGenerator
        state.food = food
    }

    public func step(input: PlayerInput = PlayerInput()) {
        guard !state.isPaused else { return }
        guard state.phase == .playing else { return }

        state.tick += 1
        updateEraIfNeeded()
        updateMassExtinctionIfNeeded()

        updatePlayerOrganism(input: input)
        updateDescendants()
        updatePredators()
        updateFood()
        updatePressure()
        handlePlayerDeath()
        checkVictory()

        state.pressure.decay()
    }

    public func stepMultiple(count: Int, input: PlayerInput = PlayerInput()) {
        let steps = min(count, SimulationTuning.maxTicksPerStep)
        for _ in 0..<steps {
            step(input: input)
            if state.phase != .playing { break }
        }
    }

    public func selectMutation(_ option: MutationOption) {
        guard state.phase == .awaitingMutationChoice else { return }
        guard let targetID = state.pendingMutationTargetID else { return }
        guard let index = state.organisms.firstIndex(where: { $0.id == targetID }) else { return }

        option.apply(to: &state.organisms[index].traits)
        state.pendingMutationOffers = []
        state.pendingMutationTargetID = nil
        state.phase = .playing
    }

    public func transferControl(to organismID: EntityID) {
        for index in state.organisms.indices {
            state.organisms[index].isPlayerControlled = state.organisms[index].id == organismID
        }
        state.playerOrganismID = organismID
    }

    private func updatePlayerOrganism(input: PlayerInput) {
        guard let id = state.playerOrganismID,
              let index = state.organisms.firstIndex(where: { $0.id == id && $0.isAlive }) else { return }

        var organism = state.organisms[index]
        let terrainType = state.terrain(at: organism.position)

        MovementSystem.applyMovement(
            organism: &organism,
            direction: input.movementDirection,
            terrain: terrainType,
            bounds: state.config.bounds
        )

        var foodEaten = false
        var food = state.food
        if FoodSystem.tryConsume(organism: &organism, food: &food) {
            foodEaten = true
        }
        state.food = food

        var nearMiss = false
        var hit = false
        if let (predator, dist) = PredatorSystem.nearestPredator(to: organism.position, predators: state.predators) {
            if dist <= organism.traits.effectiveSenseRadius {
                if dist > organism.radius + predator.radius + 10 {
                    nearMiss = true
                    state.pressure.predator += SimulationTuning.predatorNearMissPressure
                }
            }
            let damageMultiplier = SocialDefenseSystem.predatorDamageMultiplier(
                for: organism,
                nearbyOrganisms: state.organisms
            )
            if PredatorSystem.attack(
                organism: &organism,
                predator: predator,
                aggression: currentPredatorAggression(),
                damageMultiplier: damageMultiplier
            ) {
                hit = true
            }
        }

        FitnessSystem.update(
            metrics: &state.fitness,
            organism: organism,
            terrain: terrainType,
            foodEaten: foodEaten,
            nearMiss: nearMiss,
            hit: hit
        )

        trackExploration(at: organism.position, terrain: terrainType)
        applyTerrainPressure(terrainType)

        let reproductionSiteIsSafe = ReproductionSystem.isSafeSite(
            position: organism.position,
            predators: state.predators,
            terrain: terrainType,
            traits: organism.traits
        )
        if organism.canReproduce && reproductionSiteIsSafe {
            var rng = state.rng
            var idGenerator = state.idGenerator
            if let child = ReproductionSystem.reproduce(
                parent: &organism,
                rng: &rng,
                idGenerator: &idGenerator,
                predators: state.predators,
                bounds: state.config.bounds,
                terrainField: state.terrain
            ) {
                state.rng = rng
                state.idGenerator = idGenerator
                state.fitness.totalOffspring += 1
                state.organisms.append(child)
                beginMutationChoice(for: child.id)
            }
        }

        organism.age += 1
        if organism.age >= SimulationTuning.maxAge {
            organism.isAlive = false
        }

        state.organisms[index] = organism
    }

    private func descendantMovementDirection(for organism: Organism) -> Vector2? {
        if let (predator, dist) = PredatorSystem.nearestPredator(to: organism.position, predators: state.predators),
           dist <= organism.traits.effectiveSenseRadius {
            return (organism.position - predator.position).normalized
        }

        if let food = state.food.min(by: {
            organism.position.distance(to: $0.position) < organism.position.distance(to: $1.position)
        }),
            organism.position.distance(to: food.position) <= organism.traits.effectiveSenseRadius {
            return (food.position - organism.position).normalized
        }

        return nil
    }

    private func updateDescendants() {
        let descendantCount = state.organisms.filter { $0.isAlive && !$0.isPlayerControlled }.count
        guard descendantCount <= SimulationTuning.maxDescendants else { return }

        for index in state.organisms.indices {
            guard state.organisms[index].isAlive, !state.organisms[index].isPlayerControlled else { continue }

            var organism = state.organisms[index]
            let terrainType = state.terrain(at: organism.position)

            if let direction = descendantMovementDirection(for: organism), direction != .zero {
                MovementSystem.applyMovement(
                    organism: &organism,
                    direction: direction,
                    terrain: terrainType,
                    bounds: state.config.bounds
                )
            } else {
                var rng = state.rng
                MovementSystem.wander(
                    organism: &organism,
                    terrain: terrainType,
                    bounds: state.config.bounds,
                    rng: &rng
                )
                state.rng = rng
            }

            var food = state.food
            _ = FoodSystem.tryConsume(organism: &organism, food: &food)
            state.food = food

            if let (_, dist) = PredatorSystem.nearestPredator(to: organism.position, predators: state.predators),
               dist <= organism.radius + SimulationTuning.predatorRadius {
                let aggression = currentPredatorAggression()
                let damageMultiplier = SocialDefenseSystem.predatorDamageMultiplier(
                    for: organism,
                    nearbyOrganisms: state.organisms
                )
                for pIndex in state.predators.indices where state.predators[pIndex].isAlive {
                    if PredatorSystem.attack(
                        organism: &organism,
                        predator: state.predators[pIndex],
                        aggression: aggression,
                        damageMultiplier: damageMultiplier
                    ) {
                        break
                    }
                }
            }

            organism.age += 1
            if organism.age >= SimulationTuning.maxAge {
                organism.isAlive = false
            }
            state.organisms[index] = organism
        }
    }

    private func updatePredators() {
        let targetPos = state.playerOrganism?.position ?? state.config.bounds.center
        let aggression = currentPredatorAggression()
        var rng = state.rng
        for index in state.predators.indices {
            PredatorSystem.update(
                predator: &state.predators[index],
                targetPosition: targetPos,
                bounds: state.config.bounds,
                rng: &rng,
                aggression: aggression
            )
        }
        state.rng = rng
    }

    private func updateFood() {
        var food = state.food
        var rng = state.rng
        var idGenerator = state.idGenerator

        FoodSystem.spawnIfNeeded(
            food: &food,
            rng: &rng,
            idGenerator: &idGenerator,
            bounds: state.config.bounds,
            tick: state.tick
        )

        state.food = food
        state.rng = rng
        state.idGenerator = idGenerator

        if state.food.count < SimulationTuning.maxFoodParticles / 3 {
            state.pressure.foodScarcity += SimulationTuning.foodScarcityPressure
        }
    }

    private func updatePressure() {
        if state.food.isEmpty {
            state.pressure.foodScarcity += SimulationTuning.foodScarcityPressure
        }
    }

    private func trackExploration(at position: Vector2, terrain: TerrainType) {
        let cellKey = "\(Int(position.x / 40)):\(Int(position.y / 40))"
        if !state.exploredCells.contains(cellKey) {
            state.exploredCells.insert(cellKey)
            state.pressure.exploration += SimulationTuning.explorationPressure
        }
        state.fitness.biomesExplored.insert(terrain)
    }

    private func applyTerrainPressure(_ terrain: TerrainType) {
        switch terrain {
        case .water:
            state.pressure.water += SimulationTuning.waterExposurePressure
        case .toxicPool:
            state.pressure.toxic += SimulationTuning.toxicExposurePressure
        default:
            break
        }
    }

    private func beginMutationChoice(for organismID: EntityID) {
        var rng = state.rng
        state.pendingMutationTargetID = organismID
        state.pendingMutationOffers = MutationSystem.offers(for: state.pressure, rng: &rng)
        state.rng = rng
        state.phase = .awaitingMutationChoice
    }

    private func handlePlayerDeath() {
        guard state.playerOrganism == nil || state.playerOrganism?.isAlive == false else { return }

        if let descendant = state.organisms.first(where: { $0.isAlive && !$0.isPlayerControlled }) {
            transferControl(to: descendant.id)
        } else if state.organisms.contains(where: { $0.isAlive }) {
            if let any = state.organisms.first(where: { $0.isAlive }) {
                transferControl(to: any.id)
            }
        } else {
            state.phase = .extinct
        }
    }

    private func updateEraIfNeeded() {
        let newEra = EraSystem.era(for: state.fitness.compositeScore)
        if newEra.rawValue > state.config.era.rawValue {
            state.config.era = newEra
            EraContent.apply(to: &state)
            applyPredatorDifficulty(for: newEra)
        }
    }

    private func applyPredatorDifficulty(for era: GameEra) {
        let baseSpeed = EraContent.predatorSpeed(for: era)
        let senseRadius = EraContent.predatorSenseRadius(for: era)
        let damage = EraContent.predatorDamage(for: era)
        let speed = state.massExtinctionActive
            ? baseSpeed * SimulationTuning.massExtinctionSpeedMultiplier
            : baseSpeed

        for index in state.predators.indices {
            state.predators[index].speed = speed
            state.predators[index].senseRadius = senseRadius
            state.predators[index].damage = damage
        }

        // Respect an explicit predator-count override (e.g. the gentle tutorial preset) across
        // era transitions. Without this the override only held at bootstrap and eras silently
        // re-escalated predator counts, making the tutorial harder than intended.
        let targetCount = state.config.predatorCountOverride ?? EraContent.predatorCount(for: era)
        adjustPredatorCount(to: targetCount, era: era)
    }

    private func adjustPredatorCount(to targetCount: Int, era: GameEra) {
        let currentCount = state.predators.count
        guard currentCount != targetCount else { return }

        if currentCount < targetCount {
            var rng = state.rng
            var idGenerator = state.idGenerator
            let anchor = state.playerOrganism?.position ?? state.config.bounds.center
            for _ in 0..<(targetCount - currentCount) {
                let pos = Self.spawnPosition(
                    awayFrom: anchor,
                    minDistance: SimulationTuning.predatorSpawnMinDistanceFromPlayer,
                    bounds: state.config.bounds,
                    rng: &rng
                )
                var speed = EraContent.predatorSpeed(for: era)
                if state.massExtinctionActive {
                    speed *= SimulationTuning.massExtinctionSpeedMultiplier
                }
                state.predators.append(
                    Predator(
                        id: idGenerator.next(),
                        position: pos,
                        speed: speed,
                        senseRadius: EraContent.predatorSenseRadius(for: era),
                        damage: EraContent.predatorDamage(for: era)
                    )
                )
            }
            state.rng = rng
            state.idGenerator = idGenerator
            return
        }

        let playerPos = state.playerOrganism?.position ?? state.config.bounds.center
        let removeCount = currentCount - targetCount
        let idsToRemove = state.predators
            .sorted { lhs, rhs in
                let lhsDist = lhs.position.distance(to: playerPos)
                let rhsDist = rhs.position.distance(to: playerPos)
                if lhsDist != rhsDist { return lhsDist > rhsDist }
                if lhs.health != rhs.health { return lhs.health < rhs.health }
                return lhs.id.rawValue > rhs.id.rawValue
            }
            .prefix(removeCount)
            .map(\.id)
        let removeSet = Set(idsToRemove)
        state.predators.removeAll { removeSet.contains($0.id) }
    }

    private func updateMassExtinctionIfNeeded() {
        guard state.config.enableMassExtinctionEvents else { return }
        if state.tick == 2000 && !state.massExtinctionActive {
            state.massExtinctionActive = true
            state.massExtinctionStartTick = state.tick
            for index in state.predators.indices {
                state.predators[index].speed *= SimulationTuning.massExtinctionSpeedMultiplier
            }
        }
    }

    private func checkVictory() {
        let living = state.livingOrganisms.count
        if EraSystem.checkVictory(
            goal: state.config.victoryGoal,
            metrics: state.fitness,
            livingPopulation: living,
            tick: state.tick,
            massExtinctionActive: state.massExtinctionActive
        ) {
            state.phase = .victory
        }
    }
}

// MARK: - Save / Restore

public struct SavedSimulation: Codable, Equatable, Sendable {
    public var state: SimulationState
    public var inputLog: [PlayerInput]

    public init(state: SimulationState, inputLog: [PlayerInput] = []) {
        self.state = state
        self.inputLog = inputLog
    }
}

public enum SimulationReplay {
    public static func replay(config: SimulationConfig, inputs: [PlayerInput]) -> SimulationState {
        let controller = SimulationController(config: config)
        for input in inputs {
            if controller.state.phase == .awaitingMutationChoice,
               let offer = controller.state.pendingMutationOffers.first {
                controller.selectMutation(offer)
            }
            controller.step(input: input)
        }
        return controller.state
    }
}
