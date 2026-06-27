import SwiftUI
import EvolutionSimCore

enum ContextualTip: String, Identifiable {
    case firstWater
    case firstToxic
    case firstMud
    case firstDamagingTerrain
    case firstReproductionReady
    case firstUnsafeReproductionBlocked
    case firstMutation
    case firstOffspringLoss
    case firstLineageHandoff
    case massExtinctionBegins
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
        case .firstDamagingTerrain: return "Damaging Terrain"
        case .firstReproductionReady: return "Ready to Reproduce"
        case .firstUnsafeReproductionBlocked: return "Unsafe Reproduction Site"
        case .firstMutation: return "Adaptation Choice"
        case .firstOffspringLoss: return "Offspring Lost"
        case .firstLineageHandoff: return "Lineage Handoff"
        case .massExtinctionBegins: return "Mass Extinction"
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
        case .firstDamagingTerrain:
            return "This terrain deals damage over time. Damaging terrain also blocks safe reproduction until you move to a safer site or evolve resistance."
        case .firstReproductionReady:
            return "Your organism will reproduce automatically at a safe site. Keep predators away and avoid damaging terrain so offspring can find food."
        case .firstUnsafeReproductionBlocked:
            return "Energy is high enough, but reproduction waits for a safe site. Move away from predators and damaging terrain — the HUD shows \"Safe Site Needed\" until conditions improve."
        case .firstMutation:
            return "Recent survival pressure shapes which adaptations appear. The mutation applies to the offspring, not the parent."
        case .firstOffspringLoss:
            return "A newborn did not survive. Reproduce near food, away from predators, and on non-damaging terrain. Parental Care and Enhanced Senses help offspring last longer."
        case .firstLineageHandoff:
            return "Your parent organism died, but control transferred to a living descendant. The lineage continues until every descendant is gone."
        case .massExtinctionBegins:
            return GameCopy.predatorThreatSummary(for: .ecosystemDominance, massExtinctionActive: true)
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
            case .desert, .tundra, .ice where shouldShow(.firstDamagingTerrain):
                if damagingTerrainTipApplies(for: terrain, snapshot: snapshot) {
                    return .firstDamagingTerrain
                }
            default: break
            }
        }

        if let player = snapshot.playerOrganism,
           player.canReproduce,
           !snapshot.playerCanReproduceSafely,
           shouldShow(.firstUnsafeReproductionBlocked) {
            return .firstUnsafeReproductionBlocked
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

    private func damagingTerrainTipApplies(for terrain: TerrainType, snapshot: SimulationSnapshot) -> Bool {
        guard let player = snapshot.playerOrganism else { return false }
        let damage = TerrainSystem.effectBreakdown(for: terrain, traits: player.traits).damage
        return damage > 0
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
            .accessibilityLabel("Dismiss tip")
            .accessibilityIdentifier("contextualTipDismissButton")
        }
        .padding(12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("contextualTipBanner")
        .accessibilityLabel("\(tip.title). \(tip.message)")
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
