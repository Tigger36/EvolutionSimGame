import EvolutionSimCore

/// Entities that can be position-interpolated between simulation snapshots for
/// smooth rendering. Interpolation is purely visual and never feeds back into the
/// simulation.
protocol PositionedEntity {
    var id: EntityID { get }
    var position: Vector2 { get set }
}

extension Organism: PositionedEntity {}
extension FoodParticle: PositionedEntity {}
extension Predator: PositionedEntity {}

enum EntityInterpolation {
    /// Returns `current` entities with positions linearly interpolated from their
    /// matching `previous` position by `alpha` (0 = previous, 1 = current). Entities
    /// without a match in `previous` (newly spawned) are returned at their current
    /// position.
    static func interpolate<T: PositionedEntity>(
        current: [T],
        previous: [T]?,
        alpha: Double
    ) -> [T] {
        guard let previous, alpha < 1 else { return current }

        var previousPositions: [EntityID: Vector2] = [:]
        previousPositions.reserveCapacity(previous.count)
        for entity in previous {
            previousPositions[entity.id] = entity.position
        }

        return current.map { entity in
            guard let from = previousPositions[entity.id] else { return entity }
            var interpolated = entity
            interpolated.position = Vector2(
                x: from.x + (entity.position.x - from.x) * alpha,
                y: from.y + (entity.position.y - from.y) * alpha
            )
            return interpolated
        }
    }
}
