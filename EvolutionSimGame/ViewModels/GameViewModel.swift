import SwiftUI
import Combine
import EvolutionSimCore

enum AppPhase: Equatable {
    case startScreen
    case newGameSetup(skippedTutorial: Bool)
    case tutorial
    case playing
}

@MainActor
final class GameViewModel: ObservableObject {
    @Published private(set) var snapshot: SimulationSnapshot
    @Published var movementDirection: Vector2 = .zero
    @Published var showDebugOverlays = false
    @Published var selectedDebugOverlay: DebugOverlay = .none
    @Published var appPhase: AppPhase = .startScreen
    @Published var showHowToPlay = false
    @Published var showBiomeFitOverlay = false
    @Published var showTerrainLegend = true
    @Published var terrainEntryBanner: String?
    @Published var mutationFeedback: String?
    @Published var contextualTip: ContextualTip?
    @Published var tutorialStep: TutorialStep?
    @Published var tutorialContext = TutorialContext()

    @Published var preferSkipTutorial: Bool {
        didSet { UserDefaults.standard.set(preferSkipTutorial, forKey: Self.preferSkipTutorialKey) }
    }

    private let controller: SimulationController
    private var tickTimer: Timer?
    private var inputLog: [PlayerInput] = []
    private var lastTerrain: TerrainType?
    private var previousPhase: SimulationPhase?
    private var previousPlayerGeneration: Int?
    private var previousEra: GameEra?
    private var previousTotalBorn: Int = 0
    private var previousLivingCount: Int = 0
    private var previousMassExtinctionActive: Bool = false
    private var hasPresentedMutationChoiceThisRun = false
    private var deferredMutationPresentationTicks = 0
    private var eraAdvanceTipCoordinator = EraAdvanceTipCoordinator()
    private var feedbackClearTask: Task<Void, Never>?
    private var terrainBannerClearTask: Task<Void, Never>?
    private let contextualTips = ContextualTipsManager()

    private static let preferSkipTutorialKey = "preferSkipTutorial"
    private static let hasCompletedTutorialKey = "hasCompletedTutorial"
    private static let terrainLegendDismissedKey = "terrainLegendDismissed"
    /// UI-only deferral: first mutation modal waits this many timer callbacks while sim is
    /// `.awaitingMutationChoice` in normal play (sim ticks do not advance during that phase).
    static let firstMutationMinimumTick = 60

    init(config: SimulationConfig = SimulationConfig(seed: 42)) {
        controller = SimulationController(config: config)
        snapshot = controller.snapshot()
        preferSkipTutorial = UserDefaults.standard.bool(forKey: Self.preferSkipTutorialKey)
        showTerrainLegend = !UserDefaults.standard.bool(forKey: Self.terrainLegendDismissedKey)
        controller.setPaused(true)
        previousPhase = snapshot.phase
        previousPlayerGeneration = snapshot.playerOrganism?.generation
        previousEra = snapshot.era
        previousTotalBorn = snapshot.lineage.totalBorn
        previousLivingCount = snapshot.lineage.livingCount
        previousMassExtinctionActive = snapshot.massExtinctionActive
    }

    /// Whether the mutation choice modal should be shown (UI-only gating; sim may already be `.awaitingMutationChoice`).
    var shouldPresentMutationChoice: Bool {
        meetsMutationStepRequirement && !isMutationPresentationDeferred
    }

    /// True while the sim waits for a mutation choice but the UI intentionally hides the modal.
    private var isMutationPresentationDeferred: Bool {
        guard snapshot.phase == .awaitingMutationChoice else { return false }

        if appPhase == .tutorial {
            guard let step = tutorialStep else { return true }
            return step.rawValue < TutorialStep.chooseMutation.rawValue
        }

        if appPhase == .playing {
            if hasPresentedMutationChoiceThisRun { return false }
            return deferredMutationPresentationTicks < Self.firstMutationMinimumTick
        }

        return true
    }

    /// Tutorial step / phase eligibility for ever showing the mutation modal.
    private var meetsMutationStepRequirement: Bool {
        guard snapshot.phase == .awaitingMutationChoice else { return false }

        if appPhase == .tutorial {
            guard let step = tutorialStep else { return false }
            return step.rawValue >= TutorialStep.chooseMutation.rawValue
        }

        return appPhase == .playing
    }

    deinit {
        tickTimer?.invalidate()
    }

    var controllerForSave: SimulationController { controller }

    var isTickLoopActive: Bool {
        tickTimer != nil
    }

