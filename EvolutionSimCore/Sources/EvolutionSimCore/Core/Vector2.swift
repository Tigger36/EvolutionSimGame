import Foundation

public struct Vector2: Codable, Equatable, Hashable, Sendable {
    public var x: Double
    public var y: Double

    public init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }

    public static let zero = Vector2(x: 0, y: 0)

    public var length: Double {
        (x * x + y * y).squareRoot()
    }

    public var normalized: Vector2 {
        let len = length
        guard len > 1e-9 else { return .zero }
        return Vector2(x: x / len, y: y / len)
    }

    public static func + (lhs: Vector2, rhs: Vector2) -> Vector2 {
        Vector2(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    public static func - (lhs: Vector2, rhs: Vector2) -> Vector2 {
        Vector2(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    public static func * (lhs: Vector2, rhs: Double) -> Vector2 {
        Vector2(x: lhs.x * rhs, y: lhs.y * rhs)
    }

    public static func / (lhs: Vector2, rhs: Double) -> Vector2 {
        Vector2(x: lhs.x / rhs, y: lhs.y / rhs)
    }

    public func distance(to other: Vector2) -> Double {
        (self - other).length
    }

    public func clamped(to bounds: WorldBounds) -> Vector2 {
        Vector2(
            x: min(max(x, bounds.minX), bounds.maxX),
            y: min(max(y, bounds.minY), bounds.maxY)
        )
    }
}
