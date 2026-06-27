import SwiftUI
import EvolutionSimCore

/// Centralized visual design tokens for the simulation renderer.
///
/// This is the single source of truth for colors, opacities, line weights, and
/// minimum on-screen sizes used when drawing the world. Drawing code should read
/// from here instead of hard-coding literals so the art direction can evolve in
/// one place and stay consistent across terrain, entities, and overlays.
///
/// See `docs/art-direction.md` for the rationale behind these choices and the
/// trait-to-visual mapping that later milestones build on.
enum VisualTokens {

    // MARK: - World backdrop

    enum World {
        /// Base canvas color behind all terrain and entities.
        static let background = Color(red: 0.10, green: 0.13, blue: 0.12)
        /// Faint reference grid drawn over the background.
        static let grid = Color.white
        static let gridOpacity: Double = 0.04
        static let gridSpacing: CGFloat = 64
        static let gridLineWidth: CGFloat = 0.5
        /// Edge vignette darkening the world frame to focus attention inward.
        static let vignette = Color.black
        static let vignetteOpacity: Double = 0.35
        /// Subtle tint applied at the canvas edge for the player's current biome.
        static let biomeTintOpacity: Double = 0.14
    }

    // MARK: - Terrain palette

    /// Biome fill colors. Paired with non-color cues (a per-biome texture and a
    /// legend glyph) so terrain is never identified by hue alone.
    enum Terrain {
        static func color(for type: TerrainType) -> Color {
            switch type {
            case .land: return Color(red: 0.25, green: 0.45, blue: 0.2)
            case .water: return Color(red: 0.15, green: 0.35, blue: 0.7)
            case .mud: return Color(red: 0.4, green: 0.3, blue: 0.15)
            case .toxicPool: return Color(red: 0.5, green: 0.1, blue: 0.5)
            case .forest: return Color(red: 0.1, green: 0.35, blue: 0.15)
            case .swamp: return Color(red: 0.2, green: 0.35, blue: 0.25)
            case .desert: return Color(red: 0.7, green: 0.6, blue: 0.3)
            case .tundra: return Color(red: 0.6, green: 0.65, blue: 0.7)
            case .mountain: return Color(red: 0.45, green: 0.42, blue: 0.4)
            case .ice: return Color(red: 0.75, green: 0.85, blue: 0.95)
            }
        }

        /// Texture mark color for a biome. Lighter biomes get a darker pattern and
        /// vice versa, so the texture reads at any brightness.
        static func patternColor(for type: TerrainType) -> Color {
            switch type {
            case .land: return Color(red: 0.18, green: 0.36, blue: 0.14)
            case .water: return Color(red: 0.45, green: 0.65, blue: 0.95)
            case .mud: return Color(red: 0.28, green: 0.2, blue: 0.1)
            case .toxicPool: return Color(red: 0.8, green: 0.4, blue: 0.85)
            case .forest: return Color(red: 0.05, green: 0.22, blue: 0.08)
            case .swamp: return Color(red: 0.12, green: 0.24, blue: 0.16)
            case .desert: return Color(red: 0.85, green: 0.76, blue: 0.5)
            case .tundra: return Color(red: 0.78, green: 0.82, blue: 0.88)
            case .mountain: return Color(red: 0.3, green: 0.28, blue: 0.26)
            case .ice: return Color(red: 0.95, green: 0.98, blue: 1.0)
            }
        }

        /// SF Symbol identifying a biome in the legend (a non-color cue).
        static func glyph(for type: TerrainType) -> String {
            switch type {
            case .land: return "leaf.fill"
            case .water: return "drop.fill"
            case .mud: return "circle.grid.3x3.fill"
            case .toxicPool: return "exclamationmark.triangle.fill"
            case .forest: return "tree.fill"
            case .swamp: return "humidity.fill"
            case .desert: return "sun.max.fill"
            case .tundra: return "snowflake"
            case .mountain: return "mountain.2.fill"
            case .ice: return "snowflake.circle.fill"
            }
        }

        /// Alpha multiplier applied at a region's outer edge, blending overlapping
        /// regions instead of producing hard "plate" boundaries.
        static let edgeAlpha: Double = 0.0
        /// Alpha at a region's center (full color).
        static let centerAlpha: Double = 1.0
        /// Spacing (world units) between texture marks within a region.
        static let textureSpacing: Double = 22
        /// Opacity of texture marks.
        static let textureOpacity: Double = 0.5
        /// Base size (points) of a texture mark before scaling.
        static let textureMarkSize: CGFloat = 2.2
    }

    // MARK: - Entity roles

    /// Role styling for entities. Color is one channel; shape, outline, and motion
    /// (added in later milestones) carry the rest so roles remain distinguishable
    /// when desaturated.
    enum Entity {
        static let food = Color.green
        static let foodOpacity: Double = 0.8

        static let predator = Color.red
        static let predatorOpacity: Double = 0.85

