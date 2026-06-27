import SwiftUI
import EvolutionSimCore

/// A transient, time-based visual effect triggered by a simulation event detected in
/// the UI layer (e.g. reproduction, death, lineage handoff, damage). Effects are
/// purely cosmetic and never influence the simulation.
struct VisualEffect: Identifiable {
    enum Kind {
        case birth
        case death
        case focusPulse
        case damageFlash
    }

    let id = UUID()
    let kind: Kind
    /// World-space position (unused for full-screen effects like `damageFlash`).
    let position: Vector2
    let start: Date
    let duration: Double

    func progress(at now: Date) -> Double {
        guard duration > 0 else { return 1 }
        return min(1, max(0, now.timeIntervalSince(start) / duration))
    }

    func isExpired(at now: Date) -> Bool {
        now.timeIntervalSince(start) > duration
    }
}

/// Draws transient effects, the mutation-target highlight, and the mass-extinction
/// tint. Reads only positions/time; performs no simulation logic.
enum EffectsRenderer {

    static func draw(
        context: inout GraphicsContext,
        effects: [VisualEffect],
        transform: ViewTransform,
        size: CGSize,
        now: Date
    ) {
        for effect in effects where !effect.isExpired(at: now) {
            let t = effect.progress(at: now)
            switch effect.kind {
            case .birth:
                drawExpandingRing(
                    context: &context,
                    center: transform.point(effect.position),
                    progress: t,
                    maxRadius: 26,
                    color: VisualTokens.FoodStyle.core,
                    lineWidth: 3
                )
            case .death:
                drawFadingPuff(
                    context: &context,
                    center: transform.point(effect.position),
                    progress: t,
                    radius: 16,
                    color: VisualTokens.Entity.bodyOutline
                )
            case .focusPulse:
                let center = transform.point(effect.position)
                drawExpandingRing(context: &context, center: center, progress: t, maxRadius: 34, color: VisualTokens.Entity.playerMarker, lineWidth: 3)
                drawExpandingRing(context: &context, center: center, progress: min(1, t + 0.25), maxRadius: 34, color: VisualTokens.Entity.playerMarker, lineWidth: 2)
            case .damageFlash:
                let alpha = (1 - t) * 0.28
                context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.red.opacity(alpha)))
            }
        }
    }

    /// Pulsing highlight around the offspring awaiting a mutation choice.
    static func drawMutationHighlight(
        context: inout GraphicsContext,
        organism: Organism,
        transform: ViewTransform,
        time: Double,
        reduceMotion: Bool
    ) {
        let center = transform.point(organism.position)
        let baseRadius = max(VisualTokens.Entity.minOrganismRadius, transform.scale * organism.radius)
        let pulse = reduceMotion ? 1.0 : 1.0 + 0.18 * sin(time * 4)
        let radius = baseRadius * 2.2 * pulse
        context.stroke(
            ring(center: center, radius: radius),
            with: .color(VisualTokens.Entity.toxinCore),
            style: StrokeStyle(lineWidth: 2.5, dash: [6, 4])
        )
    }

    /// Soft pulsing glow around the player when reproduction is ready and safe.
    static func drawReproductionReady(
        context: inout GraphicsContext,
        organism: Organism,
        transform: ViewTransform,
        time: Double,
        reduceMotion: Bool
    ) {
        let center = transform.point(organism.position)
        let baseRadius = max(VisualTokens.Entity.minOrganismRadius, transform.scale * organism.radius)
        let pulse = reduceMotion ? 1.0 : 1.0 + 0.12 * sin(time * 3)
        let radius = baseRadius * 1.9 * pulse
        let alpha = reduceMotion ? 0.35 : 0.25 + 0.15 * (0.5 + 0.5 * sin(time * 3))
        context.stroke(
            ring(center: center, radius: radius),
            with: .color(VisualTokens.FoodStyle.core.opacity(alpha)),
            lineWidth: max(1.5, baseRadius * 0.3)
        )
    }

    /// Ominous desaturated tint while a mass-extinction event is active.
    static func drawExtinctionTint(
        context: inout GraphicsContext,
        size: CGSize,
        time: Double,
        reduceMotion: Bool
    ) {
        let pulse = reduceMotion ? 0.0 : 0.04 * (0.5 + 0.5 * sin(time * 1.5))
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let maxRadius = max(size.width, size.height) * 0.8
        let gradient = Gradient(stops: [
            .init(color: .clear, location: 0.35),
            .init(color: Color(red: 0.3, green: 0.0, blue: 0.05).opacity(0.45 + pulse), location: 1.0),
        ])
        context.fill(
            Path(CGRect(origin: .zero, size: size)),
            with: .radialGradient(gradient, center: center, startRadius: 0, endRadius: maxRadius)
        )
    }

    // MARK: - Helpers

    private static func drawExpandingRing(
        context: inout GraphicsContext,
        center: CGPoint,
        progress: Double,
        maxRadius: CGFloat,
        color: Color,
        lineWidth: CGFloat
    ) {
        let radius = maxRadius * progress
        let alpha = 1 - progress
        context.stroke(
            ring(center: center, radius: radius),
            with: .color(color.opacity(alpha)),
            lineWidth: lineWidth * (1 - progress * 0.5)
        )
    }

    private static func drawFadingPuff(
        context: inout GraphicsContext,
        center: CGPoint,
        progress: Double,
        radius: CGFloat,
        color: Color
    ) {
        let r = radius * (1 - progress * 0.5)
        let alpha = (1 - progress) * 0.5
        context.fill(
            Path(ellipseIn: CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2)),
            with: .color(color.opacity(alpha))
        )
    }

    private static func ring(center: CGPoint, radius: CGFloat) -> Path {
        Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
    }
}
