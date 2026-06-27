import SwiftUI
import EvolutionSimCore

/// Draws an organism whose silhouette encodes its traits, so adaptation is visible
/// in the world without opening the inspector.
///
/// Trait to visual mapping (see `docs/art-direction.md`):
/// - `size`        -> body radius (via `effectiveRadius`)
/// - `speed`       -> streamlined, elongated body along the heading
/// - `swimEfficiency` -> tail fins
/// - `armor`       -> heavier outline plus segmented shell plates
/// - `toxinResistance` -> tinted core membrane
/// - `senseRadius` -> faint sensory halo
/// - `socialBehavior` -> dashed group halo
/// - `nightVision` -> brighter, larger pupils
///
/// Detail degrades gracefully at small on-screen sizes: the silhouette, outline,
/// core tint, and halos read even when fine features (eyes, fins, plates) are too
/// small to draw. The inspector thumbnail renders the same organism large for clear
/// side-by-side comparison.
enum OrganismRenderer {

    static func draw(
        context: inout GraphicsContext,
        organism: Organism,
        transform: ViewTransform,
        roleColor: Color,
        time: Double = 0,
        reduceMotion: Bool = false
    ) {
        let center = transform.point(organism.position)
        let pulse = idlePulse(traits: organism.traits, id: organism.id, time: time, reduceMotion: reduceMotion)
        let radius = max(VisualTokens.Entity.minOrganismRadius, transform.scale * organism.radius) * pulse
        let facing = heading(of: organism.velocity)
        drawDetailed(
            context: &context,
            center: center,
            radius: radius,
            facing: facing,
            traits: organism.traits,
            roleColor: roleColor,
            isPlayer: organism.isPlayerControlled
        )
    }

    /// Shared drawing routine used by both the world renderer and the inspector
    /// thumbnail. `center`/`radius`/`facing` are already in view space.
    static func drawDetailed(
        context: inout GraphicsContext,
        center: CGPoint,
        radius r: CGFloat,
        facing: Double,
        traits: TraitSet,
        roleColor: Color,
        isPlayer: Bool
    ) {
        drawHalos(context: &context, center: center, radius: r, traits: traits)

        var body = context
        body.translateBy(x: center.x, y: center.y)
        body.rotate(by: .radians(facing))

        let major = r * (1 + 0.3 * traits.speed)
        let minor = r * (1 - 0.12 * traits.speed)
        let bodyRect = CGRect(x: -major, y: -minor, width: major * 2, height: minor * 2)

        if r >= VisualTokens.Entity.minOrganismRadius, traits.swimEfficiency > VisualTokens.Entity.finThreshold {
            drawFins(context: &body, major: major, minor: minor, roleColor: roleColor, swim: traits.swimEfficiency)
        }

        body.fill(Path(ellipseIn: bodyRect), with: .color(roleColor))

        if r >= 3, traits.toxinResistance > 0.05 {
            let coreR = r * 0.5
            body.fill(
                Path(ellipseIn: CGRect(x: -coreR, y: -coreR, width: coreR * 2, height: coreR * 2)),
                with: .color(VisualTokens.Entity.toxinCore.opacity(VisualTokens.Entity.toxinCoreMaxOpacity * traits.toxinResistance))
            )
        }

        drawArmor(context: &body, bodyRect: bodyRect, radius: r, armor: traits.armor)

        if r >= VisualTokens.Entity.minOrganismRadius {
            drawEyes(context: &body, major: major, minor: minor, radius: r, nightVision: traits.nightVision)
        }

        if isPlayer, r >= 3 {
            drawForwardTick(context: &body, major: major, radius: r)
        }

        if isPlayer {
            drawPlayerRings(context: &context, center: center, radius: r)
        }
    }

    // MARK: - Components

    private static func drawHalos(
        context: inout GraphicsContext,
        center: CGPoint,
        radius r: CGFloat,
        traits: TraitSet
    ) {
        let senseR = r * (1.4 + CGFloat(traits.senseRadius) * 0.9)
        context.stroke(
            ring(center: center, radius: senseR),
            with: .color(VisualTokens.Entity.senseHalo.opacity(VisualTokens.Entity.senseHaloOpacity * (0.5 + traits.senseRadius))),
            lineWidth: max(1, r * 0.35)
        )

        if traits.socialBehavior > VisualTokens.Entity.socialThreshold {
            let socialR = r * 1.75
            context.stroke(
                ring(center: center, radius: socialR),
                with: .color(VisualTokens.Entity.socialHalo.opacity(VisualTokens.Entity.socialHaloOpacity)),
                style: StrokeStyle(lineWidth: max(1, r * 0.18), dash: [max(2, r * 0.5), max(2, r * 0.5)])
            )
        }
    }

    private static func drawFins(
        context: inout GraphicsContext,
        major: CGFloat,
        minor: CGFloat,
        roleColor: Color,
        swim: Double
    ) {
        let reach = CGFloat(swim) * minor * 1.4
        let finColor = roleColor.opacity(VisualTokens.Entity.finOpacity)
        for side in [CGFloat(1), -1] {
            var fin = Path()
            fin.move(to: CGPoint(x: -major * 0.5, y: side * minor * 0.3))
            fin.addLine(to: CGPoint(x: -major * 1.3, y: side * (minor + reach)))
            fin.addLine(to: CGPoint(x: -major * 0.95, y: side * minor * 0.2))
            fin.closeSubpath()
            context.fill(fin, with: .color(finColor))
        }
    }

