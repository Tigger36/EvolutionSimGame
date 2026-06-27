import SwiftUI
import EvolutionSimCore

/// Orchestrates drawing of the full simulation scene into a Canvas context.
///
/// Owns the draw order (backdrop -> terrain -> vignette -> analysis overlays ->
/// food -> predators -> descendants -> player) so layering is defined in one place.
///
/// Entity positions are supplied already interpolated by the view layer so motion
/// is smooth between simulation ticks; the renderer itself performs no simulation
/// logic and never mutates simulation state. The `transform` (camera) is also built
/// by the view so it can follow the interpolated player position.
struct SimulationRenderer {
    let snapshot: SimulationSnapshot
    let organisms: [Organism]
    let food: [FoodParticle]
    let predators: [Predator]
    let debugOverlay: DebugOverlay
    let showBiomeFitOverlay: Bool
    let transform: ViewTransform
    let time: Double
    let reduceMotion: Bool
    let effects: [VisualEffect]
    let now: Date
    let quality: RenderQuality

    func draw(into context: inout GraphicsContext, size: CGSize) {
        TerrainRenderer.drawBackdrop(
            context: &context,
            terrain: snapshot.terrain,
            bounds: snapshot.bounds,
            transform: transform
        )
        TerrainRenderer.draw(
            context: &context,
            terrain: snapshot.terrain,
            transform: transform,
            textureSpacing: quality.terrainTextureSpacing
        )
        TerrainRenderer.drawVignette(
            context: &context,
            size: size,
            currentTerrain: snapshot.playerCurrentTerrain,
            defaultTerrain: snapshot.terrain.defaultType
        )

        if debugOverlay == .terrainCost || showBiomeFitOverlay {
            OverlayRenderer.drawTerrainCost(
                context: &context,
                snapshot: snapshot,
                transform: transform,
                gridStep: quality.terrainCostGridStep
            )
        }
        if debugOverlay == .foodDensity {
            OverlayRenderer.drawFoodDensity(context: &context, food: food, transform: transform)
        }
        if debugOverlay == .dangerZones {
            OverlayRenderer.drawDangerZones(context: &context, predators: predators, transform: transform)
        }

        EntityRenderer.drawFood(context: &context, food: food, transform: transform)
        EntityRenderer.drawPredators(context: &context, predators: predators, transform: transform)
        EntityRenderer.drawDescendants(
            context: &context,
            organisms: organisms,
            transform: transform,
            time: time,
            reduceMotion: reduceMotion
        )

        if let player = organisms.first(where: { $0.id == snapshot.playerOrganismID && $0.isAlive }) {
            if snapshot.playerCanReproduceSafely {
                EffectsRenderer.drawReproductionReady(
                    context: &context,
                    organism: player,
                    transform: transform,
                    time: time,
                    reduceMotion: reduceMotion
                )
            }
            EntityRenderer.drawPlayer(
                context: &context,
                player: player,
                transform: transform,
                time: time,
                reduceMotion: reduceMotion
            )
            if debugOverlay == .lineage {
                OverlayRenderer.drawSenseRadius(context: &context, organism: player, transform: transform)
            }
        }

        if snapshot.phase == .awaitingMutationChoice, let targetID = snapshot.pendingMutationTargetID,
           let target = organisms.first(where: { $0.id == targetID }) {
            EffectsRenderer.drawMutationHighlight(
                context: &context,
                organism: target,
                transform: transform,
                time: time,
                reduceMotion: reduceMotion
            )
        }

        EffectsRenderer.draw(context: &context, effects: effects, transform: transform, size: size, now: now)

        if snapshot.massExtinctionActive {
            EffectsRenderer.drawExtinctionTint(context: &context, size: size, time: time, reduceMotion: reduceMotion)
        }
    }
}
