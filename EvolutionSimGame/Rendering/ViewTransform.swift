import SwiftUI
import EvolutionSimCore

/// Maps world-space coordinates into view-space points for Canvas drawing.
///
/// The MVP transform fits the entire world bounds into the available view size,
/// preserving aspect ratio and centering the world. Camera follow and zoom are
/// layered on in a later milestone; keeping the conversion isolated here makes
/// that change additive rather than invasive.
struct ViewTransform {
    let scale: CGFloat
    let offsetX: CGFloat
    let offsetY: CGFloat

    init(bounds: WorldBounds, viewSize: CGSize) {
        let scaleX = viewSize.width / bounds.width
        let scaleY = viewSize.height / bounds.height
        scale = min(scaleX, scaleY)
        offsetX = (viewSize.width - bounds.width * scale) / 2
        offsetY = (viewSize.height - bounds.height * scale) / 2
    }

    /// Follow-camera transform: fits the world, applies `zoom`, centers on `focus`,
    /// and clamps so the view never reveals space outside the world bounds. At
    /// `zoom == 1` this is equivalent to the fit transform (whole world visible).
    init(bounds: WorldBounds, viewSize: CGSize, focus: Vector2, zoom: CGFloat) {
        let fit = min(viewSize.width / bounds.width, viewSize.height / bounds.height)
        let s = fit * max(1, zoom)
        scale = s

        offsetX = Self.clampedOffset(
            desired: viewSize.width / 2 - focus.x * s,
            viewExtent: viewSize.width,
            worldMin: bounds.minX,
            worldMax: bounds.maxX,
            scale: s
        )
        offsetY = Self.clampedOffset(
            desired: viewSize.height / 2 - focus.y * s,
            viewExtent: viewSize.height,
            worldMin: bounds.minY,
            worldMax: bounds.maxY,
            scale: s
        )
    }

    private static func clampedOffset(
        desired: CGFloat,
        viewExtent: CGFloat,
        worldMin: Double,
        worldMax: Double,
        scale: CGFloat
    ) -> CGFloat {
        let worldExtent = CGFloat(worldMax - worldMin) * scale
        if worldExtent <= viewExtent {
            // World smaller than the view: center it.
            return (viewExtent - worldExtent) / 2 - CGFloat(worldMin) * scale
        }
        // World larger than the view: keep edges flush so no void is shown.
        let maxOffset = -CGFloat(worldMin) * scale
        let minOffset = viewExtent - CGFloat(worldMax) * scale
        return min(maxOffset, max(minOffset, desired))
    }

    func point(_ world: Vector2) -> CGPoint {
        CGPoint(
            x: offsetX + world.x * scale,
            y: offsetY + world.y * scale
        )
    }
}
