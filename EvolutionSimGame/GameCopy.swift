import EvolutionSimCore

enum GameCopy {
    static func predatorThreatLabel(for era: GameEra, massExtinctionActive: Bool) -> String {
        if massExtinctionActive {
            return "Critical — Mass Extinction"
        }
        switch era {
        case .primordialPool: return "Low"
        case .reefShallows: return "Moderate"
        case .landfall: return "Elevated"
        case .biomes: return "High"
        case .ecosystemDominance: return "Extreme"
        }
    }

    static func eraAdvanceTipTitle(for era: GameEra) -> String {
        "New Era: \(era.displayName)"
    }

    static func eraAdvanceTipMessage(for era: GameEra) -> String {
        predatorThreatSummary(for: era, massExtinctionActive: false)
    }

    static func predatorThreatSummary(for era: GameEra, massExtinctionActive: Bool) -> String {
        if massExtinctionActive {
            return "Predators move faster and chase more aggressively during the extinction event."
        }
        switch era {
        case .primordialPool:
            return "Predators hunt less aggressively and notice you from shorter range."
        case .reefShallows:
            return "Predators are more alert and a bit faster as shallow waters grow crowded."
        case .landfall:
            return "More predators roam the world, with wider awareness and sharper pursuit."
        case .biomes:
            return "Predators are faster, more numerous, and harder to evade across diverse biomes."
        case .ecosystemDominance:
            return "Peak predator pressure — fast hunters with long range and heavy damage."
        }
    }

    static func victoryGoalDescription(_ goal: VictoryGoal) -> String {
        switch goal {
        case .surviveMassExtinction:
            return "Survive the mass extinction event that begins around tick 2000."
        case .spreadToAllBiomes:
            return "Explore and adapt to at least 6 different biome types."
        case .reachPopulation:
            return "Grow your lineage to 15 living organisms."
        case .evolveIntelligence:
            return "Reach generation 10 with a fitness score of 500+."
        }
    }
}
