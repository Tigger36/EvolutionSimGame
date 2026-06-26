import Foundation
@testable import EvolutionSimCore
import XCTest

final class SeededRNGTests: XCTestCase {
    func testDeterministicSequence() {
        var a = SeededRNG(seed: 12345)
        var b = SeededRNG(seed: 12345)
        for _ in 0..<100 {
            XCTAssertEqual(a.nextUInt64(), b.nextUInt64())
        }
    }
}

final class TerrainTests: XCTestCase {
    func testMVPterrainSampling() {
        let bounds = WorldBounds.standard
        let field = TerrainField.mvpLayout(bounds: bounds)
        let waterPoint = Vector2(x: bounds.center.x * 0.35, y: bounds.center.y)
        XCTAssertEqual(field.terrain(at: waterPoint), .water)
    }

    func testTerrainPenalties() {
        let traits = TraitSet(toxinResistance: 0.0)
        let effects = TerrainSystem.effects(for: .toxicPool, traits: traits)
        XCTAssertGreaterThan(effects.damagePerTick, 0)
        XCTAssertLessThan(effects.speedMultiplier, 1.0)

        let resistant = TraitSet(toxinResistance: 1.0)
        let resistantEffects = TerrainSystem.effects(for: .toxicPool, traits: resistant)
        XCTAssertEqual(resistantEffects.damagePerTick, 0)
    }
}

final class TraitTests: XCTestCase {
    func testMutationApplication() {
        var traits = TraitSet.default
        MutationOption.strongerFins.apply(to: &traits)
        XCTAssertGreaterThan(traits.swimEfficiency, 0.5)
    }

    func testInheritanceVariance() {
        var rng = SeededRNG(seed: 99)
        let parent = TraitSet(speed: 0.7, armor: 0.6)
        let child = parent.inherited(from: parent, rng: &rng)
        XCTAssertNotEqual(child.speed, parent.speed)
    }
}

final class MutationOfferTests: XCTestCase {
    func testWaterPressureBiasesOffers() {
        var pressure = PressureState()
        pressure.water = 10
        var rng = SeededRNG(seed: 7)
        let offers = MutationSystem.offers(for: pressure, rng: &rng)
        XCTAssertEqual(offers.count, 3)
        let waterRelated: Set<MutationOption> = [.strongerFins, .gills, .moistureResistantSkin]
        XCTAssertTrue(offers.contains(where: { waterRelated.contains($0) }))
    }
}

final class MutationPreviewTests: XCTestCase {
    func testStrongerFinsTraitDeltas() {
        let base = TraitSet.default
        let deltas = MutationPreview.traitDeltas(option: .strongerFins, base: base)
        XCTAssertTrue(deltas.contains { $0.name == "Swim" && $0.delta > 0 })
        XCTAssertTrue(deltas.contains { $0.name == "Speed" && $0.delta < 0 })
    }

    func testDominantPressureLabel() {
        var pressure = PressureState()
        XCTAssertNil(pressure.dominantPressureLabel)
        pressure.water = 0.2
        XCTAssertEqual(pressure.dominantPressureLabel, "Water exposure")
    }

    func testCompatibilityChangesForToxinFilter() {
        let base = TraitSet.default
        let changes = MutationPreview.compatibilityChanges(option: .toxinFilter, base: base)
        let toxic = changes.first { $0.terrain == .toxicPool }
        XCTAssertNotNil(toxic)
        XCTAssertGreaterThan(toxic!.after, toxic!.before)
    }

    func testPlayerFacingTerrainSummary() {
        XCTAssertTrue(TerrainSystem.playerFacingSummary(for: .toxicPool).contains("Toxin"))
    }

    func testSnapshotIncludesReproductionSafety() {
        let controller = SimulationController(config: SimulationConfig(seed: 42))
        let snapshot = controller.snapshot()
        XCTAssertNotNil(snapshot.playerCurrentTerrain)
        XCTAssertNil(snapshot.pendingMutationTargetID)
        if let player = snapshot.playerOrganism {
            let expected = player.canReproduce
                && ReproductionSystem.isSafeSite(position: player.position, predators: snapshot.predators)
            XCTAssertEqual(snapshot.playerCanReproduceSafely, expected)
        }
    }
}

