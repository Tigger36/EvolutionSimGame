import SwiftUI

/// Per-frame rendering quality, tuned to the current layout so the heavier drawing
/// work is scaled back on compact (iPhone) screens to protect the performance budget.
///
/// See `docs/graphics-asset-spec.md` for the budgets these levels target.
struct RenderQuality {
    /// Multiplier on terrain texture spacing. Larger spacing means fewer texture
    /// marks per region (cheaper) at the cost of finer detail.
    let terrainTextureSpacing: CGFloat
    /// Cell size (world units) for the debug terrain-cost grid. Larger is coarser
    /// and cheaper.
    let terrainCostGridStep: Double

    /// Detailed quality for regular-width layouts (iPad, macOS).
    static let regular = RenderQuality(terrainTextureSpacing: 1.0, terrainCostGridStep: 40)
    /// Coarser quality for compact-width layouts (iPhone).
    static let compact = RenderQuality(terrainTextureSpacing: 2.0, terrainCostGridStep: 72)

    static func forSizeClass(_ sizeClass: UserInterfaceSizeClass?) -> RenderQuality {
        sizeClass == .compact ? .compact : .regular
    }
}
