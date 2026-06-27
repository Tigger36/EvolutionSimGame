import Foundation

public struct SpatialGrid: Sendable {
    private let cellSize: Double
    private let bounds: WorldBounds

    public init(cellSize: Double = 64, bounds: WorldBounds) {
        self.cellSize = cellSize
        self.bounds = bounds
    }

    private func cellIndex(for point: Vector2) -> (Int, Int) {
        let cx = Int(floor((point.x - bounds.minX) / cellSize))
        let cy = Int(floor((point.y - bounds.minY) / cellSize))
        return (cx, cy)
    }

    public func nearbyEntities<T>(
        at point: Vector2,
        radius: Double,
        entities: [(EntityID, Vector2, T)]
    ) -> [(EntityID, Vector2, T)] {
        return entities.filter { _, pos, _ in
            point.distance(to: pos) <= radius
        }
    }
}

public enum MovementSystem {
    public static func applyMovement(
        organism: inout Organism,
        direction: Vector2,
        terrain: TerrainType,
        bounds: WorldBounds
    ) {
        guard organism.isAlive else { return }

        let effects = TerrainSystem.effects(for: terrain, traits: organism.traits)
        let speed = organism.traits.effectiveSpeed * effects.speedMultiplier
        let dir = direction.length > 0 ? direction.normalized : .zero
        organism.velocity = dir * speed
        organism.position = (organism.position + organism.velocity * SimulationTuning.tickDuration)
            .clamped(to: bounds)

        let moveCost = SimulationTuning.movementEnergyCost * effects.energyDrainMultiplier
        organism.energy -= moveCost + organism.traits.metabolismDrain

        if effects.damagePerTick > 0 {
            organism.health -= effects.damagePerTick
        }

        if organism.energy <= 0 {
            organism.energy = 0
            organism.health -= SimulationTuning.starvationDamage
        }

        if organism.health <= 0 {
            organism.health = 0
            organism.isAlive = false
        }
    }

    public static func wander(
        organism: inout Organism,
        terrain: TerrainType,
        bounds: WorldBounds,
        rng: inout SeededRNG
    ) {
        let angle = rng.nextDouble(in: 0...(2 * .pi))
        let dir = Vector2(x: cos(angle), y: sin(angle))
        applyMovement(organism: &organism, direction: dir, terrain: terrain, bounds: bounds)
    }
}

public enum FoodSystem {
    public static func tryConsume(
        organism: inout Organism,
        food: inout [FoodParticle]
    ) -> Bool {
        guard organism.isAlive else { return false }
        for index in food.indices {
            let particle = food[index]
            let dist = organism.position.distance(to: particle.position)
            if dist <= organism.radius + particle.radius {
                organism.energy = min(SimulationTuning.baseEnergy * 1.5, organism.energy + particle.energyValue)
                food.remove(at: index)
                return true
            }
        }
        return false
    }

    public static func spawnIfNeeded(
        food: inout [FoodParticle],
        rng: inout SeededRNG,
        idGenerator: inout EntityIDGenerator,
        bounds: WorldBounds,
        tick: Int
    ) {
        guard food.count < SimulationTuning.maxFoodParticles else { return }
        guard tick % SimulationTuning.foodSpawnInterval == 0 else { return }
        let pos = bounds.randomPoint(rng: &rng)
        food.append(FoodParticle(id: idGenerator.next(), position: pos))
    }
}

public enum PredatorSystem {
    public static func update(
        predator: inout Predator,
        targetPosition: Vector2,
        bounds: WorldBounds,
        rng: inout SeededRNG,
        aggression: Double = 1.0
    ) {
        guard predator.isAlive else { return }

        let distToTarget = predator.position.distance(to: targetPosition)
        let movementDirection: Vector2
        let movementSpeed: Double

        if distToTarget <= predator.senseRadius {
            movementDirection = (targetPosition - predator.position).normalized
            movementSpeed = predator.speed * aggression
        } else {
            let angle = rng.nextDouble(in: 0...(2 * .pi))
            movementDirection = Vector2(x: cos(angle), y: sin(angle))
            movementSpeed = predator.speed * SimulationTuning.predatorWanderSpeedFraction
        }

        predator.velocity = movementDirection * movementSpeed
        predator.position = (predator.position + predator.velocity * SimulationTuning.tickDuration)
            .clamped(to: bounds)
    }

    public static func attack(
        organism: inout Organism,
        predator: Predator,
        aggression: Double = 1.0,
        damageMultiplier: Double = 1.0
    ) -> Bool {
        guard organism.isAlive, predator.isAlive else { return false }
        let dist = organism.position.distance(to: predator.position)
        guard dist <= organism.radius + predator.radius else { return false }

        let socialMultiplier = min(1.0, max(0.0, damageMultiplier))
        let damage = predator.damage * aggression * socialMultiplier * (1.0 - organism.traits.armor * 0.5)
        organism.health -= damage
        if organism.health <= 0 {
            organism.health = 0
            organism.isAlive = false
        }
        return true
    }

    public static func nearestPredator(
        to position: Vector2,
        predators: [Predator]
    ) -> (Predator, Double)? {
        var best: (Predator, Double)?
        for predator in predators where predator.isAlive {
            let dist = position.distance(to: predator.position)
            if best == nil || dist < best!.1 {
                best = (predator, dist)
            }
        }
        return best
    }
}

