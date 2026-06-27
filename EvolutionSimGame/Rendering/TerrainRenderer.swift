import SwiftUI
import EvolutionSimCore

/// Draws the environment layers: world backdrop, base terrain, biome regions with
/// soft edges and per-biome texture, plus an edge vignette and current-biome tint.
///
/// All drawing is procedural (Canvas primitives) and deterministic: texture marks
/// are placed on a fixed grid with no randomness, so the scene is stable frame to
/// frame. Styling reads from `VisualTokens`.
enum TerrainRenderer {

    // MARK: - Backdrop (base fill + reference grid)

    static func drawBackdrop(
        context: inout GraphicsContext,
        terrain: TerrainField,
        bounds: WorldBounds,
        transform: ViewTransform
    ) {
        let origin = transform.point(Vector2(x: bounds.minX, y: bounds.minY))
        let far = transform.point(Vector2(x: bounds.maxX, y: bounds.maxY))
        let worldRect = CGRect(x: origin.x, y: origin.y, width: far.x - origin.x, height: far.y - origin.y)

        // Base fill in the default biome color grounds "land" (and any default type)
        // instead of leaving it as bare backdrop.
        context.fill(Path(worldRect), with: .color(VisualTokens.Terrain.color(for: terrain.defaultType)))

        // Faint reference grid for a sense of scale.
        var grid = Path()
        let spacing = VisualTokens.World.gridSpacing
        var x = worldRect.minX
        while x <= worldRect.maxX {
            grid.move(to: CGPoint(x: x, y: worldRect.minY))
            grid.addLine(to: CGPoint(x: x, y: worldRect.maxY))
            x += spacing
        }
        var y = worldRect.minY
        while y <= worldRect.maxY {
            grid.move(to: CGPoint(x: worldRect.minX, y: y))
            grid.addLine(to: CGPoint(x: worldRect.maxX, y: y))
            y += spacing
        }
        context.stroke(
            grid,
            with: .color(VisualTokens.World.grid.opacity(VisualTokens.World.gridOpacity)),
            lineWidth: VisualTokens.World.gridLineWidth
        )
    }

    // MARK: - Biome regions

    static func draw(
        context: inout GraphicsContext,
        terrain: TerrainField,
        transform: ViewTransform,
        textureSpacing: CGFloat = 1.0
    ) {
        for region in terrain.regions {
            let center = transform.point(region.center)
            let radius = transform.scale * region.radius
            let rect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
            let circle = Path(ellipseIn: rect)
            let color = VisualTokens.Terrain.color(for: region.type)

            // Soft-edged fill: solid through most of the radius, fading at the rim so
            // overlapping regions blend instead of stacking as hard plates.
            let gradient = Gradient(stops: [
                .init(color: color.opacity(VisualTokens.Terrain.centerAlpha), location: 0.0),
                .init(color: color.opacity(VisualTokens.Terrain.centerAlpha), location: 0.78),
                .init(color: color.opacity(VisualTokens.Terrain.edgeAlpha), location: 1.0),
            ])
            context.fill(
                circle,
                with: .radialGradient(gradient, center: center, startRadius: 0, endRadius: radius)
            )

            drawTexture(context: &context, region: region, center: center, radius: radius, spacingMultiplier: textureSpacing)
        }
    }

    /// Draws the per-biome texture, clipped to the region circle.
    private static func drawTexture(
        context: inout GraphicsContext,
        region: TerrainRegion,
        center: CGPoint,
        radius: CGFloat,
        spacingMultiplier: CGFloat
    ) {
        guard radius > 6 else { return }
        let markColor = VisualTokens.Terrain.patternColor(for: region.type)
            .opacity(VisualTokens.Terrain.textureOpacity)
        let step = max(8, CGFloat(VisualTokens.Terrain.textureSpacing) * (radius / 120) * spacingMultiplier)
        let markSize = VisualTokens.Terrain.textureMarkSize

        context.drawLayer { layer in
            layer.clip(to: Path(ellipseIn: CGRect(
                x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2
            )))

            var row = 0
            var y = center.y - radius
            while y <= center.y + radius {
                // Stagger alternate rows for a more organic, less gridded look.
                let xOffset = (row % 2 == 0) ? 0 : step / 2
                var x = center.x - radius + xOffset
                while x <= center.x + radius {
                    drawMark(
                        layer: &layer,
                        type: region.type,
                        at: CGPoint(x: x, y: y),
                        size: markSize,
                        color: markColor
                    )
                    x += step
                }
                y += step
                row += 1
            }
        }
    }

