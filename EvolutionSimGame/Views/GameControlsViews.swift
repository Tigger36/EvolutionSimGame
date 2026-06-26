import SwiftUI
import EvolutionSimCore

struct HUDView: View {
    let snapshot: SimulationSnapshot

    var body: some View {
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
        guard let id = snapshot.playerOrganismID else { return nil }
        return snapshot.organisms.first { $0.id == id }
    }

    private var reproductionBadge: some View {
        Group {
            if let player, player.canReproduce {
                Label("Ready to Reproduce", systemImage: "heart.fill")
                    .font(.caption.bold())
                    .foregroundStyle(.pink)
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
                    Image(systemName: "stop.fill")
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Stop")
                moveButton(label: "Right", icon: "arrow.right", direction: Vector2(x: 1, y: 0))
            }
            moveButton(label: "Down", icon: "arrow.down", direction: Vector2(x: 0, y: 1))
        }
    }

    #if os(iOS)
    private var touchPad: some View {
        JoystickView(direction: $direction)
            .frame(width: 120, height: 120)
    }
    #endif

    private func moveButton(label: String, icon: String, direction moveDir: Vector2) -> some View {
        Button {
            direction = moveDir
        } label: {
            Image(systemName: icon)
                .frame(width: 44, height: 44)
        }
        .accessibilityLabel(label)
    }
}

#if os(iOS)
struct JoystickView: View {
    @Binding var direction: Vector2
    @State private var dragOffset: CGSize = .zero

    var body: some View {
        GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let maxRadius = min(geo.size.width, geo.size.height) / 2 - 20

            ZStack {
                Circle()
                    .stroke(.secondary.opacity(0.4), lineWidth: 2)
                Circle()
                    .fill(.secondary.opacity(0.6))
                    .frame(width: 40, height: 40)
                    .position(
                        x: center.x + dragOffset.width,
                        y: center.y + dragOffset.height
                    )
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let dx = value.location.x - center.x
                        let dy = value.location.y - center.y
                        let dist = sqrt(dx * dx + dy * dy)
                        let clampedDist = min(dist, maxRadius)
                        let angle = atan2(dy, dx)
                        dragOffset = CGSize(
                            width: cos(angle) * clampedDist,
                            height: sin(angle) * clampedDist
                        )
                        if clampedDist > 5 {
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
        .accessibilityLabel("Movement joystick")
    }
}
#endif

struct MutationChoiceView: View {
    let offers: [MutationOption]
    let onSelect: (MutationOption) -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.6).ignoresSafeArea()
            VStack(spacing: 16) {
                Text("Choose an Adaptation")
                    .font(.title2.bold())
                Text("Your offspring awaits a guided mutation.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                ForEach(offers, id: \.self) { option in
                    Button {
                        onSelect(option)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(option.displayName).font(.headline)
                            Text(option.description).font(.caption).foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 10))
                    }
                    .accessibilityIdentifier("mutationOption_\(option.rawValue)")
                }
            }
            .padding(24)
            .frame(maxWidth: 400)
        }
    }
}