final class SimulationDeterminismTests: XCTestCase {
    func testSameSeedSameStateAfterNTicks() throws {
        let config = SimulationConfig(seed: 42)
        let input = PlayerInput(movementDirection: Vector2(x: 1, y: 0))

        let controllerA = SimulationController(config: config)
        let controllerB = SimulationController(config: config)

        for _ in 0..<50 {
            controllerA.step(input: input)
            controllerB.step(input: input)
        }

        let dataA = try JSONEncoder().encode(controllerA.state)
        let dataB = try JSONEncoder().encode(controllerB.state)
        let stateA = try JSONDecoder().decode(SimulationState.self, from: dataA)
        let stateB = try JSONDecoder().decode(SimulationState.self, from: dataB)
        XCTAssertEqual(stateA, stateB)
    }

    func testSnapshotRoundTrip() throws {
        let controller = SimulationController(config: SimulationConfig(seed: 1))
        controller.step(input: PlayerInput(movementDirection: Vector2(x: 0, y: 1)))

        let snapshot = controller.snapshot()
        let encoded = try JSONEncoder().encode(snapshot)
        let decoded = try JSONDecoder().decode(SimulationSnapshot.self, from: encoded)
        XCTAssertEqual(snapshot, decoded)
    }

    func testStateSerializationRoundTrip() throws {
        var controller = SimulationController(config: SimulationConfig(seed: 5))
        for _ in 0..<20 {
            controller.step(input: PlayerInput(movementDirection: Vector2(x: 0.5, y: 0.5)))
        }

        let encoded = try JSONEncoder().encode(controller.state)
        let decoded = try JSONDecoder().decode(SimulationState.self, from: encoded)
        let restored = SimulationController(state: decoded)
        XCTAssertEqual(controller.state.tick, restored.state.tick)
        XCTAssertEqual(controller.state.organisms.count, restored.state.organisms.count)
    }
}

final class ReproductionTests: XCTestCase {
    func testReproductionRequiresEnergy() {
        var parent = Organism(
            id: EntityID(rawValue: 1),
            position: .zero,
            energy: 10
        )
        var rng = SeededRNG(seed: 1)
        var idGen = EntityIDGenerator()
        let child = ReproductionSystem.reproduce(
            parent: &parent,
            rng: &rng,
            idGenerator: &idGen,
            predators: []
        )
        XCTAssertNil(child)
    }

    func testReproductionCreatesOffspring() {
        var parent = Organism(
            id: EntityID(rawValue: 1),
            position: Vector2(x: 100, y: 100),
            energy: 100
        )
        var rng = SeededRNG(seed: 1)
        var idGen = EntityIDGenerator(startingAt: 2)
        let child = ReproductionSystem.reproduce(
            parent: &parent,
            rng: &rng,
            idGenerator: &idGen,
            predators: []
        )
        XCTAssertNotNil(child)
        XCTAssertEqual(parent.offspringCount, 1)
    }
}

final class LineageHandoffTests: XCTestCase {
    func testControlTransfersToDescendant() {
        var state = SimulationState(config: SimulationConfig(seed: 100))
        let playerID = EntityID(rawValue: 1)
        let childID = EntityID(rawValue: 999)

        state.organisms = [
            Organism(id: playerID, position: .zero, isPlayerControlled: true, generation: 1, lineageID: 1),
            Organism(id: childID, position: Vector2(x: 50, y: 50), isPlayerControlled: false, generation: 2, lineageID: 1),
        ]
        state.playerOrganismID = playerID
        state.organisms[0].isAlive = false

        let controller = SimulationController(state: state)
        controller.transferControl(to: childID)

        XCTAssertEqual(controller.state.playerOrganismID, childID)
        XCTAssertTrue(controller.state.organisms.first(where: { $0.id == childID })?.isPlayerControlled ?? false)
    }