public enum SocialDefenseSystem {
    public static func predatorDamageMultiplier(
        for organism: Organism,
        nearbyOrganisms: [Organism]
    ) -> Double {
        guard organism.traits.socialBehavior > 0 else { return 1.0 }

        let hasNearbyAlly = nearbyOrganisms.contains { candidate in
            candidate.id != organism.id
                && candidate.isAlive
                && candidate.lineageID == organism.lineageID
                && candidate.position.distance(to: organism.position) <= SimulationTuning.socialDefenseRadius
        }
        guard hasNearbyAlly else { return 1.0 }

        let reduction = organism.traits.socialBehavior * SimulationTuning.maxSocialPredatorDamageReduction
        return 1.0 - reduction
    }
}

public enum ReproductionSystem {
    public static func isSafeSite(
        position: Vector2,
        predators: [Predator]
    ) -> Bool {
        for predator in predators where predator.isAlive {
            if position.distance(to: predator.position) < SimulationTuning.safeSiteMinDistanceFromPredator {
                return false
            }
        }
        return true
    }

    public static func isSafeSite(
        position: Vector2,
        predators: [Predator],
        terrain: TerrainType,
        traits: TraitSet
    ) -> Bool {
        guard isSafeSite(position: position, predators: predators) else { return false }
        return TerrainSystem.effects(for: terrain, traits: traits).damagePerTick <= 0
    }

    public static func reproduce(
        parent: inout Organism,
        rng: inout SeededRNG,
        idGenerator: inout EntityIDGenerator,
        predators: [Predator],
        bounds: WorldBounds? = nil,
        terrainField: TerrainField? = nil
    ) -> Organism? {
        guard parent.canReproduce else { return nil }
        if let terrainField {
            let parentTerrain = terrainField.terrain(at: parent.position)
            guard isSafeSite(
                position: parent.position,
                predators: predators,
                terrain: parentTerrain,
                traits: parent.traits
            ) else { return nil }
        } else {
            guard isSafeSite(position: parent.position, predators: predators) else { return nil }
        }

        parent.energy -= SimulationTuning.reproductionEnergyCost
        parent.offspringCount += 1

        let childTraits = parent.traits.inherited(from: parent.traits, rng: &rng)
        let childEnergy = SimulationTuning.baseEnergy * 0.5
            + parent.traits.parentalCare * 30
        let rawPosition = parent.position + Vector2(
            x: rng.nextDouble(in: -10...10),
            y: rng.nextDouble(in: -10...10)
        )
        let candidatePosition = bounds.map { rawPosition.clamped(to: $0) } ?? rawPosition
        let fallbackPosition = bounds.map { parent.position.clamped(to: $0) } ?? parent.position
        let childPosition: Vector2
        if let terrainField {
            let childTerrain = terrainField.terrain(at: candidatePosition)
            childPosition = isSafeSite(
                position: candidatePosition,
                predators: predators,
                terrain: childTerrain,
                traits: childTraits
            ) ? candidatePosition : fallbackPosition
        } else {
            childPosition = isSafeSite(position: candidatePosition, predators: predators)
                ? candidatePosition
                : fallbackPosition
        }

        let child = Organism(
            id: idGenerator.next(),
            position: childPosition,
            traits: childTraits,
            energy: childEnergy,
            generation: parent.generation + 1,
            lineageID: parent.lineageID
        )
        return child
    }
}

public enum FitnessSystem {
    public static func update(
        metrics: inout FitnessMetrics,
        organism: Organism,
        terrain: TerrainType,
        foodEaten: Bool,
        nearMiss: Bool,
        hit: Bool
    ) {
        if organism.isAlive {
            metrics.survivalTicks += 1
        }
        metrics.biomesExplored.insert(terrain)
        if foodEaten { metrics.foodConsumed += 1 }
        if nearMiss { metrics.predatorNearMisses += 1 }
        if hit { metrics.predatorHits += 1 }
        metrics.generationsReached = max(metrics.generationsReached, organism.generation)
    }
}

public enum EraSystem {
    public static func era(for fitness: Double) -> GameEra {
        if fitness >= SimulationTuning.era5FitnessThreshold { return .ecosystemDominance }
        if fitness >= SimulationTuning.era4FitnessThreshold { return .biomes }
        if fitness >= SimulationTuning.era3FitnessThreshold { return .landfall }
        if fitness >= SimulationTuning.era2FitnessThreshold { return .reefShallows }
        return .primordialPool
    }

    public static func checkVictory(
        goal: VictoryGoal,
        metrics: FitnessMetrics,
        livingPopulation: Int,
        tick: Int,
        massExtinctionActive: Bool
    ) -> Bool {
        switch goal {
        case .surviveMassExtinction:
            return massExtinctionActive && tick >= SimulationTuning.massExtinctionSurvivalTicks && livingPopulation > 0
        case .spreadToAllBiomes:
            return metrics.biomesExplored.count >= SimulationTuning.biomeSpreadVictoryCount
        case .reachPopulation:
            return livingPopulation >= SimulationTuning.populationVictoryCount
        case .evolveIntelligence:
            return metrics.generationsReached >= 10 && metrics.compositeScore >= 500
        }
    }
}
