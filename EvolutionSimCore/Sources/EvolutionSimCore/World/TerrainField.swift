import Foundation

public enum TerrainType: String, Codable, CaseIterable, Sendable {
    case land
    case water
    case mud
    case toxicPool
    // Phase 5 expanded terrain
    case forest
    case swamp
    case desert
    case tundra
    case mountain
    case ice

    public var displayName: String {
        switch self {
        case .land: return "Land"
        case .water: return "Water"
        case .mud: return "Mud"
        case .toxicPool: return "Toxic Pool"
        case .forest: return "Forest"
        case .swamp: return "Swamp"
        case .desert: return "Desert"
        case .tundra: return "Tundra"
        case .mountain: return "Mountain"
        case .ice: return "Ice"
        }
    }

    public var isMVPTerrain: Bool {
        switch self {
        case .land, .water, .mud, .toxicPool: return true
        default: return false
        }
    }
}

public struct TerrainRegion: Codable, Equatable, Sendable {
    public let type: TerrainType
    public let center: Vector2
    public let radius: Double

    public init(type: TerrainType, center: Vector2, radius: Double) {
        self.type = type
        self.center = center
        self.radius = radius
    }

    public func contains(_ point: Vector2) -> Bool {
        point.distance(to: center) <= radius
    }
}

public struct TerrainField: Codable, Equatable, Sendable {
    public var defaultType: TerrainType
    public var regions: [TerrainRegion]

    public init(defaultType: TerrainType = .land, regions: [TerrainRegion] = []) {
        self.defaultType = defaultType
        self.regions = regions
    }

    public func terrain(at point: Vector2) -> TerrainType {
        for region in regions.reversed() where region.contains(point) {
            return region.type
        }
        return defaultType
    }

    public static func mvpLayout(bounds: WorldBounds) -> TerrainField {
        let cx = bounds.center.x
        let cy = bounds.center.y
        return TerrainField(
            defaultType: .land,
            regions: [
                TerrainRegion(type: .water, center: Vector2(x: cx * 0.35, y: cy), radius: 120),
                TerrainRegion(type: .mud, center: Vector2(x: cx * 1.4, y: cy * 0.85), radius: 90),
                TerrainRegion(type: .toxicPool, center: Vector2(x: cx * 1.5, y: cy * 0.35), radius: 70),
            ]
        )
    }

    public static func eraExpandedLayout(bounds: WorldBounds, era: GameEra) -> TerrainField {
        var field = mvpLayout(bounds: bounds)
        guard era.rawValue >= GameEra.biomes.rawValue else { return field }

        let cx = bounds.center.x
        let cy = bounds.center.y
        field.regions.append(contentsOf: [
            TerrainRegion(type: .forest, center: Vector2(x: cx * 0.6, y: cy * 1.3), radius: 100),
            TerrainRegion(type: .swamp, center: Vector2(x: cx * 0.9, y: cy * 1.1), radius: 80),
            TerrainRegion(type: .desert, center: Vector2(x: cx * 1.7, y: cy * 1.2), radius: 90),
            TerrainRegion(type: .tundra, center: Vector2(x: cx * 0.5, y: cy * 0.3), radius: 85),
            TerrainRegion(type: .mountain, center: Vector2(x: cx * 1.3, y: cy * 0.25), radius: 75),
            TerrainRegion(type: .ice, center: Vector2(x: cx * 0.25, y: cy * 0.2), radius: 70),
        ])
        return field
    }
}

public enum GameEra: Int, Codable, CaseIterable, Sendable {
    case primordialPool = 1
    case reefShallows = 2
    case landfall = 3
    case biomes = 4
    case ecosystemDominance = 5

    public var displayName: String {
        switch self {
        case .primordialPool: return "Primordial Pool"
        case .reefShallows: return "Reef / Shallows"
        case .landfall: return "Landfall"
        case .biomes: return "Biomes"
        case .ecosystemDominance: return "Ecosystem Dominance"
        }
    }
}

public struct TerrainEffects: Sendable {
    public let speedMultiplier: Double
    public let energyDrainMultiplier: Double
    public let damagePerTick: Double

    public static let neutral = TerrainEffects(speedMultiplier: 1, energyDrainMultiplier: 1, damagePerTick: 0)
}