    private static func drawArmor(
        context: inout GraphicsContext,
        bodyRect: CGRect,
        radius r: CGFloat,
        armor: Double
    ) {
        let outlineWidth = r * (VisualTokens.Entity.bodyOutlineWidthRatio + VisualTokens.Entity.armorOutlineWidthRatio * CGFloat(armor))
        context.stroke(
            Path(ellipseIn: bodyRect),
            with: .color(VisualTokens.Entity.bodyOutline.opacity(VisualTokens.Entity.bodyOutlineOpacity + 0.3 * armor)),
            lineWidth: max(0.5, outlineWidth)
        )

        guard armor > 0.5, r >= 4 else { return }
        let plateColor = VisualTokens.Entity.armorPlate.opacity(VisualTokens.Entity.armorPlateOpacity)
        context.drawLayer { layer in
            layer.clip(to: Path(ellipseIn: bodyRect))
            let plateCount = 3
            let spacing = bodyRect.width / CGFloat(plateCount + 1)
            for index in 1...plateCount {
                let x = bodyRect.minX + spacing * CGFloat(index)
                var line = Path()
                line.move(to: CGPoint(x: x, y: bodyRect.minY))
                line.addLine(to: CGPoint(x: x, y: bodyRect.maxY))
                layer.stroke(line, with: .color(plateColor), lineWidth: max(0.5, r * 0.12))
            }
        }
    }

    private static func drawEyes(
        context: inout GraphicsContext,
        major: CGFloat,
        minor: CGFloat,
        radius r: CGFloat,
        nightVision: Double
    ) {
        let eyeR = r * 0.2
        let eyeColor = VisualTokens.Entity.eye.opacity(VisualTokens.Entity.eyeOpacity)
        for side in [CGFloat(1), -1] {
            let eyeCenter = CGPoint(x: major * 0.45, y: side * minor * 0.4)
            context.fill(
                Path(ellipseIn: CGRect(x: eyeCenter.x - eyeR, y: eyeCenter.y - eyeR, width: eyeR * 2, height: eyeR * 2)),
                with: .color(eyeColor)
            )
            let pupilR = eyeR * (0.4 + 0.5 * CGFloat(nightVision))
            context.fill(
                Path(ellipseIn: CGRect(x: eyeCenter.x - pupilR, y: eyeCenter.y - pupilR, width: pupilR * 2, height: pupilR * 2)),
                with: .color(VisualTokens.Entity.pupil.opacity(0.4 + 0.6 * nightVision))
            )
        }
    }

    private static func drawForwardTick(
        context: inout GraphicsContext,
        major: CGFloat,
        radius r: CGFloat
    ) {
        let tip = major + r * 0.5
        let base = major + r * 0.05
        var tick = Path()
        tick.move(to: CGPoint(x: tip, y: 0))
        tick.addLine(to: CGPoint(x: base, y: -r * 0.3))
        tick.addLine(to: CGPoint(x: base, y: r * 0.3))
        tick.closeSubpath()
        context.fill(tick, with: .color(VisualTokens.Entity.playerForwardTick))
    }

    private static func drawPlayerRings(
        context: inout GraphicsContext,
        center: CGPoint,
        radius r: CGFloat
    ) {
        let inner = r + VisualTokens.Entity.playerMarkerInset
        context.stroke(
            ring(center: center, radius: inner),
            with: .color(VisualTokens.Entity.playerMarker),
            lineWidth: VisualTokens.Entity.playerMarkerLineWidth
        )
        let outer = inner + max(2, r * 0.35)
        context.stroke(
            ring(center: center, radius: outer),
            with: .color(VisualTokens.Entity.playerMarker.opacity(0.5)),
            lineWidth: max(1, VisualTokens.Entity.playerMarkerLineWidth * 0.6)
        )
    }

    // MARK: - Helpers

    private static func heading(of velocity: Vector2) -> Double {
        velocity.length > 0.01 ? atan2(velocity.y, velocity.x) : -.pi / 2
    }

    /// A subtle per-organism "breathing" scale. Each organism is desynchronized by a
    /// phase derived from its id, and pulses faster with higher metabolism. Returns
    /// 1.0 (no motion) when Reduce Motion is enabled.
    private static func idlePulse(
        traits: TraitSet,
        id: EntityID,
        time: Double,
        reduceMotion: Bool
    ) -> CGFloat {
        guard !reduceMotion else { return 1 }
        let phase = Double(id.rawValue % 100) / 100 * 2 * .pi
        let rate = VisualTokens.Motion.idleWobbleBaseRate
            + VisualTokens.Motion.idleWobbleMetabolismRate * traits.metabolism
        return 1 + VisualTokens.Motion.idleWobbleAmplitude * CGFloat(sin(time * rate + phase))
    }

    private static func ring(center: CGPoint, radius: CGFloat) -> Path {
        Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
    }
}
