import Foundation

public struct TraitDelta: Equatable, Sendable {
    public let name: String
    public let before: Double
    public let after: Double

    public var delta: Double { after - before }

    public var formattedDelta: String {
        let points = Int((delta * 100).rounded())
        guard points != 0 else { return "" }
        return points > 0 ? "+\(points)%" : "\(points)%"
    }

    public init(name: String, before: Double, after: Double) {
        self.name = name
        self.before = before
        self.after = after
    }
}

public struct BiomeCompatibilityChange: Equatable, Sendable {
    public let terrain: TerrainType
    public let before: Double
    public let after: Double

    public var delta: Double { after - before }

    public init(terrain: TerrainType, before: Double, after: Double) {
        self.terrain = terrain
        self.before = before
        self.after = after
    }
}

public enum MutationPreview {
    private static let traitKeys: [(String, KeyPath<TraitSet, Double>)] = [
        ("Speed", \.speed),
        ("Size", \.size),
        ("Armor", \.armor),
        ("Toxin Resistance", \.toxinResistance),
        ("Swim", \.swimEfficiency),
        ("Reproduction", \.reproductionRate),
        ("Sense", \.senseRadius),
        ("Metabolism", \.metabolism),
        ("Night Vision", \.nightVision),
        ("Social", \.socialBehavior),
        ("Parental Care", \.parentalCare),
    ]

    public static func traitDeltas(option: MutationOption, base: TraitSet) -> [TraitDelta] {
        var modified = base
        option.apply(to: &modified)
        return traitKeys.compactMap { name, keyPath in
            let before = base[keyPath: keyPath]
            let after = modified[keyPath: keyPath]
            guard abs(after - before) >= 0.001 else { return nil }
            return TraitDelta(name: name, before: before, after: after)
        }
    }

    public static func formattedTraitDeltas(option: MutationOption, base: TraitSet) -> String {
        traitDeltas(option: option, base: base)
            .map { "\($0.name) \($0.formattedDelta)" }
            .joined(separator: ", ")
    }

    public static func compatibilityChanges(
        option: MutationOption,
        base: TraitSet,
        terrains: [TerrainType] = TerrainType.allCases
    ) -> [BiomeCompatibilityChange] {
        terrains.map { terrain in
            let before = TerrainSystem.biomeCompatibility(traits: base, terrain: terrain)
            var modified = base
            option.apply(to: &modified)
            let after = TerrainSystem.biomeCompatibility(traits: modified, terrain: terrain)
            return BiomeCompatibilityChange(terrain: terrain, before: before, after: after)
        }
    }

    public static func topCompatibilityChanges(
        option: MutationOption,
        base: TraitSet,
        limit: Int = 2
    ) -> [BiomeCompatibilityChange] {
        compatibilityChanges(option: option, base: base)
            .filter { abs($0.delta) >= 0.01 }
            .sorted { abs($0.delta) > abs($1.delta) }
            .prefix(limit)
            .map { $0 }
    }

    public static func formattedBiomeImpact(option: MutationOption, base: TraitSet) -> String {
        let changes = topCompatibilityChanges(option: option, base: base)
        guard !changes.isEmpty else { return "Minimal biome shift" }
        return changes.map { change in
            let arrow = change.delta > 0 ? "↑" : "↓"
            return "\(change.terrain.displayName) \(arrow)"
        }
        .joined(separator: ", ")
    }
}
