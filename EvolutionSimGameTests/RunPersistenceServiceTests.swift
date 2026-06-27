import Foundation
import EvolutionSimCore
@testable import EvolutionSimGame
import XCTest

@MainActor
final class RunPersistenceServiceTests: XCTestCase {
    func testPersistedRunRoundTripPreservesSessionFields() throws {
        let controller = SimulationController(config: SimulationConfig(seed: 123))
        controller.step(input: PlayerInput(movementDirection: Vector2(x: 1, y: 0)))

        let persistedRun = PersistedRun(
            savedAt: Date(timeIntervalSince1970: 1234),
            simulation: SavedSimulation(
                state: controller.state,
                inputLog: [PlayerInput(movementDirection: Vector2(x: 0, y: 1))]
            ),
            session: RunSessionState(
                hasPresentedMutationChoiceThisRun: true,
                deferredMutationPresentationTicks: 12
            )
        )

        let encoded = try JSONEncoder().encode(persistedRun)
        let decoded = try JSONDecoder().decode(PersistedRun.self, from: encoded)

        XCTAssertEqual(decoded, persistedRun)
    }

    func testLoadCorruptSaveReturnsCorruptError() throws {
        let tempDirectory = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: tempDirectory) }

        let service = RunPersistenceService(baseDirectory: tempDirectory)
        let saveURL = tempDirectory.appendingPathComponent("active-run.json")
        try Data("not-json".utf8).write(to: saveURL)

        XCTAssertThrowsError(try service.load()) { error in
            guard case RunPersistenceError.corruptSave = error else {
                return XCTFail("Expected corrupt save error, got \(error)")
            }
        }
    }

    func testLoadRejectsIncompatibleSchemaVersion() throws {
        let tempDirectory = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: tempDirectory) }

        let controller = SimulationController(config: SimulationConfig(seed: 55))
        let incompatibleRun = PersistedRun(
            schemaVersion: RunSaveSchemaVersion + 1,
            simulation: SavedSimulation(state: controller.state),
            session: RunSessionState(
                hasPresentedMutationChoiceThisRun: false,
                deferredMutationPresentationTicks: 0
            )
        )

        let saveURL = tempDirectory.appendingPathComponent("active-run.json")
        try JSONEncoder().encode(incompatibleRun).write(to: saveURL)

        let service = RunPersistenceService(baseDirectory: tempDirectory)
        XCTAssertThrowsError(try service.load()) { error in
            guard case let RunPersistenceError.incompatibleNewerSchema(found, supported) = error else {
                return XCTFail("Expected incompatible schema error, got \(error)")
            }
            XCTAssertEqual(found, RunSaveSchemaVersion + 1)
            XCTAssertEqual(supported, RunSaveSchemaVersion)
        }
    }

    func testRestoreFromPersistedRunRestoresDeferredMutationSession() throws {
        let tempDirectory = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: tempDirectory) }

        let controller = SimulationController(config: .tutorialPreset())
        controller.step()
        XCTAssertEqual(controller.state.phase, .awaitingMutationChoice)

        let viewModel = GameViewModel(
            persistenceService: RunPersistenceService(baseDirectory: tempDirectory)
        )
        viewModel.restore(
            from: PersistedRun(
                simulation: SavedSimulation(state: controller.state),
                session: RunSessionState(
                    hasPresentedMutationChoiceThisRun: false,
                    deferredMutationPresentationTicks: GameViewModel.firstMutationMinimumTick - 1
                )
            )
        )

        XCTAssertEqual(viewModel.appPhase, .playing)
        XCTAssertEqual(viewModel.snapshot.phase, .awaitingMutationChoice)
        XCTAssertFalse(viewModel.shouldPresentMutationChoice)

        viewModel.tick()
        XCTAssertTrue(viewModel.shouldPresentMutationChoice)
    }

    func testRestorePreservesPausedStateAndSeed() throws {
        let tempDirectory = try makeTemporaryDirectory()
        defer { try? FileManager.default.removeItem(at: tempDirectory) }

        let controller = SimulationController(config: SimulationConfig(seed: 88))
        controller.setPaused(true)
        controller.setSpeedMultiplier(2)

        let viewModel = GameViewModel(
            persistenceService: RunPersistenceService(baseDirectory: tempDirectory)
        )
        viewModel.restore(
            from: PersistedRun(
                simulation: SavedSimulation(state: controller.state),
                session: RunSessionState(
                    hasPresentedMutationChoiceThisRun: true,
                    deferredMutationPresentationTicks: 0
                )
            )
        )

        XCTAssertEqual(viewModel.currentRunSeed, 88)
        XCTAssertTrue(viewModel.snapshot.isPaused)
        XCTAssertEqual(viewModel.snapshot.speedMultiplier, 2, accuracy: 0.001)
        XCTAssertFalse(viewModel.isTickLoopActive)
    }

    private func makeTemporaryDirectory() throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }
}
