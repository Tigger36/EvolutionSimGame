import EvolutionSimCore
@testable import EvolutionSimGame
import XCTest

@MainActor
final class GameViewModelMutationGatingTests: XCTestCase {
    func testTutorialDefersMutationModalUntilChooseMutationStep() {
        let viewModel = GameViewModel()
        viewModel.beginTutorial()
        viewModel.stopTickLoop()

        if viewModel.snapshot.phase != .awaitingMutationChoice {
            viewModel.tick()
        }
        XCTAssertEqual(viewModel.snapshot.phase, .awaitingMutationChoice)
        XCTAssertEqual(viewModel.tutorialStep, .move)

        for step in [TutorialStep.move, .eatFood, .avoidPredators, .terrainBasics, .reproduce] {
            viewModel.tutorialStep = step
            XCTAssertFalse(
                viewModel.shouldPresentMutationChoice,
                "Expected deferral during tutorial step \(step)"
            )
        }

        viewModel.tutorialStep = .chooseMutation
        XCTAssertTrue(viewModel.shouldPresentMutationChoice)
    }

    func testNormalPlayDefersFirstMutationUntilDeferredTimerTicksElapse() {
        let viewModel = GameViewModel()
        viewModel.startGame(config: .tutorialPreset())
        viewModel.stopTickLoop()

        if viewModel.snapshot.phase != .awaitingMutationChoice {
            viewModel.tick()
        }
        XCTAssertEqual(viewModel.snapshot.phase, .awaitingMutationChoice)
        XCTAssertEqual(viewModel.appPhase, .playing)
        XCTAssertFalse(viewModel.shouldPresentMutationChoice)

        for tick in 1..<GameViewModel.firstMutationMinimumTick {
            viewModel.tick()
            XCTAssertFalse(
                viewModel.shouldPresentMutationChoice,
                "Expected deferral at deferred tick \(tick)"
            )
        }

        viewModel.tick()
        XCTAssertTrue(viewModel.shouldPresentMutationChoice)
    }

    func testTutorialContinuesSimulationWhileMutationPresentationDeferred() {
        let viewModel = GameViewModel()
        viewModel.beginTutorial()
        viewModel.stopTickLoop()

        if viewModel.snapshot.phase != .awaitingMutationChoice {
            viewModel.tick()
        }
        XCTAssertEqual(viewModel.tutorialStep, .move)

        let startTick = viewModel.snapshot.tick
        let startPosition = viewModel.snapshot.playerOrganism?.position
        viewModel.movementDirection = Vector2(x: 1, y: 0)

        for _ in 0..<40 {
            viewModel.tick()
        }

        XCTAssertFalse(viewModel.shouldPresentMutationChoice)
        XCTAssertGreaterThan(viewModel.snapshot.tick, startTick)
        if let startPosition, let endPosition = viewModel.snapshot.playerOrganism?.position {
            XCTAssertGreaterThan(endPosition.distance(to: startPosition), 25)
        }
    }

    func testNormalPlaySimulationAdvancesDuringDeferredPresentation() {
        let viewModel = GameViewModel()
        viewModel.startGame(config: .tutorialPreset())
        viewModel.stopTickLoop()

        if viewModel.snapshot.phase != .awaitingMutationChoice {
            viewModel.tick()
        }

        let startTick = viewModel.snapshot.tick
        viewModel.movementDirection = Vector2(x: 0, y: 1)

        for _ in 0..<10 {
            viewModel.tick()
        }

        XCTAssertFalse(viewModel.shouldPresentMutationChoice)
        XCTAssertGreaterThan(viewModel.snapshot.tick, startTick)
        XCTAssertEqual(viewModel.snapshot.phase, .awaitingMutationChoice)
    }
}
