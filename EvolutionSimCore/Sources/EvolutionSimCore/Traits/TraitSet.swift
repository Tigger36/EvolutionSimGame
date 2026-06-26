import Foundation

public struct TraitSet: Codable, Equatable, Sendable {
    public var speed: Double
    public var size: Double
    public var armor: Double
    public var toxinResistance: Double
    public var swimEfficiency: Double
    public var reproductionRate: Double
    public var senseRadius: Double
    public var metabolism: Double
    // Phase 5 expanded traits
    public var nightVision: Double
    public var socialBehavior: Double
    public var parentalCare: Double

    public init(
        speed: Double = 0.5,
        size: Double = 0.5,
        armor: Double = 0.5,
        toxinResistance: Double = 0.5,
        swimEfficiency: Double = 0.5,
        reproductionRate: Double = 0.5,
        senseRadius: Double = 0.5,
        metabolism: Double = 0.5,
        nightVision: Double = 0,
        socialBehavior: Double = 0,
        parentalCare: Double = 0
    ) {
        self.speed = Self.clamp(speed)
        self.size = Self.clamp(size)
        self.armor = Self.clamp(armor)
        self.toxinResistance = Self.clamp(toxinResistance)
        self.swimEfficiency = Self.clamp(swimEfficiency)
        self.reproductionRate = Self.clamp(reproductionRate)
        self.senseRadius = Self.clamp(senseRadius)
        self.metabolism = Self.clamp(metabolism)
        self.nightVision = Self.clamp(nightVision)
        self.socialBehavior = Self.clamp(socialBehavior)
        self.parentalCare = Self.clamp(parentalCare)
    }

    public static let `default` = TraitSet()

    private static func clamp(_ value: Double) -> Double {
        min(1.0, max(0.0, value))
    }

    public mutating func clampAll() {
        speed = Self.clamp(speed)
        size = Self.clamp(size)
        armor = Self.clamp(armor)
        toxinResistance = Self.clamp(toxinResistance)
        swimEfficiency = Self.clamp(swimEfficiency)
        reproductionRate = Self.clamp(reproductionRate)
        senseRadius = Self.clamp(senseRadius)
        metabolism = Self.clamp(metabolism)
        nightVision = Self.clamp(nightVision)
        socialBehavior = Self.clamp(socialBehavior)
        parentalCare = Self.clamp(parentalCare)
    }

    public var effectiveSpeed: Double {
        SimulationTuning.baseSpeed * (0.5 + speed) * (1.0 - size * 0.2) * (1.0 - armor * 0.15)
    }

    public var effectiveRadius: Double {
        SimulationTuning.baseRadius * (0.6 + size * 0.8)
    }

    public var effectiveSenseRadius: Double {
        40 + senseRadius * 80 + nightVision * 20
    }

    public var metabolismDrain: Double {
        SimulationTuning.baseMetabolismDrain * (0.5 + metabolism)
    }

    public var reproductionThreshold: Double {
        SimulationTuning.reproductionEnergyThreshold * (1.2 - reproductionRate * 0.4)
    }

    public mutating func applyVariance(rng: inout SeededRNG, amount: Double = SimulationTuning.offspringTraitVariance) {
        speed += rng.nextDouble(in: -amount...amount)
        size += rng.nextDouble(in: -amount...amount)
        armor += rng.nextDouble(in: -amount...amount)
        toxinResistance += rng.nextDouble(in: -amount...amount)
        swimEfficiency += rng.nextDouble(in: -amount...amount)
        reproductionRate += rng.nextDouble(in: -amount...amount)
        senseRadius += rng.nextDouble(in: -amount...amount)
        metabolism += rng.nextDouble(in: -amount...amount)
        clampAll()
    }

    public func inherited(from parent: TraitSet, rng: inout SeededRNG) -> TraitSet {
        var child = parent
        child.applyVariance(rng: &rng)
        return child
    }
}

public enum MutationOption: String, Codable, CaseIterable, Sendable {
    case strongerFins
    case moistureResistantSkin
    case gills
    case stayGeneralized
    case hardenedShell
    case toxinFilter
    case enhancedSenses
    case fastMetabolism
    case efficientMetabolism
    case largerSize
    case smallerSize
    case parentalCareBoost
    case herdInstinct
    case nightVisionBoost

    public var displayName: String {
        switch self {
        case .strongerFins: return "Stronger Fins"
        case .moistureResistantSkin: return "Moisture-Resistant Skin"
        case .gills: return "Gills"
        case .stayGeneralized: return "Stay Generalized"
        case .hardenedShell: return "Hardened Shell"
        case .toxinFilter: return "Toxin Filter"
        case .enhancedSenses: return "Enhanced Senses"
        case .fastMetabolism: return "Fast Metabolism"
        case .efficientMetabolism: return "Efficient Metabolism"
        case .largerSize: return "Larger Size"
        case .smallerSize: return "Smaller Size"
        case .parentalCareBoost: return "Parental Care"
        case .herdInstinct: return "Herd Instinct"
        case .nightVisionBoost: return "Night Vision"
        }
    }

    public var description: String {
        switch self {
        case .strongerFins: return "Better swimming, worse land agility."
        case .moistureResistantSkin: return "Better land survival, higher energy cost."
        case .gills: return "Better underwater endurance, worse dry survival."
        case .stayGeneralized: return "No major bonus, no major penalty."
        case .hardenedShell: return "More armor, slower movement."
        case .toxinFilter: return "Better toxin resistance, slower metabolism."
        case .enhancedSenses: return "Larger sense radius, higher energy drain."
        case .fastMetabolism: return "Faster movement, hungrier."
        case .efficientMetabolism: return "Lower energy drain, slower speed."
        case .largerSize: return "More health buffer, slower and hungrier."
        case .smallerSize: return "Faster and stealthier, less health."
        case .parentalCareBoost: return "Offspring start with more energy."
        case .herdInstinct: return "Better predator avoidance in groups."
        case .nightVisionBoost: return "See further in low light, slight energy cost."
        }
    }

