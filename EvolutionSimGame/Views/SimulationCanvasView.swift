import SwiftUI
import EvolutionSimCore

struct SimulationCanvasView: View {
    let snapshot: SimulationSnapshot
    let debugOverlay: DebugOverlay

    var body: some View {
        Canvas { context, size in
            let transform = ViewTransform(bounds: snapshot.bounds, viewSize: size)

            drawTerrain(context: &context, transform: transform)
            if debugOverlay == .terrainCost {
                drawTerrainCostOverlay(context: &context, transform: transform)
            }
            if debugOverlay == .foodDensity {
                drawFoodDensityOverlay(context: &context, transform: transform)
            }
            if debugOverlay == .dangerZones {
                drawDangerZones(context: &context, transform: transform)
            }

            for food in snapshot.food {
                let center = transform.point(food.position)
                let radius = transform.scale * food.radius
                context.fill(
                    Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)),
                    with: .color(.green.opacity(0.8))
                )
            }

            for predator in snapshot.predators where predator.isAlive {
                let center = transform.point(predator.position)
                let radius = transform.scale * predator.radius
                context.fill(
                    Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)),
                    with: .color(.red.opacity(0.85))
                )
            }

            for organism in snapshot.organisms where organism.isAlive && !organism.isPlayerControlled {
                drawOrganism(context: &context, organism: organism, transform: transform, color: .cyan.opacity(0.7))
            }

            if let playerID = snapshot.playerOrganismID,
               let player = snapshot.organisms.first(where: { $0.id == playerID && $0.isAlive }) {
                drawOrganism(context: &context, organism: player, transform: transform, color: .yellow)
                if debugOverlay == .lineage {
                    drawSenseRadius(context: &context, organism: player, transform: transform)
                }
            }
        }
        .background(Color(red: 0.12, green: 0.15, blue: 0.12))
        .accessibilityIdentifier("simulationCanvas")
    }

    private func drawOrganism(context: inout GraphicsContext, organism: Organism, transform: ViewTransform, color: Color) {
        let center = transform.point(organism.position)
        let radius = transform.scale * organism.radius
        context.fill(
            Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)),
            with: .color(color)
        )
        if organism.isPlayerControlled {
            context.stroke(
                Path(ellipseIn: CGRect(x: center.x - radius - 2, y: center.y - radius - 2, width: radius * 2 + 4, height: radius * 2 + 4)),
                with: .color(.white),
                lineWidth: 2
            )
        }
    }

    private func drawTerrain(context: inout GraphicsContext, transform: ViewTransform) {
        for region in snapshot.terrain.regions {
            let center = transform.point(region.center)
            let radius = transform.scale * region.radius
            let color = terrainColor(region.type)
            context.fill(
                Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)),
                with: .color(color)
            )
        }
    }

    private func drawTerrainCostOverlay(context: inout GraphicsContext, transform: ViewTransform) {
        guard let player = snapshot.organisms.first(where: { $0.id == snapshot.playerOrganismID }) else { return }
        let gridStep = 40.0
        var x = snapshot.bounds.minX
        while x <= snapshot.bounds.maxX {
            var y = snapshot.bounds.minY
            while y <= snapshot.bounds.maxY {
                let pos = Vector2(x: x, y: y)
                let terrain = snapshot.terrain.terrain(at: pos)
                let compat = TerrainSystem.biomeCompatibility(traits: player.traits, terrain: terrain)
                let center = transform.point(pos)
                let size: CGFloat = 6
                context.fill(
                    Path(CGRect(x: center.x - size/2, y: center.y - size/2, width: size, height: size)),
                    with: .color(Color.red.opacity(1 - compat))
                )
                y += gridStep
            }
            x += gridStep
        }
    }

    private func drawFoodDensityOverlay(context: inout GraphicsContext, transform: ViewTransform) {
        let cellSize = 60.0
        var counts: [String: Int] = [:]
        for food in snapshot.food {
            let key = "\(Int(food.position.x / cellSize)):\(Int(food.position.y / cellSize))"
            counts[key, default: 0] += 1
        }
        for (key, count) in counts {
            let parts = key.split(separator: ":")
            guard parts.count == 2, let cx = Double(parts[0]), let cy = Double(parts[1]) else { continue }
            let pos = Vector2(x: cx * cellSize + cellSize/2, y: cy * cellSize + cellSize/2)
            let center = transform.point(pos)
            let alpha = min(1.0, Double(count) / 5.0)
            context.fill(
                Path(ellipseIn: CGRect(x: center.x - 15, y: center.y - 15, width: 30, height: 30)),
                with: .color(.green.opacity(alpha * 0.5))
            )
        }
    }

    private func drawDangerZones(context: inout GraphicsContext, transform: ViewTransform) {
        for predator in snapshot.predators where predator.isAlive {
            let center = transform.point(predator.position)
            let radius = transform.scale * SimulationTuning.predatorSenseRadius
            context.stroke(
                Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)),
                with: .color(.red.opacity(0.3)),
                lineWidth: 1
            )
        }
    }

    private func drawSenseRadius(context: inout GraphicsContext, organism: Organism, transform: ViewTransform) {
        let center = transform.point(organism.position)
        let radius = transform.scale * organism.traits.effectiveSenseRadius
        context.stroke(
            Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)),
            with: .color(.yellow.opacity(0.4)),
            lineWidth: 1
        )
    }

    private func terrainColor(_ type: TerrainType) -> Color {
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
}

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

    func point(_ world: Vector2) -> CGPoint {
        CGPoint(
            x: offsetX + world.x * scale,
            y: offsetY + world.y * scale
        )
    }
}

struct DebugOverlayLegend: View {
    let overlay: DebugOverlay

    var body: some View {
        VStack {
            HStack {
                Text(overlay.displayName)
                    .font(.caption.bold())
                    .padding(6)
                    .background(.ultraThinMaterial, in: Capsule())
                Spacer()
            }
            Spacer()
        }
        .padding(8)
        .allowsHitTesting(false)
    }
}
