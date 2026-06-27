import Foundation
@testable import EvolutionSimCore
import XCTest

/// Phase 7 — Beta Gameplay Hardening.
///
/// Deterministic balance, progression, and failure/recovery coverage for the beta loop.
/// These tests defend the core beta guarantees:
///  - common starts (default seed 42 and tutorial seed 1001) are viable, never an unavoidable
///    early extinction (risk R10 / beta entry criterion #7),
///  - every `VictoryGoal` is reachable from a real seeded run, and
///  - victory and extinction outcomes are reproducible from seed + recorded input log (risk R2).
///
/// Rationale for the chosen seeds and tuning lives in `docs/beta/pacing-targets.md`.
final class Phase7BalanceTests: XCTestCase {

    // MARK: - Representative seed suite

    /// Representative seeds for beta balance checks, with documented intent. The suite is
    /// deliberately small and fixed so balance regressions are reproducible and reviewable.
    enum SeedSuite {
        /// Default new-game seed (`SimulationConfig` default). Must be a viable common start.
        static let defaultSeed: UInt64 = 42
        /// Tutorial preset seed (`SimulationConfig.tutorialSeed`). Must be a viable, gentle start.
        static let tutorialSeed: UInt64 = SimulationConfig.tutorialSeed // 1001

        /// Early/mid/late representatives spanning fast-food, sparse-food, and predator-heavy
        /// starts. Verified to allow a naive learner to survive the early game and reproduce.
        static let representatives: [UInt64] = [42, 1001, 7, 77, 123, 999, 2024]

        /// Seeds verified (under skilled scripted play) to reach each victory goal. Picked from a
        /// 1...30 seed sweep; kept as small candidate lists so per-seed variance never makes the
        /// "every goal is winnable" guarantee flaky.
        static let biomeSpreadWinners: [UInt64] = [3, 5, 6, 9, 11]
        static let intelligenceWinners: [UInt64] = [8, 9, 13, 15, 21]
        static let massExtinctionWinners: [UInt64] = [3, 5, 8, 9, 12]
        static let populationWinners: [UInt64] = [3, 8]
    }

    // MARK: - Scripted players (deterministic, state-driven)

    /// Skilled play: flee a sensed predator, otherwise seek the nearest food.
    private func smartInput(_ state: SimulationState) -> PlayerInput {
        guard let player = state.playerOrganism else { return PlayerInput() }
        if let (predator, dist) = PredatorSystem.nearestPredator(to: player.position, predators: state.predators),
           dist <= player.traits.effectiveSenseRadius {
            return PlayerInput(movementDirection: (player.position - predator.position).normalized)
        }
        if let food = state.food.min(by: {
            player.position.distance(to: $0.position) < player.position.distance(to: $1.position)
        }) {
            return PlayerInput(movementDirection: (food.position - player.position).normalized)
        }
        return PlayerInput()
    }

    /// Naive learner: only chases food, never flees. Models a brand-new player.
    private func naiveInput(_ state: SimulationState) -> PlayerInput {
        guard let player = state.playerOrganism else { return PlayerInput() }
        if let food = state.food.min(by: {
            player.position.distance(to: $0.position) < player.position.distance(to: $1.position)
        }) {
            return PlayerInput(movementDirection: (food.position - player.position).normalized)
        }
        return PlayerInput()
    }

    /// Result of a recorded run: the input log replayable via `SimulationReplay`, plus the
    /// terminal state. The record loop mirrors `SimulationReplay.replay` exactly (resolve any
    /// pending mutation by taking the first offer, then step) so the log reproduces the run.
    private struct RecordedRun {
        var config: SimulationConfig
        var inputLog: [PlayerInput]
        var finalState: SimulationState
    }

    private func recordRun(
        config: SimulationConfig,
        maxTicks: Int,
        strategy: (SimulationState) -> PlayerInput
    ) -> RecordedRun {
        let controller = SimulationController(config: config)
        var log: [PlayerInput] = []
        for _ in 0..<maxTicks {
            if controller.state.phase == .awaitingMutationChoice,
               let offer = controller.state.pendingMutationOffers.first {
                controller.selectMutation(offer)
            }
            guard controller.state.phase == .playing else { break }
            let input = strategy(controller.state)
            log.append(input)
            controller.step(input: input)
            if controller.state.phase == .victory || controller.state.phase == .extinct { break }
        }
        return RecordedRun(config: config, inputLog: log, finalState: controller.state)
    }

