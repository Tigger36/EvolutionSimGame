import EvolutionSimCore

/// Player-facing predator threat derived from era progression and live predator state.
struct PredatorThreatPresentation: Equatable {
    let tierLabel: String
    let summary: String
    let relativeLevel: Int
    let livePredatorCount: Int
    let eraBaselineCount: Int
    let massExtinctionActive: Bool
    let era: GameEra

    static func make(from snapshot: SimulationSnapshot) -> PredatorThreatPresentation {
        let era = snapshot.era
        let massExtinctionActive = snapshot.massExtinctionActive
        return PredatorThreatPresentation(
            tierLabel: GameCopy.predatorThreatLabel(for: era, massExtinctionActive: massExtinctionActive),
            summary: GameCopy.predatorThreatSummary(for: era, massExtinctionActive: massExtinctionActive),
            relativeLevel: relativeLevel(for: era, massExtinctionActive: massExtinctionActive),
            livePredatorCount: snapshot.predators.filter(\.isAlive).count,
            eraBaselineCount: EraContent.predatorCount(for: era),
            massExtinctionActive: massExtinctionActive,
            era: era
        )
    }

    var activePredatorCaption: String {
        let count = livePredatorCount
        let noun = count == 1 ? "predator" : "predators"
        return "\(count) active \(noun)"
    }

    var accessibilityLabel: String {
        var parts = ["Predator threat", tierLabel, summary, activePredatorCaption]
        if massExtinctionActive {
            parts.append("Mass extinction event active")
        }
        return parts.joined(separator: ". ")
    }

    private static func relativeLevel(for era: GameEra, massExtinctionActive: Bool) -> Int {
        if massExtinctionActive { return 5 }
        switch era {
        case .primordialPool: return 1
        case .reefShallows: return 2
        case .landfall: return 3
        case .biomes: return 4
        case .ecosystemDominance: return 5
        }
    }
}