    func testExtinctionWhenNoLivingOrganisms() {
        var state = SimulationState(config: SimulationConfig(seed: 100))
        state.organisms = [
            Organism(id: EntityID(rawValue: 1), position: .zero, isPlayerControlled: true),
        ]
        state.organisms[0].isAlive = false
        state.playerOrganismID = EntityID(rawValue: 1)

        let controller = SimulationController(state: state)
        controller.step()

        XCTAssertEqual(controller.state.phase, .extinct)
    }
}

final class FitnessTests: XCTestCase {
    func testCompositeScoreIncreasesWithSurvival() {
        var metrics = FitnessMetrics()
        let organism = Organism(id: EntityID(rawValue: 1), position: .zero)
        FitnessSystem.update(
            metrics: &metrics,
            organism: organism,
            terrain: .land,
            foodEaten: true,
            nearMiss: true,
            hit: false
        )
        XCTAssertGreaterThan(metrics.compositeScore, 0)
    }
}

final class EraAndVictoryTests: XCTestCase {
    func testEraProgression() {
        XCTAssertEqual(EraSystem.era(for: 10), .primordialPool)
        XCTAssertEqual(EraSystem.era(for: 100), .reefShallows)
        XCTAssertEqual(EraSystem.era(for: 500), .ecosystemDominance)
    }

    func testBiomeVictory() {
        var metrics = FitnessMetrics()
        metrics.biomesExplored = Set(TerrainType.allCases.prefix(6))
        let won = EraSystem.checkVictory(
            goal: .spreadToAllBiomes,
            metrics: metrics,
            livingPopulation: 1,
            tick: 100,
            massExtinctionActive: false
        )
        XCTAssertTrue(won)
    }
}

final class SavedSimulationTests: XCTestCase {
    func testSaveRestoreRoundTrip() throws {
        let controller = SimulationController(config: SimulationConfig(seed: 77))
        controller.step(input: PlayerInput(movementDirection: Vector2(x: 1, y: 0)))
        let saved = SavedSimulation(state: controller.state)

        let encoded = try JSONEncoder().encode(saved)
        let decoded = try JSONDecoder().decode(SavedSimulation.self, from: encoded)
        XCTAssertEqual(saved, decoded)
    }
}

final class PredatorDifficultyTests: XCTestCase {
    func testEraSpeedScalingIsMonotonic() {
        let primordial = EraContent.predatorSpeed(for: .primordialPool)
        let reef = EraContent.predatorSpeed(for: .reefShallows)
        let landfall = EraContent.predatorSpeed(for: .landfall)
        let biomes = EraContent.predatorSpeed(for: .biomes)
        let ecosystem = EraContent.predatorSpeed(for: .ecosystemDominance)

        XCTAssertLessThan(primordial, reef)
        XCTAssertLessThan(reef, landfall)
        XCTAssertLessThan(landfall, biomes)
        XCTAssertLessThan(biomes, ecosystem)
        XCTAssertLessThan(primordial, SimulationTuning.predatorSpeed)
    }

    func testBootstrapSpawnsEraPredatorCount() {
        let controller = SimulationController(config: SimulationConfig(seed: 42))
        XCTAssertEqual(controller.state.config.era, .primordialPool)
        XCTAssertEqual(
            controller.state.predators.count,
            EraContent.predatorCount(for: .primordialPool)
        )
        XCTAssertEqual(controller.state.predators.count, 3)
    }

    func testBootstrapPredatorsUsePrimordialDifficulty() {
        let controller = SimulationController(config: SimulationConfig(seed: 42))
        let expectedSpeed = EraContent.predatorSpeed(for: .primordialPool)
        let expectedSense = EraContent.predatorSenseRadius(for: .primordialPool)

        for predator in controller.state.predators {
            XCTAssertEqual(predator.speed, expectedSpeed, accuracy: 0.001)
            XCTAssertEqual(predator.senseRadius, expectedSense, accuracy: 0.001)
            XCTAssertLessThan(predator.speed, SimulationTuning.predatorSpeed)
        }
    }

