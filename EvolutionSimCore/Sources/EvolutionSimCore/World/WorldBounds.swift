import Foundation

public struct WorldBounds: Codable, Equatable, Sendable {
    public let minX: Double
    public let minY: Double
    public let maxX: Double
    public let maxY: Double

    public init(minX: Double, minY: Double, maxX: Double, maxY: Double) {
        self.minX = minX
        self.minY = minY
        self.maxX = maxX
        self.maxY = maxY
    }

    public static let standard = WorldBounds(minX: 0, minY: 0, maxX: 800, maxY: 600)

    public var width: Double { maxX - minX }
    public var height: Double { maxY - minY }
    public var center: Vector2 { Vector2(x: (minX + maxX) / 2, y: (minY + maxY) / 2) }

    public func contains(_ point: Vector2) -> Bool {
        point.x >= minX && point.x <= maxX && point.y >= minY && point.y <= maxY
    }

    public func randomPoint(rng: inout SeededRNG) -> Vector2 {
        Vector2(
            x: rng.nextDouble(in: minX...maxX),
            y: rng.nextDouble(in: minY...maxY)
        )
    }
}