public enum TerrainSystem {
    public static func effects(for terrain: TerrainType, traits: TraitSet) -> TerrainEffects {
        switch terrain {
        case .land:
            let penalty = max(0.5, 1.0 - traits.swimEfficiency * 0.3)
            return TerrainEffects(speedMultiplier: penalty, energyDrainMultiplier: 1.0, damagePerTick: 0)
        case .water:
            let swimBonus = 0.6 + traits.swimEfficiency * 0.5
            let landPenalty = max(0.3, swimBonus)
            return TerrainEffects(speedMultiplier: landPenalty, energyDrainMultiplier: 0.9, damagePerTick: 0)
        case .mud:
            let slowFactor = max(0.35, 0.7 - traits.size * 0.05)
            return TerrainEffects(speedMultiplier: slowFactor, energyDrainMultiplier: 1.3, damagePerTick: 0)
        case .toxicPool:
            let resistance = traits.toxinResistance
            let damage = max(0, SimulationTuning.toxicDamagePerTick * (1.0 - resistance))
            let drain = 1.0 + (1.0 - resistance) * 0.5
            return TerrainEffects(speedMultiplier: 0.6, energyDrainMultiplier: drain, damagePerTick: damage)
        case .forest:
            let camouflage = traits.senseRadius > 0.6 ? 1.05 : 0.85
            return TerrainEffects(speedMultiplier: camouflage, energyDrainMultiplier: 1.1, damagePerTick: 0)
        case .swamp:
            let amphibious = traits.swimEfficiency > 0.5 ? 0.9 : 0.5
            return TerrainEffects(speedMultiplier: amphibious, energyDrainMultiplier: 1.4, damagePerTick: 0)
        case .desert:
            let heatTol = traits.metabolism > 0.5 ? 0.85 : 0.55
            return TerrainEffects(speedMultiplier: heatTol, energyDrainMultiplier: 1.6, damagePerTick: 0.02)
        case .tundra:
            let coldTol = traits.metabolism < 0.5 ? 0.9 : 0.6
            return TerrainEffects(speedMultiplier: coldTol, energyDrainMultiplier: 1.3, damagePerTick: 0.01)
        case .mountain:
            let grip = max(0.4, 1.0 - traits.size * 0.08)
            return TerrainEffects(speedMultiplier: grip, energyDrainMultiplier: 1.5, damagePerTick: 0)
        case .ice:
            let insulated = traits.armor > 0.4 ? 0.75 : 0.45
            return TerrainEffects(speedMultiplier: insulated, energyDrainMultiplier: 1.2, damagePerTick: 0.015)
        }
    }

    public static func biomeCompatibility(traits: TraitSet, terrain: TerrainType) -> Double {
        let effects = effects(for: terrain, traits: traits)
        let speedScore = effects.speedMultiplier
        let drainScore = 1.0 / max(0.1, effects.energyDrainMultiplier)
        let damageScore = effects.damagePerTick <= 0 ? 1.0 : max(0, 1.0 - effects.damagePerTick * 10)
        return min(1.0, (speedScore + drainScore + damageScore) / 3.0)
    }

    public static func playerFacingSummary(for terrain: TerrainType) -> String {
        switch terrain {
        case .land:
            return "Baseline terrain; high swim efficiency slows land movement."
        case .water:
            return "Favors swim adaptations; slows land-focused builds."
        case .mud:
            return "Slows movement and drains energy; smaller size helps."
        case .toxicPool:
            return "Damage over time; raise Toxin Resistance to survive."
        case .forest:
            return "Dense cover; high sense radius improves movement."
        case .swamp:
            return "Slow and draining; swim efficiency helps."
        case .desert:
            return "Hot and draining; efficient metabolism helps."
        case .tundra:
            return "Cold terrain; lower metabolism adapts better."
        case .mountain:
            return "Steep and draining; smaller size climbs easier."
        case .ice:
            return "Slippery and cold; armor improves grip."
        }
    }

    public static func entryMessage(for terrain: TerrainType) -> String {
        switch terrain {
        case .land:
            return "On Land — standard movement and energy use."
        case .water:
            return "Entered Water — movement slows unless adapted."
        case .mud:
            return "Entered Mud — slower movement and higher energy drain."
        case .toxicPool:
            return "Entered Toxic Pool — damage over time without resistance."
        case .forest:
            return "Entered Forest — cover affects movement speed."
        case .swamp:
            return "Entered Swamp — slow and energy-intensive."
        case .desert:
            return "Entered Desert — high heat drains energy quickly."
        case .tundra:
            return "Entered Tundra — cold slows unprepared organisms."
        case .mountain:
            return "Entered Mountain — steep terrain slows large builds."
        case .ice:
            return "Entered Ice — slippery and damaging without armor."
        }
    }

    public static func effectBreakdown(for terrain: TerrainType, traits: TraitSet) -> (speed: Double, energyDrain: Double, damage: Double) {
        let effects = effects(for: terrain, traits: traits)
        return (effects.speedMultiplier, effects.energyDrainMultiplier, effects.damagePerTick)
    }
}
