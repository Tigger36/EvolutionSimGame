import SwiftUI
import Combine
import EvolutionSimCore

@MainActor
final class GameViewModel: ObservableObject {
    @Published private(set) var snapshot: SimulationSnapshot
    @Published var movementDirection: Vector2 = .zero
    @Published var showDebugOverlays = false
    @Published var selectedDebugOverlay: DebugOverlay = .none

    private let controller: SimulationController
    private var tickTimer: Timer?
    private var inputLog: [PlayerInput] = []

    init(config: SimulationConfig = SimulationConfig(seed: 42)) {
        controller = SimulationController(config: config)
        snapshot = controller.snapshot()
        startTickLoop()
    }

    deinit {
        tickTimer?.invalidate()
    }

    var controllerForSave: SimulationController { controller }

    func startTickLoop() {
        tickTimer?.invalidate()
        let interval = SimulationTuning.tickDuration / max(0.25, snapshot.speedMultiplier)
        tickTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    func tick() {
        guard snapshot.phase == .playing || snapshot.phase == .awaitingMutationChoice else { return }

        if snapshot.phase == .awaitingMutationChoice { return }

        let input = PlayerInput(movementDirection: movementDirection)
        inputLog.append(input)
        controller.step(input: input)
        snapshot = controller.snapshot()
    }

    func togglePause() {
        controller.setPaused(!snapshot.isPaused)
        snapshot = controller.snapshot()
    }

    func setSpeed(_ multiplier: Double) {
        controller.setSpeedMultiplier(multiplier)
        snapshot = controller.snapshot()
        startTickLoop()
    }

    func reset(seed: UInt64? = nil) {
        if let seed {
            controller.setSeed(seed)
        } else {
            controller.reset()
        }
        inputLog = []
        snapshot = controller.snapshot()
    }

    func stepOnce() {
        let wasPaused = snapshot.isPaused
        controller.setPaused(false)
        tick()
        controller.setPaused(wasPaused)
        snapshot = controller.snapshot()
    }

    func selectMutation(_ option: MutationOption) {
        controller.selectMutation(option)
        snapshot = controller.snapshot()
    }

    func saveSimulation() -> SavedSimulation {
        SavedSimulation(state: controller.state, inputLog: inputLog)
    }

    func biomeCompatibility(for organism: Organism) -> [(TerrainType, Double)] {
        TerrainType.allCases.map { terrain in
            (terrain, TerrainSystem.biomeCompatibility(traits: organism.traits, terrain: terrain))
        }
    }
}

enum DebugOverlay: String, CaseIterable, Identifiable {
    case none
    case foodDensity
    case dangerZones
    case terrainCost
    case lineage

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .none: return "None"
        case .foodDensity: return "Food Density"
        case .dangerZones: return "Danger Zones"
        case .terrainCost: return "Terrain Cost"
        case .lineage: return "Lineage"
        }
    }
}