    func testEraTransitionUpdatesPredatorSpeeds() {
        let bootstrapped = SimulationController(config: SimulationConfig(seed: 77))
        var state = bootstrapped.state
        state.fitness.survivalTicks = 600
        let controller = SimulationController(state: state)
        controller.step()

        XCTAssertEqual(controller.state.config.era, .reefShallows)
        let expectedSpeed = EraContent.predatorSpeed(for: .reefShallows)
        XCTAssertTrue(controller.state.predators.allSatisfy { abs($0.speed - expectedSpeed) < 0.001 })
    }

    func testEraTransitionSpawnsAdditionalPredators() {
        let bootstrapped = SimulationController(config: SimulationConfig(seed: 77))
        XCTAssertEqual(bootstrapped.state.predators.count, 3)

        var state = bootstrapped.state
        state.fitness.survivalTicks = 600
        let advancing = SimulationController(state: state)
        advancing.step()

        XCTAssertEqual(
            advancing.state.predators.count,
            EraContent.predatorCount(for: .reefShallows)
        )
        XCTAssertEqual(advancing.state.predators.count, 4)
    }

    func testSenseRadiusGatesChaseBehavior() {
        let bounds = WorldBounds.standard
        let farTarget = Vector2(x: 400, y: 300)

        var limitedPredator = Predator(
            id: EntityID(rawValue: 1),
            position: Vector2(x: 100, y: 100),
            speed: 50,
            senseRadius: 80,
            damage: 5
        )
        var omniscientPredator = limitedPredator
        omniscientPredator.senseRadius = 500

        var limitedRNG = SeededRNG(seed: 42)
        var omniscientRNG = SeededRNG(seed: 42)

        for _ in 0..<20 {
            PredatorSystem.update(
                predator: &limitedPredator,
                targetPosition: farTarget,
                bounds: bounds,
                rng: &limitedRNG
            )
            PredatorSystem.update(
                predator: &omniscientPredator,
                targetPosition: farTarget,
                bounds: bounds,
                rng: &omniscientRNG
            )
        }

        let limitedClosing = Vector2(x: 100, y: 100).distance(to: farTarget)
            - limitedPredator.position.distance(to: farTarget)
        let omniscientClosing = Vector2(x: 100, y: 100).distance(to: farTarget)
            - omniscientPredator.position.distance(to: farTarget)

        XCTAssertGreaterThan(omniscientClosing, limitedClosing)
    }

    func testMassExtinctionMultipliesEraScaledSpeed() {
        let bootstrapped = SimulationController(config: SimulationConfig(seed: 42))
        var state = bootstrapped.state
        state.fitness.survivalTicks = 600
        state.tick = 1999
        let controller = SimulationController(state: state)
        let preExtinctionSpeed = EraContent.predatorSpeed(for: .reefShallows)

        controller.step()

        XCTAssertTrue(controller.state.massExtinctionActive)
        let expectedSpeed = preExtinctionSpeed * SimulationTuning.massExtinctionSpeedMultiplier
        XCTAssertTrue(controller.state.predators.allSatisfy { abs($0.speed - expectedSpeed) < 0.001 })
        XCTAssertNotEqual(expectedSpeed, SimulationTuning.predatorSpeed * SimulationTuning.massExtinctionSpeedMultiplier)
    }

    func testPrimordialPlayerSurvivesEarlyGame() {
        let controller = SimulationController(config: SimulationConfig(seed: 42))
        for _ in 0..<120 {
            controller.step()
            XCTAssertTrue(controller.state.playerOrganism?.isAlive ?? false)
        }
    }

    func testPrimordialPlayerCanConsumeNearbyFood() {
        let bootstrapped = SimulationController(config: SimulationConfig(seed: 42))
        var state = bootstrapped.state
        guard let player = state.playerOrganism else {
            XCTFail("Missing player organism")
            return
        }

        state.food = [
            FoodParticle(id: EntityID(rawValue: 99_999), position: player.position)
        ]

        let controller = SimulationController(state: state)
        controller.step()

        XCTAssertGreaterThan(controller.state.fitness.foodConsumed, 0)
        XCTAssertTrue(controller.state.playerOrganism?.isAlive ?? false)
    }
}