    public func apply(to traits: inout TraitSet) {
        switch self {
        case .strongerFins:
            traits.swimEfficiency = min(1, traits.swimEfficiency + 0.2)
            traits.speed = max(0, traits.speed - 0.1)
        case .moistureResistantSkin:
            traits.metabolism = min(1, traits.metabolism + 0.1)
            traits.toxinResistance = min(1, traits.toxinResistance + 0.05)
        case .gills:
            traits.swimEfficiency = min(1, traits.swimEfficiency + 0.25)
            traits.metabolism = min(1, traits.metabolism + 0.05)
        case .stayGeneralized:
            break
        case .hardenedShell:
            traits.armor = min(1, traits.armor + 0.2)
            traits.speed = max(0, traits.speed - 0.15)
        case .toxinFilter:
            traits.toxinResistance = min(1, traits.toxinResistance + 0.25)
            traits.metabolism = min(1, traits.metabolism + 0.05)
        case .enhancedSenses:
            traits.senseRadius = min(1, traits.senseRadius + 0.2)
            traits.metabolism = min(1, traits.metabolism + 0.1)
        case .fastMetabolism:
            traits.speed = min(1, traits.speed + 0.15)
            traits.metabolism = min(1, traits.metabolism + 0.15)
        case .efficientMetabolism:
            traits.metabolism = max(0, traits.metabolism - 0.15)
            traits.speed = max(0, traits.speed - 0.1)
        case .largerSize:
            traits.size = min(1, traits.size + 0.2)
            traits.speed = max(0, traits.speed - 0.1)
        case .smallerSize:
            traits.size = max(0, traits.size - 0.2)
            traits.speed = min(1, traits.speed + 0.1)
        case .parentalCareBoost:
            traits.parentalCare = min(1, traits.parentalCare + 0.3)
            traits.reproductionRate = max(0, traits.reproductionRate - 0.05)
        case .herdInstinct:
            traits.socialBehavior = min(1, traits.socialBehavior + 0.3)
            traits.senseRadius = min(1, traits.senseRadius + 0.05)
        case .nightVisionBoost:
            traits.nightVision = min(1, traits.nightVision + 0.3)
            traits.metabolism = min(1, traits.metabolism + 0.05)
        }
        traits.clampAll()
    }
}

public struct PressureState: Codable, Equatable, Sendable {
    public var water: Double = 0
    public var predator: Double = 0
    public var foodScarcity: Double = 0
    public var exploration: Double = 0
    public var toxic: Double = 0

    public mutating func decay() {
        let d = SimulationTuning.pressureDecayPerTick
        water = max(0, water - d)
        predator = max(0, predator - d)
        foodScarcity = max(0, foodScarcity - d)
        exploration = max(0, exploration - d)
        toxic = max(0, toxic - d)
    }

    public var dominantCategory: String {
        let pairs: [(String, Double)] = [
            ("water", water), ("predator", predator), ("food", foodScarcity),
            ("exploration", exploration), ("toxic", toxic),
        ]
        return pairs.max(by: { $0.1 < $1.1 })?.0 ?? "general"
    }

    public var dominantPressureLabel: String? {
        let threshold = 0.05
        let pairs: [(String, Double)] = [
            ("Water exposure", water),
            ("Predator encounters", predator),
            ("Food scarcity", foodScarcity),
            ("Exploration", exploration),
            ("Toxic exposure", toxic),
        ]
        guard let top = pairs.max(by: { $0.1 < $1.1 }), top.1 >= threshold else { return nil }
        return top.0
    }
}

public enum MutationSystem {
    public static func offers(for pressure: PressureState, rng: inout SeededRNG, count: Int = 3) -> [MutationOption] {
        var weighted: [(MutationOption, Double)] = []

        weighted.append((.stayGeneralized, 1.0))
        weighted.append((.strongerFins, 1.0 + pressure.water * 5))
        weighted.append((.gills, 1.0 + pressure.water * 4))
        weighted.append((.moistureResistantSkin, 1.0 + pressure.water * 2))
        weighted.append((.hardenedShell, 1.0 + pressure.predator * 4))
        weighted.append((.enhancedSenses, 1.0 + pressure.predator * 3))
        weighted.append((.efficientMetabolism, 1.0 + pressure.foodScarcity * 4))
        weighted.append((.fastMetabolism, 1.0 + pressure.exploration * 2))
        weighted.append((.toxinFilter, 1.0 + pressure.toxic * 5))
        weighted.append((.herdInstinct, 1.0 + pressure.predator * 2))
        weighted.append((.nightVisionBoost, 1.0 + pressure.exploration * 3))

        var pool = weighted
        var selected: [MutationOption] = []
        while selected.count < count && !pool.isEmpty {
            let total = pool.reduce(0.0) { $0 + $1.1 }
            var roll = rng.nextDouble() * total
            for (index, item) in pool.enumerated() {
                roll -= item.1
                if roll <= 0 {
                    if !selected.contains(item.0) {
                        selected.append(item.0)
                    }
                    pool.remove(at: index)
                    break
                }
            }
        }

        if selected.count < count {
            let remaining = MutationOption.allCases.filter { !selected.contains($0) }
            for option in remaining.prefix(count - selected.count) {
                selected.append(option)
            }
        }
        return selected
    }
}
