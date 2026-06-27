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
            return "Grow your lineage to 12 living organisms."
        case .evolveIntelligence:
            return "Reach generation 5 with a fitness score of 1200+."
        }
    }

    static func extinctionMessage(totalBorn: Int, generation: Int) -> String {
        if totalBorn == 0 {
            return "Your lineage died out before reproducing. Gather energy, avoid predators, and reproduce at a safe site to continue the lineage."
        }
        return "Every descendant has died. Your lineage reached generation \(generation) with \(totalBorn) offspring born. Start a new run to try a different strategy."
    }

    static func seedExplanation(useRandomSeed: Bool) -> String {
        if useRandomSeed {
            return "A random seed creates a unique world layout each run. Share the seed after starting if you want to replay the same world."
        }
        return "A fixed seed recreates the same world layout every time — useful for learning routes or reporting bugs."
    }

    static func eraProgressionExplanation() -> String {
        "Fitness from survival, offspring, food, biomes, and predator near-misses advances eras. Higher eras bring faster, tougher predators."
    }

    static func massExtinctionExplanation(enabled: Bool) -> String {
        if enabled {
            return "Around tick 2000, predators surge and the world tint shifts. Survive through tick 3000 to win the mass-extinction goal."
        }
        return "Mass extinction events are disabled for this run."
    }

    static func tutorialPresetExplanation() -> String {
        "The tutorial uses seed 1001 with capped predators and no mass extinction. Standard new games use your chosen seed and settings."
    }

    static func mutationAccessibilityLabel(
        option: MutationOption,
        baseTraits: TraitSet
    ) -> String {
        let statChanges = MutationPreview.formattedTraitDeltas(option: option, base: baseTraits)
        let biomeImpact = MutationPreview.formattedBiomeImpact(option: option, base: baseTraits)
        var parts = [option.displayName, option.description]
        if !statChanges.isEmpty {
            parts.append("Stat changes: \(statChanges)")
        }
        parts.append("Biome impact: \(biomeImpact)")
        return parts.joined(separator: ". ")
    }

    static func mutationCostSummary(for option: MutationOption) -> String {
        switch option {
        case .stayGeneralized:
            return "Balanced — no major tradeoff."
        case .parentalCareBoost:
            return "Cost: slightly harder future reproduction."
        case .herdInstinct:
            return "Cost: minor energy spent on social sensing."
        default:
            if option.description.contains("worse") || option.description.contains("slower")
                || option.description.contains("hungrier") || option.description.contains("higher energy") {
                return "Cost: \(option.description)"
            }
            return "Tradeoff: \(option.description)"
        }
    }
}
