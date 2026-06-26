import Foundation

public struct Organism: Codable, Equatable, Sendable {
    public let id: EntityID
    public var position: Vector2
    public var velocity: Vector2
    public var traits: TraitSet
    public var energy: Double
    public var health: Double
    public var age: Int
    public var isAlive: Bool
    public var isPlayerControlled: Bool
    public var generation: Int
    public var offspringCount: Int
    public var lineageID: UInt64

    public init(
        id: EntityID,
        position: Vector2,
        traits: TraitSet = .default,
        energy: Double = SimulationTuning.baseEnergy,
        health: Double = SimulationTuning.baseHealth,
        isPlayerControlled: Bool = false,
        generation: Int = 1,
        lineageID: UInt64 = 1
    ) {
        self.id = id
        self.position = position
        self.velocity = .zero
        self.traits = traits
        self.energy = energy
        self.health = health
        self.age = 0
        self.isAlive = true
        self.isPlayerControlled = isPlayerControlled
        self.generation = generation
        self.offspringCount = 0
        self.lineageID = lineageID
    }

    public var radius: Double { traits.effectiveRadius }

    public var canReproduce: Bool {
        isAlive && energy >= traits.reproductionThreshold
    }
}

public struct FoodParticle: Codable, Equatable, Sendable {
    public let id: EntityID
    public var position: Vector2
    public var energyValue: Double

    public init(id: EntityID, position: Vector2, energyValue: Double = SimulationTuning.foodEnergyValue) {
        self.id = id
        self.position = position
        self.energyValue = energyValue
    }

    public var radius: Double { SimulationTuning.foodRadius }
}

public struct Predator: Codable, Equatable, Sendable {
    public let id: EntityID
    public var position: Vector2
    public var velocity: Vector2
    public var health: Double
    public var isAlive: Bool
    public var speed: Double
    public var senseRadius: Double
    public var damage: Double

    public init(
        id: EntityID,
        position: Vector2,
        speed: Double = SimulationTuning.predatorSpeed,
        senseRadius: Double = SimulationTuning.predatorSenseRadius,
        damage: Double = SimulationTuning.predatorDamage
    ) {
        self.id = id
        self.position = position
        self.velocity = .zero
        self.health = 100
        self.isAlive = true
        self.speed = speed
        self.senseRadius = senseRadius
        self.damage = damage
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(EntityID.self, forKey: .id)
        position = try container.decode(Vector2.self, forKey: .position)
        velocity = try container.decode(Vector2.self, forKey: .velocity)
        health = try container.decode(Double.self, forKey: .health)
        isAlive = try container.decode(Bool.self, forKey: .isAlive)
        speed = try container.decode(Double.self, forKey: .speed)
        senseRadius = try container.decodeIfPresent(Double.self, forKey: .senseRadius)
            ?? SimulationTuning.predatorSenseRadius
        damage = try container.decodeIfPresent(Double.self, forKey: .damage)
            ?? SimulationTuning.predatorDamage
    }

    public var radius: Double { SimulationTuning.predatorRadius }
}

public struct FitnessMetrics: Codable, Equatable, Sendable {
    public var survivalTicks: Int = 0
    public var totalOffspring: Int = 0
    public var foodConsumed: Int = 0
    public var biomesExplored: Set<TerrainType> = []
    public var predatorNearMisses: Int = 0
    public var predatorHits: Int = 0
    public var generationsReached: Int = 1

    public var compositeScore: Double {
        Double(survivalTicks) * 0.1
            + Double(totalOffspring) * 10
            + Double(foodConsumed) * 2
            + Double(biomesExplored.count) * 15
            + Double(predatorNearMisses) * 3
            - Double(predatorHits) * 5
            + Double(generationsReached) * 20
    }
}

public enum VictoryGoal: String, Codable, CaseIterable, Sendable {
    case surviveMassExtinction
    case spreadToAllBiomes
    case reachPopulation
    case evolveIntelligence

    public var displayName: String {
        switch self {
        case .surviveMassExtinction: return "Survive Mass Extinction"
        case .spreadToAllBiomes: return "Spread to All Biomes"
        case .reachPopulation: return "Reach Target Population"
        case .evolveIntelligence: return "Evolve Intelligence"
        }
    }
}

public struct LineageSummary: Codable, Equatable, Sendable {
    public var lineageID: UInt64
    public var generation: Int
    public var livingCount: Int
    public var totalBorn: Int
    public var fitness: FitnessMetrics
    public var dominantTraits: TraitSet
}
