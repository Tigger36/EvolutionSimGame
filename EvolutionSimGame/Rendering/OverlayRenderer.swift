import SwiftUI
import EvolutionSimCore

/// Draws debug and analysis overlays (terrain cost, food density, danger zones,
/// player sense radius) into a Canvas context.
///
/// Overlays are visual-only diagnostics layered over the simulation. They read
/// from the snapshot and shared tuning, and use capped opacities from
/// `VisualTokens.Overlay` so they never fully obscure the primary view.
enum OverlayRenderer {

    /// Per-cell biome compatibility for the player's traits across the world.
    static func drawTerrainCost(
        context: inout GraphicsContext,
        snapshot: SimulationSnapshot,
        transform: ViewTransform,
        gridStep: Double = VisualTokens.Overlay.gridStep
    ) {
        guard let player = snapshot.playerOrganism else { return }
        let step = gridStep
        let dot = VisualTokens.Overlay.gridDotSize
        var x = snapshot.bounds.minX
        while x <= snapshot.bounds.maxX {
            var y = snapshot.bounds.minY
            while y <= snapshot.bounds.maxY {
                let pos = Vector2(x: x, y: y)
                let terrain = snapshot.terrain.terrain(at: pos)
                let compat = TerrainSystem.biomeCompatibility(traits: player.traits, terrain: terrain)
                let center = transform.point(pos)
                let color = compat > VisualTokens.Overlay.biomeFitGoodThreshold
                    ? VisualTokens.Overlay.biomeFitGood.opacity(VisualTokens.Overlay.biomeFitGoodOpacity)
                    : VisualTokens.Overlay.biomeFitPoor.opacity(1 - compat)
                context.fill(
                    Path(CGRect(x: center.x - dot / 2, y: center.y - dot / 2, width: dot, height: dot)),
                    with: .color(color)
                )
                y += step
            }
            x += step
        }
    }

    /// Heat blobs indicating local food concentration.
    static func drawFoodDensity(
        context: inout GraphicsContext,
        food: [FoodParticle],
        transform: ViewTransform
    ) {
        let cellSize = VisualTokens.Overlay.foodDensityCellSize
        var counts: [String: Int] = [:]
        for particle in food {
            let key = "\(Int(particle.position.x / cellSize)):\(Int(particle.position.y / cellSize))"
            counts[key, default: 0] += 1
        }
        let diameter = VisualTokens.Overlay.foodDensityBlobDiameter
        for (key, count) in counts {
            let parts = key.split(separator: ":")
            guard parts.count == 2, let cx = Double(parts[0]), let cy = Double(parts[1]) else { continue }
            let pos = Vector2(x: cx * cellSize + cellSize / 2, y: cy * cellSize + cellSize / 2)
            let center = transform.point(pos)
            let alpha = min(1.0, Double(count) / VisualTokens.Overlay.foodDensitySaturationCount)
            context.fill(
                Path(ellipseIn: CGRect(
                    x: center.x - diameter / 2,
                    y: center.y - diameter / 2,
                    width: diameter,
                    height: diameter
                )),
                with: .color(VisualTokens.Overlay.foodDensity.opacity(alpha * VisualTokens.Overlay.foodDensityMaxOpacity))
            )
        }
    }

    /// Sense-radius rings around predators, indicating where they can detect prey.
    static func drawDangerZones(
        context: inout GraphicsContext,
        predators: [Predator],
        transform: ViewTransform
    ) {
        for predator in predators where predator.isAlive {
            let center = transform.point(predator.position)
            let radius = transform.scale * predator.senseRadius
            context.stroke(
                Path(ellipseIn: CGRect(
                    x: center.x - radius,
                    y: center.y - radius,
                    width: radius * 2,
                    height: radius * 2
                )),
                with: .color(VisualTokens.Overlay.dangerZone.opacity(VisualTokens.Overlay.dangerZoneOpacity)),
                lineWidth: VisualTokens.Overlay.dangerZoneLineWidth
            )
        }
    }

    /// Ring showing how far the player organism can sense its surroundings.
    static func drawSenseRadius(
        context: inout GraphicsContext,
        organism: Organism,
        transform: ViewTransform
    ) {
        let center = transform.point(organism.position)
        let radius = transform.scale * organism.traits.effectiveSenseRadius
        context.stroke(
            Path(ellipseIn: CGRect(
                x: center.x - radius,
                y: center.y - radius,
                width: radius * 2,
                height: radius * 2
            )),
            with: .color(VisualTokens.Overlay.senseRadius.opacity(VisualTokens.Overlay.senseRadiusOpacity)),
            lineWidth: VisualTokens.Overlay.senseRadiusLineWidth
        )
    }
}
