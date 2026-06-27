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

    func testWaterRewardsSwimAdaptationAndLowerEnergyUse() {
        let defaultWater = TerrainSystem.effects(for: .water, traits: .default)
        let swimAdaptedWater = TerrainSystem.effects(
            for: .water,
            traits: TraitSet(swimEfficiency: 1.0)
        )

        XCTAssertLessThan(defaultWater.energyDrainMultiplier, 1.0)
        XCTAssertGreaterThan(swimAdaptedWater.speedMultiplier, defaultWater.speedMultiplier)
    }

    func testDamagingTerrainBlocksReproductionSafetyUnlessMitigated() {
        XCTAssertFalse(
            ReproductionSystem.isSafeSite(
                position: .zero,
                predators: [],
                terrain: .toxicPool,
                traits: TraitSet(toxinResistance: 0.0)
            )
        )
        XCTAssertTrue(
            ReproductionSystem.isSafeSite(
                position: .zero,
                predators: [],
                terrain: .toxicPool,
                traits: TraitSet(toxinResistance: 1.0)
            )
        )
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
        XCTAssertTrue(TerrainSystem.playerFacingSummary(for: .water).contains("energy"))
    }

    func testSnapshotIncludesReproductionSafety() {
        let controller = SimulationController(config: SimulationConfig(seed: 42))
        let snapshot = controller.snapshot()
        XCTAssertNotNil(snapshot.playerCurrentTerrain)
        XCTAssertNil(snapshot.pendingMutationTargetID)
        if let player = snapshot.playerOrganism {
            let terrainType = snapshot.terrain.terrain(at: player.position)
            let expected = player.canReproduce
                && ReproductionSystem.isSafeSite(
                    position: player.position,
                    predators: snapshot.predators,
                    terrain: terrainType,
                    traits: player.traits
                )
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
        let controller = SimulationController(config: SimulationConfig(seed: 5))
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

    func testParentalCareIncreasesOffspringStartingEnergy() {
        var parent = Organism(
            id: EntityID(rawValue: 1),
            position: Vector2(x: 100, y: 100),
            traits: TraitSet(parentalCare: 1.0),
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

        XCTAssertEqual(child?.energy ?? 0, 80, accuracy: 0.001)
    }

    func testReproductionBlocksDamagingTerrain() {
        let terrain = TerrainField(defaultType: .toxicPool)
        var parent = Organism(
            id: EntityID(rawValue: 1),
            position: Vector2(x: 100, y: 100),
            traits: TraitSet(toxinResistance: 0.0),
            energy: 100
        )
        var rng = SeededRNG(seed: 1)
        var idGen = EntityIDGenerator(startingAt: 2)

        let child = ReproductionSystem.reproduce(
            parent: &parent,
            rng: &rng,
            idGenerator: &idGen,
            predators: [],
            terrainField: terrain
        )

        XCTAssertNil(child)
    }

    func testReproductionClampsOffspringPositionToBounds() {
        let bounds = WorldBounds(minX: 0, minY: 0, maxX: 1, maxY: 1)
        var parent = Organism(
            id: EntityID(rawValue: 1),
            position: Vector2(x: 1, y: 1),
            energy: 100
        )
        var rng = SeededRNG(seed: 1)
        var idGen = EntityIDGenerator(startingAt: 2)

        let child = ReproductionSystem.reproduce(
            parent: &parent,
            rng: &rng,
            idGenerator: &idGen,
            predators: [],
            bounds: bounds
        )

        XCTAssertNotNil(child)
        XCTAssertTrue(bounds.contains(child?.position ?? Vector2(x: -1, y: -1)))
    }
}

final class SocialDefenseTests: XCTestCase {
    func testSocialBehaviorRequiresNearbyAlly() {
        let organism = Organism(
            id: EntityID(rawValue: 1),
            position: .zero,
            traits: TraitSet(socialBehavior: 1.0)
        )
        let distantAlly = Organism(
            id: EntityID(rawValue: 2),
            position: Vector2(x: SimulationTuning.socialDefenseRadius + 20, y: 0),
            traits: TraitSet(socialBehavior: 1.0)
        )
        let nearbyAlly = Organism(
            id: EntityID(rawValue: 3),
            position: Vector2(x: SimulationTuning.socialDefenseRadius - 1, y: 0),
            traits: TraitSet(socialBehavior: 1.0)
        )

        XCTAssertEqual(
            SocialDefenseSystem.predatorDamageMultiplier(for: organism, nearbyOrganisms: [distantAlly]),
            1.0
        )
        XCTAssertLessThan(
            SocialDefenseSystem.predatorDamageMultiplier(for: organism, nearbyOrganisms: [nearbyAlly]),
            1.0
        )
    }

    func testPredatorDamageUsesSocialMultiplier() {
        var organism = Organism(
            id: EntityID(rawValue: 1),
            position: .zero,
            traits: TraitSet(armor: 0.0, socialBehavior: 1.0)
        )
        let predator = Predator(
            id: EntityID(rawValue: 2),
            position: .zero,
            speed: SimulationTuning.predatorSpeed,
            senseRadius: SimulationTuning.predatorSenseRadius,
            damage: 20
        )

        _ = PredatorSystem.attack(
            organism: &organism,
            predator: predator,
            damageMultiplier: 1.0 - SimulationTuning.maxSocialPredatorDamageReduction
        )

        XCTAssertEqual(organism.health, 87, accuracy: 0.001)
    }
}

final class DescendantBehaviorTests: XCTestCase {
    func testDescendantSeeksVisibleFood() {
        let playerID = EntityID(rawValue: 1)
        let childID = EntityID(rawValue: 2)
        let childStart = Vector2(x: 100, y: 100)
        var state = SimulationState(config: SimulationConfig(seed: 123, predatorCountOverride: 0))
        state.organisms = [
            Organism(id: playerID, position: Vector2(x: 400, y: 300), energy: 10, isPlayerControlled: true),
            Organism(id: childID, position: childStart, energy: 80, generation: 2, lineageID: 1),
        ]
        state.playerOrganismID = playerID
        state.food = [
            FoodParticle(id: EntityID(rawValue: 3), position: Vector2(x: 160, y: 100))
        ]
        state.predators = []

        let controller = SimulationController(state: state)
        controller.step()

        let child = controller.state.organisms.first { $0.id == childID }
        XCTAssertGreaterThan(child?.position.x ?? childStart.x, childStart.x)
        XCTAssertEqual(child?.position.y ?? 0, childStart.y, accuracy: 0.001)
    }

    func testDescendantFleesVisiblePredator() {
        let playerID = EntityID(rawValue: 1)
        let childID = EntityID(rawValue: 2)
        let childStart = Vector2(x: 100, y: 100)
        var state = SimulationState(config: SimulationConfig(seed: 123, predatorCountOverride: 0))
        state.organisms = [
            Organism(id: playerID, position: Vector2(x: 400, y: 300), energy: 10, isPlayerControlled: true),
            Organism(id: childID, position: childStart, energy: 80, generation: 2, lineageID: 1),
        ]
        state.playerOrganismID = playerID
        state.predators = [
            Predator(id: EntityID(rawValue: 3), position: Vector2(x: 150, y: 100))
        ]

        let controller = SimulationController(state: state)
        controller.step()

        let child = controller.state.organisms.first { $0.id == childID }
        XCTAssertLessThan(child?.position.x ?? childStart.x, childStart.x)
        XCTAssertEqual(child?.position.y ?? 0, childStart.y, accuracy: 0.001)
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
        // Thresholds rebalanced in Phase 7 (era2=180, era3=480, era4=950, era5=1600) to slow
        // difficulty escalation so a lineage has time to grow before predators multiply.
        XCTAssertEqual(EraSystem.era(for: 10), .primordialPool)
        XCTAssertEqual(EraSystem.era(for: SimulationTuning.era2FitnessThreshold), .reefShallows)
        XCTAssertEqual(EraSystem.era(for: SimulationTuning.era3FitnessThreshold), .landfall)
        XCTAssertEqual(EraSystem.era(for: SimulationTuning.era4FitnessThreshold), .biomes)
        XCTAssertEqual(EraSystem.era(for: SimulationTuning.era5FitnessThreshold), .ecosystemDominance)
        XCTAssertEqual(EraSystem.era(for: SimulationTuning.era5FitnessThreshold + 500), .ecosystemDominance)
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
        state.fitness.survivalTicks = 2000 // Phase 7: era2 threshold raised to 180 composite (~1600 survival ticks).
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
        state.fitness.survivalTicks = 2000 // Phase 7: era2 threshold raised to 180 composite (~1600 survival ticks).
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
        state.fitness.survivalTicks = 2000 // Phase 7: era2 threshold raised to 180 composite (~1600 survival ticks).
        state.tick = 1999
        let controller = SimulationController(state: state)
        let preExtinctionSpeed = EraContent.predatorSpeed(for: .reefShallows)

        controller.step()

        XCTAssertTrue(controller.state.massExtinctionActive)
        let expectedSpeed = preExtinctionSpeed * SimulationTuning.massExtinctionSpeedMultiplier
        XCTAssertTrue(controller.state.predators.allSatisfy { abs($0.speed - expectedSpeed) < 0.001 })
        XCTAssertNotEqual(expectedSpeed, SimulationTuning.predatorSpeed * SimulationTuning.massExtinctionSpeedMultiplier)
    }

    // MARK: - Early-game balance helpers

    /// Representative fixed seeds for early-game balance assertions.
    private static let balanceSeeds: [UInt64] = [42, 77, 123, 999, 7, 2024]

    /// Smart play: flee when a predator is within the player's sense radius, otherwise seek food.
    private func scriptedSmartInput(_ state: SimulationState) -> PlayerInput {
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

    /// Naive learner: only seeks food, never flees (models a new player learning to eat).
    private func scriptedNaiveInput(_ state: SimulationState) -> PlayerInput {
        guard let player = state.playerOrganism else { return PlayerInput() }
        if let food = state.food.min(by: {
            player.position.distance(to: $0.position) < player.position.distance(to: $1.position)
        }) {
            return PlayerInput(movementDirection: (food.position - player.position).normalized)
        }
        return PlayerInput()
    }

    /// Steps a controller, auto-accepting any pending mutation offer so play is uninterrupted.
    private func stepAutoMutation(_ controller: SimulationController, input: PlayerInput) {
        controller.step(input: input)
        if controller.state.phase == .awaitingMutationChoice,
           let offer = controller.state.pendingMutationOffers.first {
            controller.selectMutation(offer)
        }
    }

    func testPrimordialPlayerSurvivesEarlyGame() {
        // Passive survival across representative seeds for the full grace window. The spawn buffer
        // keeps predators out of immediate chase range so a stationary player is not killed before
        // it can learn the controls.
        for seed in Self.balanceSeeds {
            let controller = SimulationController(config: SimulationConfig(seed: seed))
            for _ in 0..<SimulationTuning.primordialGraceTicks {
                controller.step()
            }
            XCTAssertTrue(
                controller.state.playerOrganism?.isAlive ?? false,
                "Passive player died during grace window for seed \(seed)"
            )
        }
    }

    func testPrimordialActivePlayerEatsAndReproduces() {
        // Realistic skilled play: the player should reliably eat and reproduce at least once and
        // keep its lineage alive across representative seeds.
        for seed in Self.balanceSeeds {
            let controller = SimulationController(config: SimulationConfig(seed: seed))
            for _ in 0..<300 {
                stepAutoMutation(controller, input: scriptedSmartInput(controller.state))
                if controller.state.phase == .extinct { break }
            }
            XCTAssertNotEqual(controller.state.phase, .extinct, "Lineage went extinct for seed \(seed)")
            XCTAssertGreaterThan(controller.state.fitness.foodConsumed, 0, "No food eaten for seed \(seed)")
            XCTAssertGreaterThanOrEqual(
                controller.state.fitness.totalOffspring, 1,
                "Player never reproduced for seed \(seed)"
            )
        }
    }

    func testPrimordialNaiveLearnerSurvivesGraceAndReproduces() {
        // A new player who only chases food and never flees must still survive the learning window
        // and reproduce at least once before any death — the core early-game teaching guarantee.
        for seed in Self.balanceSeeds {
            let controller = SimulationController(config: SimulationConfig(seed: seed))
            for tick in 0..<300 {
                stepAutoMutation(controller, input: scriptedNaiveInput(controller.state))
                if tick < SimulationTuning.primordialGraceTicks {
                    XCTAssertNotEqual(
                        controller.state.phase, .extinct,
                        "Naive learner went extinct during grace window (tick \(tick)) for seed \(seed)"
                    )
                }
            }
            XCTAssertGreaterThanOrEqual(
                controller.state.fitness.totalOffspring, 1,
                "Naive learner never reproduced for seed \(seed)"
            )
        }
    }

    func testBootstrapPredatorsRespectSpawnBuffer() {
        for seed in Self.balanceSeeds {
            let controller = SimulationController(config: SimulationConfig(seed: seed))
            let start = controller.state.config.bounds.center
            for predator in controller.state.predators {
                XCTAssertGreaterThanOrEqual(
                    predator.position.distance(to: start),
                    SimulationTuning.predatorSpawnMinDistanceFromPlayer - 0.001,
                    "Predator spawned inside the buffer for seed \(seed)"
                )
            }
        }
    }

    func testPrimordialGraceRampReducesEarlyAggression() {
        // Aggression ramps from the configured floor at tick 0 to full strength by the grace end,
        // and is always full outside the primordial era.
        var graceState = SimulationState(config: SimulationConfig(seed: 42, era: .primordialPool))
        graceState.tick = 0
        let early = SimulationController(state: graceState)
        XCTAssertEqual(
            early.currentPredatorAggression(),
            SimulationTuning.primordialGraceMinAggressionFraction,
            accuracy: 0.001
        )

        graceState.tick = SimulationTuning.primordialGraceTicks / 2
        let mid = SimulationController(state: graceState)
        XCTAssertGreaterThan(mid.currentPredatorAggression(), SimulationTuning.primordialGraceMinAggressionFraction)
        XCTAssertLessThan(mid.currentPredatorAggression(), 1.0)

        graceState.tick = SimulationTuning.primordialGraceTicks
        let late = SimulationController(state: graceState)
        XCTAssertEqual(late.currentPredatorAggression(), 1.0, accuracy: 0.001)

        var reefState = SimulationState(config: SimulationConfig(seed: 42, era: .reefShallows))
        reefState.tick = 0
        let reef = SimulationController(state: reefState)
        XCTAssertEqual(reef.currentPredatorAggression(), 1.0, accuracy: 0.001)
    }

    func testGraceReducesEarlyPredatorBiteDamage() {
        // A predator sitting on a stationary player deals less damage during the grace window
        // than after it. Build a deterministic adjacent-predator scenario for each phase.
        func damageOver(tick: Int) -> Double {
            var state = SimulationState(config: SimulationConfig(seed: 1, era: .primordialPool, enableMassExtinctionEvents: false))
            let playerID = EntityID(rawValue: 1)
            let player = Organism(id: playerID, position: Vector2(x: 400, y: 300), isPlayerControlled: true)
            state.organisms = [player]
            state.playerOrganismID = playerID
            state.predators = [
                Predator(
                    id: EntityID(rawValue: 2),
                    position: Vector2(x: 400, y: 300),
                    speed: EraContent.predatorSpeed(for: .primordialPool),
                    senseRadius: EraContent.predatorSenseRadius(for: .primordialPool),
                    damage: EraContent.predatorDamage(for: .primordialPool)
                )
            ]
            state.tick = tick
            let controller = SimulationController(state: state)
            let before = controller.state.playerOrganism?.health ?? 0
            controller.step()
            let after = controller.state.playerOrganism?.health ?? 0
            return before - after
        }

        let earlyDamage = damageOver(tick: 0)
        let lateDamage = damageOver(tick: SimulationTuning.primordialGraceTicks)
        XCTAssertGreaterThan(earlyDamage, 0)
        XCTAssertGreaterThan(lateDamage, earlyDamage)
    }

    func testEraDamageAndSenseScalingIsMonotonic() {
        let eras: [GameEra] = [.primordialPool, .reefShallows, .landfall, .biomes, .ecosystemDominance]
        for i in 1..<eras.count {
            XCTAssertLessThan(
                EraContent.predatorDamage(for: eras[i - 1]),
                EraContent.predatorDamage(for: eras[i])
            )
            XCTAssertLessThanOrEqual(
                EraContent.predatorSenseRadius(for: eras[i - 1]),
                EraContent.predatorSenseRadius(for: eras[i])
            )
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
