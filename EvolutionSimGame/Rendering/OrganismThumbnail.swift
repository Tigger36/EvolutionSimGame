import SwiftUI
import EvolutionSimCore

/// A static preview of an organism rendered with the same trait-driven drawing used
/// in the world, sized large so adaptation is clearly legible in the inspector and
/// mutation cards.
struct OrganismThumbnail: View {
    let traits: TraitSet
    var isPlayer: Bool = true
    /// Heading used for the preview; defaults to facing right for a clear profile.
    var facing: Double = 0
    var size: CGFloat = 64

    private var roleColor: Color {
        isPlayer
            ? VisualTokens.Entity.player.opacity(VisualTokens.Entity.playerOpacity)
            : VisualTokens.Entity.descendant.opacity(VisualTokens.Entity.descendantOpacity)
    }

    var body: some View {
        Canvas { context, canvasSize in
            let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
            // Leave headroom for halos and the player marker rings.
            let radius = min(canvasSize.width, canvasSize.height) * 0.32
            var ctx = context
            OrganismRenderer.drawDetailed(
                context: &ctx,
                center: center,
                radius: radius,
                facing: facing,
                traits: traits,
                roleColor: roleColor,
                isPlayer: isPlayer
            )
        }
        .frame(width: size, height: size)
        .background(VisualTokens.World.background, in: RoundedRectangle(cornerRadius: 8))
        .accessibilityHidden(true)
    }
}
