import SwiftUI
import EvolutionSimCore

/// Thin SwiftUI host for the simulation Canvas.
///
/// Drawing is delegated to `SimulationRenderer` (see `EvolutionSimGame/Rendering/`).
/// This view drives smooth playback by interpolating entity positions between
/// simulation ticks on an animation timeline, builds the (follow-capable) camera
/// transform, and forwards a motion clock. All of this is visual only; the
/// simulation is never mutated. Reduce Motion disables interpolation and idle
/// animation.
struct SimulationCanvasView: View {
    let snapshot: SimulationSnapshot
    let debugOverlay: DebugOverlay
    let showBiomeFitOverlay: Bool
    let showTerrainLegend: Bool
    let onDismissLegend: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var previousSnapshot: SimulationSnapshot?
    @State private var latestSnapshot: SimulationSnapshot?
    @State private var snapshotTime: Date = .now
    @State private var effects: [VisualEffect] = []

    var body: some View {
        ZStack(alignment: .topLeading) {
            TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: snapshot.isPaused || reduceMotion)) { timeline in
                Canvas { context, size in
                    render(into: &context, size: size, now: timeline.date)
                }
                .background(VisualTokens.World.background)
                .accessibilityIdentifier("simulationCanvas")
            }
            .onChange(of: snapshot.tick) { _, _ in
                detectEvents(old: latestSnapshot, new: snapshot)
                previousSnapshot = latestSnapshot
                latestSnapshot = snapshot
                snapshotTime = Date()
            }
            .onAppear {
                latestSnapshot = snapshot
                snapshotTime = Date()
            }

            if showTerrainLegend {
                TerrainLegendView(
                    terrains: snapshot.activeTerrainsForLegend(),
                    onDismiss: onDismissLegend
                )
                .padding(8)
            }

            if showBiomeFitOverlay {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        BiomeFitLegendView()
                            .padding(8)
                    }
                }
                .allowsHitTesting(false)
            }
        }
    }

    private func render(into context: inout GraphicsContext, size: CGSize, now: Date) {
        let alpha = interpolationFactor(now: now)
        let previous = previousSnapshot
        let organisms = EntityInterpolation.interpolate(current: snapshot.organisms, previous: previous?.organisms, alpha: alpha)
        let food = EntityInterpolation.interpolate(current: snapshot.food, previous: previous?.food, alpha: alpha)
        let predators = EntityInterpolation.interpolate(current: snapshot.predators, previous: previous?.predators, alpha: alpha)

        let focus = organisms.first(where: { $0.id == snapshot.playerOrganismID && $0.isAlive })?.position
            ?? snapshot.bounds.center
        let transform = ViewTransform(
            bounds: snapshot.bounds,
            viewSize: size,
            focus: focus,
            zoom: VisualTokens.Camera.zoom
        )

        let renderer = SimulationRenderer(
            snapshot: snapshot,
            organisms: organisms,
            food: food,
            predators: predators,
            debugOverlay: debugOverlay,
            showBiomeFitOverlay: showBiomeFitOverlay,
            transform: transform,
            time: reduceMotion ? 0 : now.timeIntervalSinceReferenceDate,
            reduceMotion: reduceMotion,
            effects: effects,
            now: now,
            quality: RenderQuality.forSizeClass(horizontalSizeClass)
        )
        renderer.draw(into: &context, size: size)
    }

    /// Diffs consecutive snapshots to spawn transient effects: reproduction bursts,
    /// death puffs, lineage-handoff focus pulses, and a damage flash. Suppressed when
    /// Reduce Motion is enabled. Expired effects are pruned here.
    private func detectEvents(old: SimulationSnapshot?, new: SimulationSnapshot) {
        let now = Date()
        effects.removeAll { $0.isExpired(at: now) }
        guard !reduceMotion, let old else { return }

        let oldAlive = Dictionary(uniqueKeysWithValues: old.organisms.filter(\.isAlive).map { ($0.id, $0) })
        let newAlive = Dictionary(uniqueKeysWithValues: new.organisms.filter(\.isAlive).map { ($0.id, $0) })

        for (id, organism) in newAlive where oldAlive[id] == nil {
            effects.append(VisualEffect(kind: .birth, position: organism.position, start: now, duration: 0.6))
        }
        for (id, organism) in oldAlive where newAlive[id] == nil {
            effects.append(VisualEffect(kind: .death, position: organism.position, start: now, duration: 0.6))
        }

        if let playerID = old.playerOrganismID,
           let before = oldAlive[playerID],
           let after = newAlive[playerID],
           after.health < before.health - 0.01 {
            effects.append(VisualEffect(kind: .damageFlash, position: .zero, start: now, duration: 0.4))
        }

        if let oldPlayer = old.playerOrganismID,
           let newPlayer = new.playerOrganismID,
           oldPlayer != newPlayer,
           let focus = newAlive[newPlayer] {
            effects.append(VisualEffect(kind: .focusPulse, position: focus.position, start: now, duration: 0.9))
        }
    }

    /// Fraction (0...1) between the previous and current snapshot, based on elapsed
    /// wall-clock time and the current tick interval. Returns 1 (no interpolation)
    /// when Reduce Motion is on or there is no prior snapshot to blend from.
    private func interpolationFactor(now: Date) -> Double {
        guard !reduceMotion, previousSnapshot != nil else { return 1 }
        let interval = SimulationTuning.tickDuration / max(0.25, snapshot.speedMultiplier)
        guard interval > 0 else { return 1 }
        return min(1, max(0, now.timeIntervalSince(snapshotTime) / interval))
    }
}

struct TerrainLegendView: View {
    let terrains: [TerrainType]
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Terrain")
                    .font(.caption.bold())
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                }
                .buttonStyle(.plain)
            }
            ForEach(terrains, id: \.self) { terrain in
                HStack(spacing: 6) {
                    Image(systemName: VisualTokens.Terrain.glyph(for: terrain))
                        .font(.system(size: 9))
                        .foregroundStyle(.white)
                        .frame(width: 14, height: 14)
                        .background(
                            Circle().fill(VisualTokens.Terrain.color(for: terrain))
                        )
                    Text(terrain.displayName)
                        .font(.caption2)
                }
            }
        }
        .padding(8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
        .accessibilityIdentifier("terrainLegend")
    }
}

struct BiomeFitLegendView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Biome Fit")
                .font(.caption.bold())
            HStack(spacing: 8) {
                Label("Good", systemImage: "square.fill")
                    .font(.caption2)
                    .foregroundStyle(.green)
                Label("Poor", systemImage: "square.fill")
                    .font(.caption2)
                    .foregroundStyle(.red)
            }
        }
        .padding(8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
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