    // MARK: - Common-start viability (R10 / entry criterion #7)

    func testDefaultAndTutorialSeedsAreViableUnderNaivePlay() throws {
        // The two common starts a beta player will actually see (default new game and the
        // tutorial preset) must never be an unavoidable early extinction: a naive learner who
        // only chases food must survive well past the learning window and produce offspring.
        let cases: [(String, SimulationConfig)] = [
            ("default-42", SimulationConfig(seed: SeedSuite.defaultSeed)),
            ("tutorial-1001", .tutorialPreset()),
        ]
        let survivalFloor = SimulationTuning.primordialGraceTicks * 2 // 480 ticks, well past learning
        for (label, config) in cases {
            let controller = SimulationController(config: config)
            for tick in 0..<survivalFloor {
                if controller.state.phase == .awaitingMutationChoice,
                   let offer = controller.state.pendingMutationOffers.first {
                    controller.selectMutation(offer)
                }
                controller.step(input: naiveInput(controller.state))
                XCTAssertNotEqual(
                    controller.state.phase, .extinct,
                    "Common start \(label) went extinct early at tick \(tick) under naive play"
                )
            }
            XCTAssertGreaterThanOrEqual(
                controller.state.fitness.totalOffspring, 1,
                "Common start \(label) never reproduced under naive play"
            )
        }
    }

    func testRepresentativeSeedSuiteSurvivesEarlyGame() throws {
        // Every representative seed must let a naive learner clear the grace window without
        // extinction — the suite is only meaningful if all members are viable starts.
        for seed in SeedSuite.representatives {
            let controller = SimulationController(config: SimulationConfig(seed: seed))
            for _ in 0..<SimulationTuning.primordialGraceTicks {
                if controller.state.phase == .awaitingMutationChoice,
                   let offer = controller.state.pendingMutationOffers.first {
                    controller.selectMutation(offer)
                }
                controller.step(input: naiveInput(controller.state))
            }
            XCTAssertNotEqual(
                controller.state.phase, .extinct,
                "Representative seed \(seed) produced early extinction under naive play"
            )
        }
    }

    // MARK: - Energy economy (root-cause regression)

    func testForagingYieldsNetPositiveEnergyAcrossPredatorFreeStart() throws {
        // Phase 7 root cause: foraging used to net ~0 energy, so lineages slowly starved even
        // with no predators. With the rebalanced food economy a skilled forager in a
        // predator-free world must grow its lineage rather than dwindle to extinction.
        let controller = SimulationController(
            config: SimulationConfig(seed: 42, enableMassExtinctionEvents: false, predatorCountOverride: 0)
        )
        var peakPopulation = 1
        for _ in 0..<1500 {
            if controller.state.phase == .awaitingMutationChoice,
               let offer = controller.state.pendingMutationOffers.first {
                controller.selectMutation(offer)
            }
            guard controller.state.phase == .playing else { break }
            controller.step(input: smartInput(controller.state))
            peakPopulation = max(peakPopulation, controller.state.livingOrganisms.count)
        }
        XCTAssertNotEqual(controller.state.phase, .extinct, "Predator-free lineage still starved out")
        XCTAssertGreaterThanOrEqual(peakPopulation, 6, "Lineage failed to grow without predators")
    }

    // MARK: - Victory path per goal (all four)

    private func assertSomeSeedWins(
        goal: VictoryGoal,
        seeds: [UInt64],
        tutorial: Bool = false,
        strategy: @escaping (SimulationState) -> PlayerInput,
        maxTicks: Int
    ) {
        for seed in seeds {
            let config: SimulationConfig = tutorial
                ? .tutorialPreset()
                : SimulationConfig(seed: seed, victoryGoal: goal)
            let run = recordRun(config: config, maxTicks: maxTicks, strategy: strategy)
            if run.finalState.phase == .victory {
                return // at least one seed reaches this goal — guarantee satisfied
            }
        }
        XCTFail("No candidate seed reached victory for goal \(goal.rawValue)")
    }

    func testBiomeSpreadVictoryIsReachable() {
        assertSomeSeedWins(goal: .spreadToAllBiomes, seeds: SeedSuite.biomeSpreadWinners, strategy: smartInput, maxTicks: 6000)
    }

