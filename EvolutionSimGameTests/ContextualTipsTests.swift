import EvolutionSimCore
@testable import EvolutionSimGame
import XCTest

@MainActor
final class ContextualTipsTests: XCTestCase {
    private var defaults: UserDefaults!
    private var defaultsSuiteName: String!

    override func setUp() {
        super.setUp()
        defaultsSuiteName = "ContextualTipsTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: defaultsSuiteName)!
        defaults.removePersistentDomain(forName: defaultsSuiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: defaultsSuiteName)
        defaults = nil
        defaultsSuiteName = nil
        super.tearDown()
    }

    func testEraAdvanceTipForForwardAdvance_mapsErasAndGuardsRegression() {
        XCTAssertEqual(
            ContextualTip.eraAdvanceTipForForwardAdvance(from: .primordialPool, to: .reefShallows),
            .eraAdvanceReefShallows
        )
        XCTAssertEqual(
            ContextualTip.eraAdvanceTipForForwardAdvance(from: .reefShallows, to: .landfall),
            .eraAdvanceLandfall
        )
        XCTAssertEqual(
            ContextualTip.eraAdvanceTipForForwardAdvance(from: .landfall, to: .biomes),
            .eraAdvanceBiomes
        )
        XCTAssertEqual(
            ContextualTip.eraAdvanceTipForForwardAdvance(from: .biomes, to: .ecosystemDominance),
            .eraAdvanceEcosystemDominance
        )

        XCTAssertNil(ContextualTip.eraAdvanceTipForForwardAdvance(from: .reefShallows, to: .reefShallows))
        XCTAssertNil(ContextualTip.eraAdvanceTipForForwardAdvance(from: .landfall, to: .reefShallows))
        XCTAssertNil(ContextualTip.eraAdvanceTipForForwardAdvance(from: .primordialPool, to: .primordialPool))
    }

    func testEraAdvanceTipForForwardAdvance_skipsPrimordialTarget() {
        XCTAssertNil(ContextualTip.eraAdvanceTipForForwardAdvance(from: .ecosystemDominance, to: .primordialPool))
    }

    func testContextualTipsManager_persistsEraTipsOncePerEra() {
        let manager = ContextualTipsManager(defaults: defaults)

        XCTAssertTrue(manager.shouldShow(.eraAdvanceReefShallows))

        manager.markShown(.eraAdvanceReefShallows)

        XCTAssertFalse(manager.shouldShow(.eraAdvanceReefShallows))
        XCTAssertTrue(manager.shouldShow(.eraAdvanceLandfall))
    }

    func testEraAdvanceTipCoordinator_queuesAndConsumesPendingTip() {
        var coordinator = EraAdvanceTipCoordinator()

        coordinator.registerForwardAdvance(
            from: .primordialPool,
            to: .reefShallows,
            shouldShow: { _ in true }
        )

        XCTAssertEqual(coordinator.pendingTip, .eraAdvanceReefShallows)
        XCTAssertEqual(
            coordinator.consumePendingTip(if: { _ in true }),
            .eraAdvanceReefShallows
        )
        XCTAssertNil(coordinator.pendingTip)
    }

    func testEraAdvanceTipCoordinator_doesNotQueueWhenAlreadyDismissed() {
        let manager = ContextualTipsManager(defaults: defaults)
        manager.markShown(.eraAdvanceReefShallows)

        var coordinator = EraAdvanceTipCoordinator()
        coordinator.registerForwardAdvance(
            from: .primordialPool,
            to: .reefShallows,
            shouldShow: manager.shouldShow(_:)
        )

        XCTAssertNil(coordinator.pendingTip)
        XCTAssertNil(coordinator.consumePendingTip(if: manager.shouldShow(_:)))
    }

    func testEraAdvanceTipCoordinator_overwritesPendingWithLatestAdvance() {
        var coordinator = EraAdvanceTipCoordinator()

        coordinator.registerForwardAdvance(from: .primordialPool, to: .reefShallows, shouldShow: { _ in true })
        coordinator.registerForwardAdvance(from: .reefShallows, to: .landfall, shouldShow: { _ in true })

        XCTAssertEqual(coordinator.consumePendingTip(if: { _ in true }), .eraAdvanceLandfall)
    }

    func testEraAdvanceTipCopy_usesGameCopyPredatorSummary() {
        let tip = ContextualTip.eraAdvanceReefShallows

        XCTAssertEqual(tip.title, GameCopy.eraAdvanceTipTitle(for: .reefShallows))
        XCTAssertEqual(tip.message, GameCopy.predatorThreatSummary(for: .reefShallows, massExtinctionActive: false))
        XCTAssertEqual(tip.title, "New Era: Reef / Shallows")
    }

    func testContextualTipsManager_tipForDoesNotSelectEraAdvanceTips() {
        let manager = ContextualTipsManager(defaults: defaults)
        let snapshot = makeSnapshot(era: .reefShallows)

        let tip = manager.tipFor(
            snapshot: snapshot,
            previousPhase: .playing,
            generationChanged: false
        )

        XCTAssertNil(tip?.associatedEra, "tipFor must not surface era-advance tips")
    }

    private func makeSnapshot(era: GameEra) -> SimulationSnapshot {
        SimulationController(config: SimulationConfig(seed: 42, era: era)).snapshot()
    }
}
