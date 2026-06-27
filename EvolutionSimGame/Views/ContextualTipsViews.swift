import SwiftUI
import EvolutionSimCore

enum ContextualTip: String, Identifiable {
    case firstWater
    case firstToxic
    case firstMud
    case firstReproductionReady
    case firstMutation
    case firstLineageHandoff
    case eraAdvanceReefShallows
    case eraAdvanceLandfall
    case eraAdvanceBiomes
    case eraAdvanceEcosystemDominance

    var id: String { rawValue }

    var title: String {
        if let era = associatedEra {
            return GameCopy.eraAdvanceTipTitle(for: era)
        }
        switch self {
        case .firstWater: return "Water Terrain"
        case .firstToxic: return "Toxic Pool"
        case .firstMud: return "Mud Terrain"
        case .firstReproductionReady: return "Ready to Reproduce"
        case .firstMutation: return "Adaptation Choice"
        case .firstLineageHandoff: return "Lineage Handoff"
        default: return ""
        }
    }

    var message: String {
        if let era = associatedEra {
            return GameCopy.eraAdvanceTipMessage(for: era)
        }
        switch self {
        case .firstWater:
            return TerrainSystem.playerFacingSummary(for: .water)
        case .firstToxic:
            return TerrainSystem.playerFacingSummary(for: .toxicPool)
        case .firstMud:
            return TerrainSystem.playerFacingSummary(for: .mud)
        case .firstReproductionReady:
            return "Your organism will reproduce automatically at a safe site. Keep predators away and avoid damaging terrain so offspring can find food."
        case .firstMutation:
            return "Recent survival pressure shapes which adaptations appear. The mutation applies to the offspring, not the parent."
        case .firstLineageHandoff:
            return "Control transferred to a descendant. Your lineage continues even when individuals die."
        default: return ""
        }
    }

    var associatedEra: GameEra? {
        switch self {
        case .eraAdvanceReefShallows: return .reefShallows
        case .eraAdvanceLandfall: return .landfall
        case .eraAdvanceBiomes: return .biomes
        case .eraAdvanceEcosystemDominance: return .ecosystemDominance
        default: return nil
        }
    }

    static func eraAdvanceTip(for era: GameEra) -> ContextualTip? {
        switch era {
        case .primordialPool: return nil
        case .reefShallows: return .eraAdvanceReefShallows
        case .landfall: return .eraAdvanceLandfall
        case .biomes: return .eraAdvanceBiomes
        case .ecosystemDominance: return .eraAdvanceEcosystemDominance
        }
    }

    static func eraAdvanceTipForForwardAdvance(from oldEra: GameEra, to newEra: GameEra) -> ContextualTip? {
        guard newEra.rawValue > oldEra.rawValue, newEra != .primordialPool else { return nil }
        return eraAdvanceTip(for: newEra)
    }
}

struct EraAdvanceTipCoordinator {
    private(set) var pendingTip: ContextualTip?

    mutating func registerForwardAdvance(
        from oldEra: GameEra,
        to newEra: GameEra,
        shouldShow: (ContextualTip) -> Bool
    ) {
        guard let tip = ContextualTip.eraAdvanceTipForForwardAdvance(from: oldEra, to: newEra),
              shouldShow(tip) else { return }
        pendingTip = tip
    }

    mutating func consumePendingTip(if shouldShow: (ContextualTip) -> Bool) -> ContextualTip? {
        guard let pending = pendingTip, shouldShow(pending) else { return nil }
        pendingTip = nil
        return pending
    }

    mutating func reset() {
        pendingTip = nil
    }
}

@MainActor
final class ContextualTipsManager {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func shouldShow(_ tip: ContextualTip) -> Bool {
        !defaults.bool(forKey: storageKey(for: tip))
    }

    func markShown(_ tip: ContextualTip) {
        defaults.set(true, forKey: storageKey(for: tip))
    }

    func tipFor(
        snapshot: SimulationSnapshot,
        previousPhase: SimulationPhase?,
        generationChanged: Bool
    ) -> ContextualTip? {
        if let terrain = snapshot.playerCurrentTerrain {
            switch terrain {
            case .water where shouldShow(.firstWater): return .firstWater
            case .toxicPool where shouldShow(.firstToxic): return .firstToxic
            case .mud where shouldShow(.firstMud): return .firstMud
            default: break
            }
        }

        if snapshot.playerCanReproduceSafely, shouldShow(.firstReproductionReady) {
            return .firstReproductionReady
        }

        if previousPhase != .awaitingMutationChoice,
           snapshot.phase == .awaitingMutationChoice,
           shouldShow(.firstMutation) {
            return .firstMutation
        }

        if generationChanged, shouldShow(.firstLineageHandoff) {
            return .firstLineageHandoff
        }

        return nil
    }

    private func storageKey(for tip: ContextualTip) -> String {
        "contextualTipShown_\(tip.rawValue)"
    }
}

struct ContextualTipBanner: View {
    let tip: ContextualTip
    let onDismiss: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(tip.title)
                    .font(.subheadline.bold())
                Text(tip.message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                onDismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
        .accessibilityIdentifier("contextualTipBanner")
    }
}

struct FeedbackBanner: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.subheadline.bold())
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.green.opacity(0.85), in: Capsule())
            .foregroundStyle(.white)
            .accessibilityIdentifier("feedbackBanner")
    }
}

struct TerrainEntryBanner: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.caption.bold())
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: Capsule())
            .accessibilityIdentifier("terrainEntryBanner")
    }
}
