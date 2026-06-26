import Foundation

/// Era-specific content configuration for post-MVP progression.
public enum EraContent {
    public static func apply(to state: inout SimulationState) {
        switch state.config.era {
        case .primordialPool:
            break
        case .reefShallows:
            state.terrain = TerrainField.mvpLayout(bounds: state.config.bounds)
        case .landfall:
            state.terrain = TerrainField.mvpLayout(bounds: state.config.bounds)
        case .biomes, .ecosystemDominance:
            state.terrain = TerrainField.eraExpandedLayout(bounds: state.config.bounds, era: state.config.era)
        }
    }

    public static func predatorCount(for era: GameEra) -> Int {
        switch era {
        case .primordialPool: return 3
        case .reefShallows: return 4
        case .landfall: return 5
        case .biomes: return 6
        case .ecosystemDominance: return 8
        }
    }

    /// Era-scaled chase speed; primordial ~31.5 vs baseline 70 at ecosystem dominance.
    public static func predatorSpeed(for era: GameEra) -> Double {
        SimulationTuning.predatorSpeed * speedMultiplier(for: era)
    }

    public static func predatorDamage(for era: GameEra) -> Double {
        SimulationTuning.predatorDamage * damageMultiplier(for: era)
    }

    public static func predatorSenseRadius(for era: GameEra) -> Double {
        SimulationTuning.predatorSenseRadius * senseMultiplier(for: era)
    }

    private static func speedMultiplier(for era: GameEra) -> Double {
        switch era {
        case .primordialPool: return SimulationTuning.predatorSpeedMultiplierPrimordial
        case .reefShallows: return SimulationTuning.predatorSpeedMultiplierReef
        case .landfall: return SimulationTuning.predatorSpeedMultiplierLandfall
        case .biomes: return SimulationTuning.predatorSpeedMultiplierBiomes
        case .ecosystemDominance: return SimulationTuning.predatorSpeedMultiplierEcosystem
        }
    }

    private static func damageMultiplier(for era: GameEra) -> Double {
        switch era {
        case .primordialPool: return SimulationTuning.predatorDamageMultiplierPrimordial
        case .reefShallows: return SimulationTuning.predatorDamageMultiplierReef
        case .landfall: return SimulationTuning.predatorDamageMultiplierLandfall
        case .biomes: return SimulationTuning.predatorDamageMultiplierBiomes
        case .ecosystemDominance: return SimulationTuning.predatorDamageMultiplierEcosystem
        }
    }

    private static func senseMultiplier(for era: GameEra) -> Double {
        switch era {
        case .primordialPool: return SimulationTuning.predatorSenseMultiplierPrimordial
        case .reefShallows: return SimulationTuning.predatorSenseMultiplierReef
        case .landfall: return SimulationTuning.predatorSenseMultiplierLandfall
        case .biomes: return SimulationTuning.predatorSenseMultiplierBiomes
        case .ecosystemDominance: return SimulationTuning.predatorSenseMultiplierEcosystem
        }
    }

    public static func foodCap(for era: GameEra) -> Int {
        switch era {
        case .primordialPool: return 30
        case .reefShallows: return 35
        case .landfall: return 40
        case .biomes: return 45
        case .ecosystemDominance: return 50
        }
    }

    public static func eraDescription(_ era: GameEra) -> String {
        switch era {
        case .primordialPool:
            return "Single-cell survival in the primordial pool. Food, toxins, and predators abound."
        case .reefShallows:
            return "Reef and shallows introduce movement and sense pressures."
        case .landfall:
            return "Amphibious evolution: moisture and terrain risk on land."
        case .biomes:
            return "Forest, desert, tundra, and more biomes unlock strategic adaptation."
        case .ecosystemDominance:
            return "Migration, rival pressures, and extinction events test your lineage."
        }
    }
}