    func testIntelligenceVictoryIsReachable() {
        assertSomeSeedWins(goal: .evolveIntelligence, seeds: SeedSuite.intelligenceWinners, strategy: smartInput, maxTicks: 8000)
    }

    func testMassExtinctionSurvivalVictoryIsReachable() {
        assertSomeSeedWins(goal: .surviveMassExtinction, seeds: SeedSuite.massExtinctionWinners, strategy: smartInput, maxTicks: 6000)
    }

    func testPopulationVictoryIsReachableInTutorialPreset() {
        // The tutorial preset's goal is `reachPopulation`; a naive learner must be able to win it.
        assertSomeSeedWins(goal: .reachPopulation, seeds: [SeedSuite.tutorialSeed], tutorial: true, strategy: naiveInput, maxTicks: 4000)
    }

    func testPopulationVictoryIsReachableInDefaultConfig() {
        assertSomeSeedWins(goal: .reachPopulation, seeds: SeedSuite.populationWinners, strategy: smartInput, maxTicks: 6000)
    }

    // MARK: - Reproducibility from seed + input log (R2)

    func testVictoryPathReproducibleFromSeedAndInputLog() throws {
        // Record a real winning run, then replay the seed + input log and require a byte-identical
        // final state. Proves a victory is reproducible for bug reports and balancing.
        let config = SimulationConfig(seed: 8, victoryGoal: .reachPopulation)
        let run = recordRun(config: config, maxTicks: 6000, strategy: smartInput)
        XCTAssertEqual(run.finalState.phase, .victory, "Expected seed 8 reachPopulation run to win")

        let replayed = SimulationReplay.replay(config: config, inputs: run.inputLog)
        XCTAssertEqual(replayed.phase, .victory)
        // Equatable comparison (content-based set equality) rather than raw bytes, since `Set`
        // fields like `exploredCells` have no guaranteed JSON ordering.
        XCTAssertEqual(replayed, run.finalState, "Replay of victory input log diverged from recorded run")
    }

    func testExtinctionPathReproducibleFromSeedAndInputLog() throws {
        // Record a real losing run, then replay the seed + input log and require a byte-identical
        // final state.
        let config = SimulationConfig(seed: 7)
        let run = recordRun(config: config, maxTicks: 6000, strategy: naiveInput)
        XCTAssertEqual(run.finalState.phase, .extinct, "Expected seed 7 naive run to go extinct")

        let replayed = SimulationReplay.replay(config: config, inputs: run.inputLog)
        XCTAssertEqual(replayed.phase, .extinct)
        XCTAssertEqual(replayed.tick, run.finalState.tick)
        XCTAssertEqual(replayed, run.finalState, "Replay of extinction input log diverged from recorded run")
    }

    // MARK: - Failure / recovery review

    func testStarvationRecoveryWhenFoodReached() throws {
        // A starving organism (energy 0, taking starvation damage) that reaches food must recover
        // energy and survive — starvation should be a recoverable pressure, not a death spiral.
        var state = SimulationState(config: SimulationConfig(seed: 1, enableMassExtinctionEvents: false, predatorCountOverride: 0))
        let playerID = EntityID(rawValue: 1)
        var player = Organism(id: playerID, position: Vector2(x: 400, y: 300), energy: 1, isPlayerControlled: true)
        player.health = 40
        state.organisms = [player]
        state.playerOrganismID = playerID
        state.predators = []
        state.food = [FoodParticle(id: EntityID(rawValue: 2), position: Vector2(x: 405, y: 300))]

        let controller = SimulationController(state: state)
        controller.step(input: PlayerInput(movementDirection: Vector2(x: 1, y: 0)))

        let recovered = controller.state.playerOrganism
        XCTAssertNotNil(recovered)
        XCTAssertGreaterThan(recovered?.energy ?? 0, 1, "Reaching food did not restore energy")
        XCTAssertTrue(recovered?.isAlive ?? false)
    }