        static let descendant = Color.cyan
        static let descendantOpacity: Double = 0.7

        static let player = Color.yellow
        static let playerOpacity: Double = 1.0

        /// Outline drawn around the player organism (non-color focus marker).
        static let playerMarker = Color.white
        static let playerMarkerLineWidth: CGFloat = 2
        /// Padding between the body edge and the player marker ring.
        static let playerMarkerInset: CGFloat = 2

        /// Smallest radius (in points) at which an organism is still drawn, so tiny
        /// or zoomed-out organisms remain visible and their silhouette reads.
        static let minOrganismRadius: CGFloat = 4.0

        // MARK: Organism detail (trait-driven)

        /// Body outline weight relative to body radius (baseline, before armor).
        static let bodyOutlineWidthRatio: CGFloat = 0.12
        static let bodyOutline = Color.black
        static let bodyOutlineOpacity: Double = 0.45

        /// Armor plates: segmented arcs and a heavier outline at high armor.
        static let armorPlate = Color.white
        static let armorPlateOpacity: Double = 0.5
        /// Extra outline weight contributed at full armor.
        static let armorOutlineWidthRatio: CGFloat = 0.22

        /// Toxin-resistance core membrane tint.
        static let toxinCore = Color(red: 0.4, green: 0.95, blue: 0.7)
        static let toxinCoreMaxOpacity: Double = 0.55

        /// Fins/tail for swim efficiency.
        static let finOpacity: Double = 0.7
        /// Swim efficiency above this grows visible fins.
        static let finThreshold: Double = 0.5

        /// Eyes; pupil brightens with night vision.
        static let eye = Color.black
        static let eyeOpacity: Double = 0.8
        static let pupil = Color(red: 1.0, green: 0.95, blue: 0.6)

        /// Sense-radius halo (subtle, always-on; distinct from the debug sense ring).
        static let senseHalo = Color.white
        static let senseHaloOpacity: Double = 0.10

        /// Social-behavior group halo (dashed ring at high social behavior).
        static let socialHalo = Color.white
        static let socialHaloOpacity: Double = 0.28
        static let socialThreshold: Double = 0.5

        /// Player focus cues layered on top of the role color.
        static let playerForwardTick = Color.white
    }

    // MARK: - Predator styling

    /// Angular, threat-reading predator silhouette oriented to its heading.
    enum PredatorStyle {
        static let body = Color.red
        static let bodyOpacity: Double = 0.9
        static let outline = Color(red: 0.35, green: 0.0, blue: 0.0)
        static let outlineWidthRatio: CGFloat = 0.14
        static let eye = Color(red: 1.0, green: 0.85, blue: 0.2)
        static let spikeCount = 7
        /// Inner radius of the spiked profile as a fraction of the outer radius.
        static let innerRadiusRatio: CGFloat = 0.6
    }

    // MARK: - Food styling

    enum FoodStyle {
        /// Bright luminous center for a "mote" read.
        static let core = Color(red: 0.8, green: 1.0, blue: 0.6)
        static let edge = Color.green
        static let edgeOpacity: Double = 0.85
    }

    // MARK: - Motion

    /// Subtle idle "breathing" of organisms. Scaled per-organism by metabolism and
    /// fully disabled when Reduce Motion is on.
    enum Motion {
        static let idleWobbleAmplitude: CGFloat = 0.05
        static let idleWobbleBaseRate: Double = 1.4
        static let idleWobbleMetabolismRate: Double = 2.2
    }

    // MARK: - Camera

    /// Camera zoom relative to fit-to-world. 1.0 keeps the entire 800x600 MVP world
    /// visible (preserving situational awareness of off-screen predators), while the
    /// follow/clamp path supports zooming in for larger future worlds.
    enum Camera {
        static let zoom: CGFloat = 1.0
    }

    // MARK: - Overlays

    /// Debug and analysis overlay styling. Opacities are capped so overlays never
    /// fully obscure the primary simulation view.
    enum Overlay {
        // Biome-fit / terrain-cost grid
        static let gridStep: Double = 40
        static let gridDotSize: CGFloat = 6
        static let biomeFitGood = Color.green
        static let biomeFitGoodOpacity: Double = 0.35
        static let biomeFitGoodThreshold: Double = 0.6
        static let biomeFitPoor = Color.red

        // Food density heat blobs
        static let foodDensityCellSize: Double = 60
        static let foodDensityBlobDiameter: CGFloat = 30
        static let foodDensity = Color.green
        static let foodDensityMaxOpacity: Double = 0.5
        static let foodDensitySaturationCount: Double = 5

        // Predator danger rings
        static let dangerZone = Color.red
        static let dangerZoneOpacity: Double = 0.3
        static let dangerZoneLineWidth: CGFloat = 1

        // Player sense radius (lineage overlay)
        static let senseRadius = Color.yellow
        static let senseRadiusOpacity: Double = 0.4
        static let senseRadiusLineWidth: CGFloat = 1
    }
}
