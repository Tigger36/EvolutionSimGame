import EvolutionSimCore

enum GameCopy {
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
