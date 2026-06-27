import SwiftUI
import EvolutionSimCore

enum TutorialStep: Int, CaseIterable, Identifiable {
    case move
    case eatFood
    case avoidPredators
    case terrainBasics
    case reproduce
    case chooseMutation
    case lineageHandoff
    case victoryGoals

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .move: return "Move Your Organism"
        case .eatFood: return "Gather Energy"
        case .avoidPredators: return "Avoid Predators"
        case .terrainBasics: return "Explore Terrain"
        case .reproduce: return "Reproduce"
        case .chooseMutation: return "Choose an Adaptation"
        case .lineageHandoff: return "Lineage Continues"
        case .victoryGoals: return "Victory Goals"
        }
    }

    var message: String {
        switch self {
        case .move:
            return "Use the movement controls below to explore. Move away from the starting spot."
        case .eatFood:
            return "Swim toward green food particles. Eating raises your energy bar."
        case .avoidPredators:
            return "Red predators chase you and reduce health. Use your sense radius to flee early."
        case .terrainBasics:
            return "Enter a colored terrain region. The biome chip shows speed, energy, or damage tradeoffs."
        case .reproduce:
            return "Reproduction is automatic when energy is high and the site is safe. Watch for the ready badge."
        case .chooseMutation:
            return "Pick one adaptation for the offspring. You keep playing as the parent after the choice."
        case .lineageHandoff:
            return "If your organism dies after reproducing, control passes to a living descendant. Keep offspring alive with safe terrain, food, and protective traits."
        case .victoryGoals:
            return "Full runs let you pick a victory goal: spread across biomes, grow population, evolve intelligence, or survive mass extinction. This tutorial uses seed 1001 with reduced predators, no mass extinction, and a population goal."
        }
    }

    var requiresManualContinue: Bool {
        switch self {
        case .avoidPredators, .lineageHandoff, .victoryGoals: return true
        default: return false
        }
    }

    func isComplete(snapshot: SimulationSnapshot, context: TutorialContext) -> Bool {
        switch self {
        case .move:
            guard let start = context.startPosition, let player = snapshot.playerOrganism else { return false }
            return player.position.distance(to: start) > 25
        case .eatFood:
            guard let baseline = context.baselineEnergy, let player = snapshot.playerOrganism else { return false }
            return player.energy > baseline + 5
        case .avoidPredators:
            return context.manualContinue
        case .terrainBasics:
            guard let terrain = snapshot.playerCurrentTerrain else { return false }
            return terrain != .land
        case .reproduce:
            return snapshot.phase == .awaitingMutationChoice || snapshot.lineage.totalBorn > 0
        case .chooseMutation:
            return context.mutationCompleted
        case .lineageHandoff:
            return context.manualContinue
        case .victoryGoals:
            return context.manualContinue
        }
    }
}

struct TutorialContext {
    var startPosition: Vector2?
    var baselineEnergy: Double?
    var manualContinue = false
    var mutationCompleted = false
}

struct TutorialCalloutView: View {
    let step: TutorialStep
    let onContinue: () -> Void
    let onSkip: () -> Void

    var body: some View {
        VStack {
            Spacer()
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Tutorial")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("Step \(step.rawValue + 1) of \(TutorialStep.allCases.count)")
                        .font(.caption.monospaced())
                        .foregroundStyle(.secondary)
                }

                Text(step.title)
                    .font(.headline)

                Text(step.message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack {
                    if step.requiresManualContinue {
                        Button("Continue", action: onContinue)
                            .buttonStyle(.borderedProminent)
                            .accessibilityIdentifier("tutorialContinueButton")
                    }
                    Spacer()
                    Button("Skip Tutorial", action: onSkip)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .accessibilityIdentifier("tutorialSkipButton")
                }
            }
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            .padding()
        }
        .allowsHitTesting(true)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("tutorialCallout")
        .accessibilityLabel("Tutorial step \(step.rawValue + 1) of \(TutorialStep.allCases.count). \(step.title). \(step.message)")
    }
}