    private static func drawMark(
        layer: inout GraphicsContext,
        type: TerrainType,
        at point: CGPoint,
        size: CGFloat,
        color: Color
    ) {
        switch type {
        case .water, .swamp:
            // Horizontal ripple dashes.
            var path = Path()
            path.move(to: CGPoint(x: point.x - size * 1.6, y: point.y))
            path.addLine(to: CGPoint(x: point.x + size * 1.6, y: point.y))
            layer.stroke(path, with: .color(color), lineWidth: size * 0.7)
        case .toxicPool:
            // Bubbles (rings).
            layer.stroke(
                Path(ellipseIn: CGRect(x: point.x - size, y: point.y - size, width: size * 2, height: size * 2)),
                with: .color(color),
                lineWidth: size * 0.5
            )
        case .mountain:
            // Short diagonal strokes (rocky).
            var path = Path()
            path.move(to: CGPoint(x: point.x - size, y: point.y + size))
            path.addLine(to: CGPoint(x: point.x + size, y: point.y - size))
            layer.stroke(path, with: .color(color), lineWidth: size * 0.6)
        case .ice:
            // Crystalline crosses.
            var path = Path()
            path.move(to: CGPoint(x: point.x - size, y: point.y))
            path.addLine(to: CGPoint(x: point.x + size, y: point.y))
            path.move(to: CGPoint(x: point.x, y: point.y - size))
            path.addLine(to: CGPoint(x: point.x, y: point.y + size))
            layer.stroke(path, with: .color(color), lineWidth: size * 0.5)
        case .forest:
            // Dappled canopy: larger soft dots.
            let r = size * 1.4
            layer.fill(
                Path(ellipseIn: CGRect(x: point.x - r, y: point.y - r, width: r * 2, height: r * 2)),
                with: .color(color)
            )
        case .land, .mud, .desert, .tundra:
            // Speckle / grain dots.
            layer.fill(
                Path(ellipseIn: CGRect(x: point.x - size, y: point.y - size, width: size * 2, height: size * 2)),
                with: .color(color)
            )
        }
    }

    // MARK: - Edge vignette and current-biome tint

    /// Darkens the frame edges and, when the player is in a non-default biome, tints
    /// the edge in that biome's color as a persistent "where am I" cue. Reduce-motion
    /// safe: it is static, not an animated flash.
    static func drawVignette(
        context: inout GraphicsContext,
        size: CGSize,
        currentTerrain: TerrainType?,
        defaultTerrain: TerrainType
    ) {
        let rect = CGRect(origin: .zero, size: size)
        let maxRadius = max(size.width, size.height) * 0.75
        let center = CGPoint(x: size.width / 2, y: size.height / 2)

        let vignette = Gradient(stops: [
            .init(color: .clear, location: 0.55),
            .init(color: VisualTokens.World.vignette.opacity(VisualTokens.World.vignetteOpacity), location: 1.0),
        ])
        context.fill(
            Path(rect),
            with: .radialGradient(vignette, center: center, startRadius: 0, endRadius: maxRadius)
        )

        if let currentTerrain, currentTerrain != defaultTerrain {
            let tintColor = VisualTokens.Terrain.color(for: currentTerrain)
            let tint = Gradient(stops: [
                .init(color: .clear, location: 0.6),
                .init(color: tintColor.opacity(VisualTokens.World.biomeTintOpacity), location: 1.0),
            ])
            context.fill(
                Path(rect),
                with: .radialGradient(tint, center: center, startRadius: 0, endRadius: maxRadius)
            )
        }
    }
}