    func startTickLoop() {
        tickTimer?.invalidate()
        let interval = SimulationTuning.tickDuration / max(0.25, snapshot.speedMultiplier)
        tickTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    func stopTickLoop() {
        tickTimer?.invalidate()
        tickTimer = nil
    }

    func tick() {
        guard appPhase == .playing || appPhase == .tutorial else { return }
        guard snapshot.phase == .playing || snapshot.phase == .awaitingMutationChoice else { return }

        if snapshot.phase == .awaitingMutationChoice {
            if isMutationPresentationDeferred {
                let input = PlayerInput(movementDirection: movementDirection)
                inputLog.append(input)
                controller.stepDuringDeferredMutationPresentation(input: input)
                if appPhase == .playing, !hasPresentedMutationChoiceThisRun {
                    deferredMutationPresentationTicks += 1
                }
                updateSnapshot()
                return
            }
            markMutationChoicePresentedIfNeeded()
            return
        }

        let input = PlayerInput(movementDirection: movementDirection)
        inputLog.append(input)
        controller.step(input: input)
        updateSnapshot()
    }

    private func markMutationChoicePresentedIfNeeded() {
        if shouldPresentMutationChoice {
            hasPresentedMutationChoiceThisRun = true
        }
    }

    private func updateSnapshot() {
        let oldPhase = snapshot.phase
        let oldGeneration = snapshot.playerOrganism?.generation
        let oldEra = snapshot.era
        let oldTotalBorn = snapshot.lineage.totalBorn
        let oldLivingCount = snapshot.lineage.livingCount
        let oldMassExtinctionActive = snapshot.massExtinctionActive
        snapshot = controller.snapshot()
        updateTerrainFeedback()
        updateContextualTips(
            previousPhase: oldPhase,
            generationChanged: oldGeneration != snapshot.playerOrganism?.generation,
            previousEra: oldEra,
            totalBornIncreased: snapshot.lineage.totalBorn > oldTotalBorn,
            previousLivingCount: oldLivingCount,
            massExtinctionJustStarted: !oldMassExtinctionActive && snapshot.massExtinctionActive
        )
        if shouldPresentMutationChoice {
            hasPresentedMutationChoiceThisRun = true
        }
        previousPhase = snapshot.phase
        previousPlayerGeneration = snapshot.playerOrganism?.generation
        previousEra = snapshot.era
        previousTotalBorn = snapshot.lineage.totalBorn
        previousLivingCount = snapshot.lineage.livingCount
        previousMassExtinctionActive = snapshot.massExtinctionActive
        evaluateTutorialProgress()
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
        lastTerrain = nil
        terrainEntryBanner = nil
        mutationFeedback = nil
        contextualTip = nil
        eraAdvanceTipCoordinator.reset()
        hasPresentedMutationChoiceThisRun = false
        deferredMutationPresentationTicks = 0
        snapshot = controller.snapshot()
        previousPhase = snapshot.phase
        previousPlayerGeneration = snapshot.playerOrganism?.generation
        previousEra = snapshot.era
        previousTotalBorn = snapshot.lineage.totalBorn
        previousLivingCount = snapshot.lineage.livingCount
        previousMassExtinctionActive = snapshot.massExtinctionActive
    }

    func resetToStartScreen() {
        stopTickLoop()
        controller.setPaused(true)
        reset(seed: 42)
        appPhase = .startScreen
        tutorialStep = nil
        tutorialContext = TutorialContext()
        showBiomeFitOverlay = false
    }

    func stepOnce() {
        let wasPaused = snapshot.isPaused
        controller.setPaused(false)
        tick()
        controller.setPaused(wasPaused)
        updateSnapshot()
    }

    func selectMutation(_ option: MutationOption) {
        controller.selectMutation(option)
        mutationFeedback = "Offspring adapted: \(option.displayName)"
        scheduleFeedbackClear()
        if appPhase == .tutorial {
            tutorialContext.mutationCompleted = true
            evaluateTutorialProgress()
        }
        updateSnapshot()
    }

    func saveSimulation() -> SavedSimulation {
        SavedSimulation(state: controller.state, inputLog: inputLog)
    }

    func biomeCompatibility(for organism: Organism) -> [(TerrainType, Double)] {
        TerrainType.allCases.map { terrain in
            (terrain, TerrainSystem.biomeCompatibility(traits: organism.traits, terrain: terrain))
        }
    }

    func terrainEffectBreakdown(for organism: Organism, terrain: TerrainType) -> (speed: Double, energyDrain: Double, damage: Double) {
        TerrainSystem.effectBreakdown(for: terrain, traits: organism.traits)
    }

    // MARK: - App flow

    func beginTutorial() {
        preferSkipTutorial = false
        controller.reset(config: SimulationConfig.tutorialPreset())
        snapshot = controller.snapshot()
        lastTerrain = snapshot.playerCurrentTerrain
        tutorialContext = TutorialContext(
            startPosition: snapshot.playerOrganism?.position,
            baselineEnergy: snapshot.playerOrganism?.energy
        )
        tutorialStep = .move
        appPhase = .tutorial
        showBiomeFitOverlay = true
        hasPresentedMutationChoiceThisRun = false
        deferredMutationPresentationTicks = 0
        previousPhase = snapshot.phase
        previousPlayerGeneration = snapshot.playerOrganism?.generation
        previousEra = snapshot.era
        previousTotalBorn = snapshot.lineage.totalBorn
        previousLivingCount = snapshot.lineage.livingCount
        previousMassExtinctionActive = snapshot.massExtinctionActive
        controller.setPaused(false)
        startTickLoop()
    }

    func skipTutorial() {
        preferSkipTutorial = true
        stopTickLoop()
        controller.setPaused(true)
        appPhase = .newGameSetup(skippedTutorial: true)
        tutorialStep = nil
    }

    func finishTutorialAndContinuePlaying() {
        UserDefaults.standard.set(true, forKey: Self.hasCompletedTutorialKey)
        stopTickLoop()
        controller.setPaused(true)
        appPhase = .newGameSetup(skippedTutorial: false)
        tutorialStep = nil
        showBiomeFitOverlay = false
    }

    func startGame(config: SimulationConfig) {
        stopTickLoop()
        controller.reset(config: config)
        snapshot = controller.snapshot()
        lastTerrain = snapshot.playerCurrentTerrain
        previousPhase = snapshot.phase
        previousPlayerGeneration = snapshot.playerOrganism?.generation
        previousEra = snapshot.era
        previousTotalBorn = snapshot.lineage.totalBorn
        previousLivingCount = snapshot.lineage.livingCount
        previousMassExtinctionActive = snapshot.massExtinctionActive
        appPhase = .playing
        tutorialStep = nil
        hasPresentedMutationChoiceThisRun = false
        deferredMutationPresentationTicks = 0
        controller.setPaused(false)
        startTickLoop()
    }

    func goToNewGameSetup(skippedTutorial: Bool) {
        stopTickLoop()
        controller.setPaused(true)
        appPhase = .newGameSetup(skippedTutorial: skippedTutorial)
    }

    func dismissTerrainLegend() {
        showTerrainLegend = false
        UserDefaults.standard.set(true, forKey: Self.terrainLegendDismissedKey)
    }

    func dismissContextualTip() {
        if let tip = contextualTip {
            contextualTips.markShown(tip)
        }
        contextualTip = nil
        presentPendingEraAdvanceTipIfNeeded()
    }

    func advanceTutorialManually() {
        tutorialContext.manualContinue = true
        evaluateTutorialProgress(forceManual: true)
    }

    // MARK: - Private helpers

    private func updateTerrainFeedback() {
        guard let terrain = snapshot.playerCurrentTerrain else { return }
        if let lastTerrain, lastTerrain != terrain {
            terrainEntryBanner = TerrainSystem.entryMessage(for: terrain)
            scheduleTerrainBannerClear()
        }
        lastTerrain = terrain
    }

    private func updateContextualTips(
        previousPhase: SimulationPhase?,
        generationChanged: Bool,
        previousEra: GameEra,
        totalBornIncreased: Bool,
        previousLivingCount: Int,
        massExtinctionJustStarted: Bool
    ) {
        guard appPhase == .playing else { return }

        eraAdvanceTipCoordinator.registerForwardAdvance(
            from: previousEra,
            to: snapshot.era,
            shouldShow: contextualTips.shouldShow(_:)
        )

        if contextualTip != nil { return }

        if presentPendingEraAdvanceTipIfNeeded() { return }

        if massExtinctionJustStarted, contextualTips.shouldShow(.massExtinctionBegins) {
            contextualTip = .massExtinctionBegins
            return
        }

        if totalBornIncreased,
           snapshot.lineage.livingCount <= previousLivingCount,
           contextualTips.shouldShow(.firstOffspringLoss) {
            contextualTip = .firstOffspringLoss
            return
        }

        if let tip = contextualTips.tipFor(
            snapshot: snapshot,
            previousPhase: previousPhase,
            generationChanged: generationChanged
        ) {
            contextualTip = tip
        }
    }

    @discardableResult
    private func presentPendingEraAdvanceTipIfNeeded() -> Bool {
        guard appPhase == .playing, contextualTip == nil else { return false }
        guard let pending = eraAdvanceTipCoordinator.consumePendingTip(if: contextualTips.shouldShow(_:)) else {
            return false
        }
        contextualTip = pending
        return true
    }

    private func evaluateTutorialProgress(forceManual: Bool = false) {
        guard appPhase == .tutorial, let step = tutorialStep else { return }

        if step.requiresManualContinue && !forceManual && !tutorialContext.manualContinue {
            return
        }

        guard step.isComplete(snapshot: snapshot, context: tutorialContext) else { return }

        tutorialContext.manualContinue = false

        if let next = TutorialStep(rawValue: step.rawValue + 1) {
            tutorialStep = next
            if next == .eatFood {
                tutorialContext.baselineEnergy = snapshot.playerOrganism?.energy
            }
        } else {
            finishTutorialAndContinuePlaying()
        }
    }

    private func scheduleFeedbackClear() {
        feedbackClearTask?.cancel()
        feedbackClearTask = Task {
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            guard !Task.isCancelled else { return }
            mutationFeedback = nil
        }
    }

    private func scheduleTerrainBannerClear() {
        terrainBannerClearTask?.cancel()
        terrainBannerClearTask = Task {
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            guard !Task.isCancelled else { return }
            terrainEntryBanner = nil
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
