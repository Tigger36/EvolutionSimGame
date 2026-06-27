import Foundation

/// Centralized tuning constants for balancing.
public enum SimulationTuning {
    public static let tickDuration: Double = 1.0 / 30.0
    public static let maxTicksPerStep: Int = 120

    // Organism
    public static let baseEnergy: Double = 100
    public static let baseHealth: Double = 100
    public static let baseSpeed: Double = 80
    public static let baseRadius: Double = 8
    public static let baseMetabolismDrain: Double = 0.15
    public static let movementEnergyCost: Double = 0.08
    public static let starvationDamage: Double = 0.5
    public static let maxAge: Int = 5000

    // Reproduction
    public static let reproductionEnergyThreshold: Double = 60
    public static let reproductionEnergyCost: Double = 40
    public static let safeSiteMinDistanceFromPredator: Double = 100
    public static let offspringTraitVariance: Double = 0.05

    // Food
    public static let foodEnergyValue: Double = 15
    public static let foodRadius: Double = 4
    public static let maxFoodParticles: Int = 40
    public static let foodSpawnInterval: Int = 45

    // Predators — `predatorSpeed`, `predatorDamage`, and `predatorSenseRadius` are era-5 baselines.
    public static let predatorSpeed: Double = 70
    public static let predatorRadius: Double = 14
    public static let predatorDamage: Double = 8
    public static let predatorSenseRadius: Double = 150
    public static let maxPredators: Int = 5
    public static let massExtinctionSpeedMultiplier: Double = 1.5
    /// Idle wander uses this fraction of chase speed when the player is outside sense radius.
    public static let predatorWanderSpeedFraction: Double = 0.35

    /// Minimum distance a newly spawned predator must keep from the player's position.
    /// Chosen larger than the primordial sense radius (~90) plus a reaction margin so no
    /// predator can begin a run already homing on (or sitting on top of) the fixed center
    /// spawn. Without this, random spawns place predators as close as ~2px to the player.
    public static let predatorSpawnMinDistanceFromPlayer: Double = 200

    /// Early-game grace window (primordial era only). For the first `primordialGraceTicks`
    /// predators chase at reduced effectiveness, ramping linearly to full strength. This gives
    /// the player time to learn movement, eating, and reproduction before the first real threat.
    public static let primordialGraceTicks: Int = 240
    /// Multiplier applied to predator chase speed and damage at tick 0 of the grace window
    /// (ramps up to 1.0 by `primordialGraceTicks`). Wander speed is unaffected.
    public static let primordialGraceMinAggressionFraction: Double = 0.35

    // Per-era predator difficulty multipliers (applied to baseline constants above).
    public static let predatorSpeedMultiplierPrimordial: Double = 0.45
    public static let predatorSpeedMultiplierReef: Double = 0.60
    public static let predatorSpeedMultiplierLandfall: Double = 0.75
    public static let predatorSpeedMultiplierBiomes: Double = 0.90
    public static let predatorSpeedMultiplierEcosystem: Double = 1.05

    public static let predatorDamageMultiplierPrimordial: Double = 0.60
    public static let predatorDamageMultiplierReef: Double = 0.75
    public static let predatorDamageMultiplierLandfall: Double = 0.85
    public static let predatorDamageMultiplierBiomes: Double = 1.0
    public static let predatorDamageMultiplierEcosystem: Double = 1.10

    public static let predatorSenseMultiplierPrimordial: Double = 0.60
    public static let predatorSenseMultiplierReef: Double = 0.75
    public static let predatorSenseMultiplierLandfall: Double = 0.85
    public static let predatorSenseMultiplierBiomes: Double = 0.95
    public static let predatorSenseMultiplierEcosystem: Double = 1.0

    // Terrain
    public static let toxicDamagePerTick: Double = 0.4

    // Population
    public static let maxDescendants: Int = 20
    public static let descendantWanderSpeed: Double = 40
    public static let socialDefenseRadius: Double = 80
    public static let maxSocialPredatorDamageReduction: Double = 0.35

    // Pressure
    public static let pressureDecayPerTick: Double = 0.001
    public static let waterExposurePressure: Double = 0.02
    public static let predatorNearMissPressure: Double = 0.05
    public static let foodScarcityPressure: Double = 0.01
    public static let explorationPressure: Double = 0.005
    public static let toxicExposurePressure: Double = 0.03

    // Era progression thresholds
    public static let era2FitnessThreshold: Double = 50
    public static let era3FitnessThreshold: Double = 120
    public static let era4FitnessThreshold: Double = 250
    public static let era5FitnessThreshold: Double = 400

    // Victory goals
    public static let biomeSpreadVictoryCount: Int = 6
    public static let populationVictoryCount: Int = 15
    public static let massExtinctionSurvivalTicks: Int = 3000
}
