import SwiftUI
import EvolutionSimCore

struct HUDView: View {
    let snapshot: SimulationSnapshot

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 16) {
                statBar(label: "Energy", value: playerEnergy, max: 150, color: .green)
                statBar(label: "Health", value: playerHealth, max: 100, color: .red)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Tick \(snapshot.tick)")
                        .font(.caption.monospaced())
                    Text(snapshot.era.displayName)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                reproductionBadge
            }

            if let terrain = snapshot.playerCurrentTerrain {
                HStack(spacing: 6) {
                    Image(systemName: "map.fill")
                        .font(.caption2)
                    Text(terrain.displayName)
                        .font(.caption.bold())
                    Text("—")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(TerrainSystem.playerFacingSummary(for: terrain))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityIdentifier("currentBiomeChip")
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Energy \(Int(playerEnergy)), Health \(Int(playerHealth))")
    }

    private var playerEnergy: Double {
        player?.energy ?? 0
    }

    private var playerHealth: Double {
        player?.health ?? 0
    }

    private var player: Organism? {
        snapshot.playerOrganism
    }

    private var reproductionBadge: some View {
        Group {
            if snapshot.playerCanReproduceSafely {
                Label("Ready to Reproduce", systemImage: "heart.fill")
                    .font(.caption.bold())
                    .foregroundStyle(.pink)
            } else if player?.canReproduce == true {
                Label("Move Away to Reproduce", systemImage: "heart.slash")
                    .font(.caption.bold())
                    .foregroundStyle(.orange)
            } else {
                Label("Gather Energy", systemImage: "bolt.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityIdentifier("reproductionStatus")
    }

    private func statBar(label: String, value: Double, max: Double, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.caption2)
            ProgressView(value: min(value, max), total: max)
                .tint(color)
                .frame(width: 100)
        }
    }
}

struct ControlBarView: View {
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        HStack(spacing: 12) {
            Button {
                viewModel.togglePause()
            } label: {
                Label(viewModel.snapshot.isPaused ? "Resume" : "Pause", systemImage: viewModel.snapshot.isPaused ? "play.fill" : "pause.fill")
            }
            .accessibilityIdentifier("pauseButton")

            Button("Step") { viewModel.stepOnce() }
                .accessibilityIdentifier("stepButton")

            Menu("Speed") {
                Button("0.5x") { viewModel.setSpeed(0.5) }
                Button("1x") { viewModel.setSpeed(1) }
                Button("2x") { viewModel.setSpeed(2) }
                Button("4x") { viewModel.setSpeed(4) }
            }

            Button("Reset") { viewModel.reset() }
                .accessibilityIdentifier("resetButton")

            Spacer()

            Toggle("Biome Fit", isOn: $viewModel.showBiomeFitOverlay)
                .font(.caption)
                .toggleStyle(.button)
                .accessibilityIdentifier("biomeFitToggle")

            Text("Gen \(viewModel.snapshot.lineage.generation)")
                .font(.caption.monospaced())
            Text("Pop \(viewModel.snapshot.lineage.livingCount)")
                .font(.caption.monospaced())
        }
        .buttonStyle(.bordered)
        .font(.caption)
    }
}

struct MovementControlsView: View {
    @Binding var direction: Vector2

    var body: some View {
        HStack(spacing: 24) {
            directionalPad
            #if os(iOS)
            touchPad
            #endif
        }
        .accessibilityIdentifier("movementControls")
    }

    private var directionalPad: some View {
        VStack(spacing: 4) {
            moveButton(label: "Up", icon: "arrow.up", direction: Vector2(x: 0, y: -1))
            HStack(spacing: 4) {
                moveButton(label: "Left", icon: "arrow.left", direction: Vector2(x: -1, y: 0))
                Button {
                    direction = .zero
                } label: {
                    Image(systemName: "circle.fill")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .accessibilityLabel("Stop")
                moveButton(label: "Right", icon: "arrow.right", direction: Vector2(x: 1, y: 0))
            }
            moveButton(label: "Down", icon: "arrow.down", direction: Vector2(x: 0, y: 1))
        }
    }

    private func moveButton(label: String, icon: String, direction move: Vector2) -> some View {
        Button {
            direction = move
        } label: {
            Image(systemName: icon)
                .frame(width: 44, height: 44)
        }
        .accessibilityLabel(label)
    }

    #if os(iOS)
    private var touchPad: some View {
        TouchJoystick(direction: $direction)
            .frame(width: 120, height: 120)
    }
    #endif
}

#if os(iOS)
struct TouchJoystick: View {
    @Binding var direction: Vector2
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                Circle()
                    .fill(.secondary.opacity(0.5))
                    .frame(width: 40, height: 40)
                    .position(
                        x: center.x + dragOffset.width,
                        y: center.y + dragOffset.height
                    )
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let maxDist = geo.size.width / 2 - 20
                        let dx = value.location.x - center.x
                        let dy = value.location.y - center.y
                        let dist = sqrt(dx * dx + dy * dy)
                        let clampedDist = min(dist, maxDist)
                        let angle = atan2(dy, dx)
                        dragOffset = CGSize(
                            width: cos(angle) * clampedDist,
                            height: sin(angle) * clampedDist
                        )
                        if dist > 5 {
                            direction = Vector2(
                                x: cos(angle),
                                y: sin(angle)
                            )
                        } else {
                            direction = .zero
                        }
                    }
                    .onEnded { _ in
                        dragOffset = .zero
                        direction = .zero
                    }
            )
        }
    }
}
#endif

struct MutationChoiceView: View {
    let offers: [MutationOption]
    let pressure: PressureState
    let offspringTraits: TraitSet?
    let onSelect: (MutationOption) -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            ScrollView {
                VStack(spacing: 16) {
                    Text("Choose an Adaptation")
                        .font(.title2.bold())
                    Text("Adaptations shaped by recent survival")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if let label = pressure.dominantPressureLabel {
                        Text("Suggested because: \(label)")
                            .font(.caption.bold())
                            .foregroundStyle(.blue)
                    }

                    Text("Your offspring awaits a guided mutation.")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    ForEach(offers, id: \.self) { option in
                        mutationOptionButton(option)
                    }

                    Text("This affects your offspring. You keep playing as the parent until death.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(24)
                .frame(maxWidth: 440)
            }
        }
    }

    @ViewBuilder
    private func mutationOptionButton(_ option: MutationOption) -> some View {
        let baseTraits = offspringTraits ?? TraitSet.default
        let statChanges = MutationPreview.formattedTraitDeltas(option: option, base: baseTraits)
        let biomeImpact = MutationPreview.formattedBiomeImpact(option: option, base: baseTraits)

        Button {
            onSelect(option)
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                Text(option.displayName).font(.headline)
                Text(option.description).font(.caption).foregroundStyle(.secondary)
                if !statChanges.isEmpty {
                    Label(statChanges, systemImage: "chart.bar.fill")
                        .font(.caption2)
                        .foregroundStyle(.primary)
                }
                Label(biomeImpact, systemImage: "map")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
        }
        .accessibilityIdentifier("mutationOption_\(option.rawValue)")
    }
}