    func testToxicStartIsRecoverable() throws {
        // A lineage that starts standing in toxic terrain must be able to walk out and survive
        // rather than being doomed by spawn placement.
        var state = SimulationState(config: SimulationConfig(seed: 1, enableMassExtinctionEvents: false, predatorCountOverride: 0))
        let toxicCenter = state.terrain.regions.first { $0.type == .toxicPool }?.center ?? Vector2(x: 600, y: 105)
        let playerID = EntityID(rawValue: 1)
        let player = Organism(id: playerID, position: toxicCenter, isPlayerControlled: true)
        state.organisms = [player]
        state.playerOrganismID = playerID
        state.predators = []
        XCTAssertEqual(state.terrain(at: toxicCenter), .toxicPool, "Test setup did not start in toxic terrain")

        let controller = SimulationController(state: state)
        // Drive straight toward open land (world center) until clear of the toxic pool.
        let escapeDirection = (state.config.bounds.center - toxicCenter).normalized
        var leftToxic = false
        for _ in 0..<400 {
            controller.step(input: PlayerInput(movementDirection: escapeDirection))
            if controller.state.phase != .playing { break }
            if let p = controller.state.playerOrganism, controller.state.terrain(at: p.position) != .toxicPool {
                leftToxic = true
                break
            }
        }
        XCTAssertTrue(leftToxic, "Player could not escape a toxic start")
        XCTAssertTrue(controller.state.playerOrganism?.isAlive ?? false, "Player died escaping toxic start")
    }

    func testOverpopulationStaysWithinCap() throws {
        // Population must stay bounded for mobile performance: living descendants never exceed
        // the configured cap across a long, food-rich, predator-free run.
        let controller = SimulationController(
            config: SimulationConfig(seed: 3, enableMassExtinctionEvents: false, predatorCountOverride: 0)
        )
        for _ in 0..<4000 {
            if controller.state.phase == .awaitingMutationChoice,
               let offer = controller.state.pendingMutationOffers.first {
                controller.selectMutation(offer)
            }
            guard controller.state.phase == .playing else { break }
            controller.step(input: smartInput(controller.state))
            let descendants = controller.state.organisms.filter { $0.isAlive && !$0.isPlayerControlled }.count
            XCTAssertLessThanOrEqual(
                descendants, SimulationTuning.maxDescendants,
                "Descendant population exceeded the cap"
            )
        }
    }

    func testMassExtinctionTriggersAndAcceleratesPredators() throws {
        // The mass-extinction event must fire on schedule (tick 2000) and raise predator chase
        // speed, so the late-game spike is real and observable. Built deterministically at tick
        // 1999 so the assertion does not depend on a lineage surviving 2000 ticks of play.
        var state = SimulationState(config: SimulationConfig(seed: 42, enableMassExtinctionEvents: true))
        state.tick = 1999
        let playerID = EntityID(rawValue: 1)
        state.organisms = [Organism(id: playerID, position: state.config.bounds.center, isPlayerControlled: true)]
        state.playerOrganismID = playerID
        state.predators = [
            Predator(id: EntityID(rawValue: 2), position: Vector2(x: 100, y: 100), speed: EraContent.predatorSpeed(for: .primordialPool)),
            Predator(id: EntityID(rawValue: 3), position: Vector2(x: 700, y: 500), speed: EraContent.predatorSpeed(for: .primordialPool)),
        ]
        let preSpeeds = state.predators.map(\.speed)

        let controller = SimulationController(state: state)
        controller.step(input: PlayerInput())

        XCTAssertTrue(controller.state.massExtinctionActive, "Mass extinction never activated at tick 2000")
        XCTAssertEqual(controller.state.massExtinctionStartTick, 2000)
        let postSpeeds = controller.state.predators.map(\.speed)
        XCTAssertGreaterThan(postSpeeds.max() ?? 0, preSpeeds.max() ?? .greatestFiniteMagnitude)
    }

    func testTutorialPredatorCountStaysCappedAcrossEras() throws {
        // The tutorial preset fixes a low predator count; era escalation must not silently
        // re-inflate it (regression guard for the override-respecting fix).
        var state = SimulationController(config: .tutorialPreset()).state
        state.fitness.survivalTicks = 20_000 // force a high composite so eras advance on step
        let controller = SimulationController(state: state)
        controller.step(input: PlayerInput())
        XCTAssertGreaterThan(controller.state.config.era.rawValue, GameEra.primordialPool.rawValue)
        XCTAssertEqual(
            controller.state.predators.count, 2,
            "Tutorial predator-count override was not respected after era escalation"
        )
    }
}
