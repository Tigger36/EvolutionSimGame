import SwiftUI
import EvolutionSimCore

/// Draws simulation entities (food, predators, organisms) into a Canvas context.
///
/// All visuals are derived from the immutable `SimulationSnapshot`; this renderer
/// never mutates simulation state. Organisms are delegated to `OrganismRenderer`,
/// which encodes traits into the silhouette. Predators use an angular threat
/// profile and food reads as a small luminous mote.
enum EntityRenderer {

    static func drawFood(
        context: inout GraphicsContext,
        food: [FoodParticle],
        transform: ViewTransform
    ) {
        for particle in food {
            let center = transform.point(particle.position)
            let radius = max(2, transform.scale * particle.radius)
            let rect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
            let gradient = Gradient(colors: [
                VisualTokens.FoodStyle.core,
                VisualTokens.FoodStyle.edge.opacity(VisualTokens.FoodStyle.edgeOpacity),
            ])
            context.fill(
                Path(ellipseIn: rect),
                with: .radialGradient(gradient, center: center, startRadius: 0, endRadius: radius)
            )
        }
    }

    static func drawPredators(
        context: inout GraphicsContext,
        predators: [Predator],
        transform: ViewTransform
    ) {
        for predator in predators where predator.isAlive {
            drawPredator(context: &context, predator: predator, transform: transform)
        }
    }

    static func drawDescendants(
        context: inout GraphicsContext,
        organisms: [Organism],
        transform: ViewTransform,
        time: Double,
        reduceMotion: Bool
    ) {
        let color = VisualTokens.Entity.descendant.opacity(VisualTokens.Entity.descendantOpacity)
        for organism in organisms where organism.isAlive && !organism.isPlayerControlled {
            OrganismRenderer.draw(
                context: &context,
                organism: organism,
                transform: transform,
                roleColor: color,
                time: time,
                reduceMotion: reduceMotion
            )
        }
    }

    static func drawPlayer(
        context: inout GraphicsContext,
        player: Organism,
        transform: ViewTransform,
        time: Double,
        reduceMotion: Bool
    ) {
        let color = VisualTokens.Entity.player.opacity(VisualTokens.Entity.playerOpacity)
        OrganismRenderer.draw(
            context: &context,
            organism: player,
            transform: transform,
            roleColor: color,
            time: time,
            reduceMotion: reduceMotion
        )
    }

    // MARK: - Predator

    private static func drawPredator(
        context: inout GraphicsContext,
        predator: Predator,
        transform: ViewTransform
    ) {
        let center = transform.point(predator.position)
        let radius = max(5, transform.scale * predator.radius)
        let facing = predator.velocity.length > 0.01
            ? atan2(predator.velocity.y, predator.velocity.x)
            : -.pi / 2

        var ctx = context
        ctx.translateBy(x: center.x, y: center.y)
        ctx.rotate(by: .radians(facing))

        // Spiked, forward-pointing silhouette.
        let spikes = VisualTokens.PredatorStyle.spikeCount
        let inner = radius * VisualTokens.PredatorStyle.innerRadiusRatio
        var path = Path()
        for index in 0..<(spikes * 2) {
            let isOuter = index % 2 == 0
            // Sharpen the front-most point to read as a heading.
            let baseAngle = Double(index) / Double(spikes * 2) * 2 * .pi
            let reach: CGFloat = isOuter ? (abs(baseAngle) < 0.4 ? radius * 1.4 : radius) : inner
            let pt = CGPoint(x: cos(baseAngle) * reach, y: sin(baseAngle) * reach)
            if index == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
        }
        path.closeSubpath()

        ctx.fill(path, with: .color(VisualTokens.PredatorStyle.body.opacity(VisualTokens.PredatorStyle.bodyOpacity)))
        ctx.stroke(
            path,
            with: .color(VisualTokens.PredatorStyle.outline),
            lineWidth: max(0.5, radius * VisualTokens.PredatorStyle.outlineWidthRatio)
        )

        // Forward-facing eyes.
        let eyeR = radius * 0.16
        for side in [CGFloat(1), -1] {
            let eyeCenter = CGPoint(x: radius * 0.45, y: side * radius * 0.3)
            ctx.fill(
                Path(ellipseIn: CGRect(x: eyeCenter.x - eyeR, y: eyeCenter.y - eyeR, width: eyeR * 2, height: eyeR * 2)),
                with: .color(VisualTokens.PredatorStyle.eye)
            )
        }
    }
}
