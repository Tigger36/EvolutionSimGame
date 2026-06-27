import SwiftUI
import EvolutionSimCore

struct ContentView: View {
    @EnvironmentObject private var viewModel: GameViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        Group {
            if horizontalSizeClass == .compact {
                iPhoneLayout
            } else {
                iPadMacLayout
            }
        }
        .overlay { gameOverlays }
        .overlay(alignment: .top) { topBanners }
        .overlay {
            if viewModel.appPhase == .tutorial, let step = viewModel.tutorialStep {
                TutorialCalloutView(
                    step: step,
                    onContinue: viewModel.advanceTutorialManually,
                    onSkip: viewModel.skipTutorial
                )
            }
        }
    }

    private var iPadMacLayout: some View {
        NavigationSplitView {
            InspectorPanelView(snapshot: viewModel.snapshot, viewModel: viewModel)
                .navigationSplitViewColumnWidth(min: 280, ideal: 320, max: 400)
        } detail: {
            simulationDetail
        }
    }

    private var iPhoneLayout: some View {
        VStack(spacing: 0) {
            simulationDetail
            compactInspector
        }
    }

    private var simulationDetail: some View {
        VStack(spacing: 8) {
            HUDView(snapshot: viewModel.snapshot)
            ZStack {
                SimulationCanvasView(
                    snapshot: viewModel.snapshot,
                    debugOverlay: viewModel.showDebugOverlays ? viewModel.selectedDebugOverlay : .none,
                    showBiomeFitOverlay: viewModel.showBiomeFitOverlay,
                    showTerrainLegend: viewModel.showTerrainLegend,
                    onDismissLegend: viewModel.dismissTerrainLegend
                )
                if viewModel.showDebugOverlays {
                    DebugOverlayLegend(overlay: viewModel.selectedDebugOverlay)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(.secondary.opacity(0.3)))

            ControlBarView(viewModel: viewModel)
            MovementControlsView(direction: $viewModel.movementDirection)
        }
        .padding()
        .navigationTitle("EvolutionSim")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar { toolbarContent }
        #if os(macOS)
        .focusable()
        .onKeyPress(.leftArrow) { viewModel.movementDirection = Vector2(x: -1, y: 0); return .handled }
        .onKeyPress(.rightArrow) { viewModel.movementDirection = Vector2(x: 1, y: 0); return .handled }
        .onKeyPress(.upArrow) { viewModel.movementDirection = Vector2(x: 0, y: -1); return .handled }
        .onKeyPress(.downArrow) { viewModel.movementDirection = Vector2(x: 0, y: 1); return .handled }
        #endif
    }

    private var compactInspector: some View {
        ScrollView {
            InspectorPanelView(snapshot: viewModel.snapshot, viewModel: viewModel)
        }
        .frame(maxHeight: 200)
        .background(.ultraThinMaterial)
    }

    @ViewBuilder
    private var topBanners: some View {
        VStack(spacing: 8) {
            if let banner = viewModel.terrainEntryBanner {
                TerrainEntryBanner(message: banner)
            }
            if let tip = viewModel.contextualTip {
                ContextualTipBanner(tip: tip, onDismiss: viewModel.dismissContextualTip)
            }
            if let feedback = viewModel.mutationFeedback {
                FeedbackBanner(message: feedback)
            }
        }
        .padding(.top, 8)
    }

    @ViewBuilder
    private var gameOverlays: some View {
        if viewModel.shouldPresentMutationChoice {
            MutationChoiceView(
                offers: viewModel.snapshot.pendingMutationOffers,
                pressure: viewModel.snapshot.pressure,
                offspringTraits: viewModel.snapshot.pendingMutationTargetTraits,
                onSelect: viewModel.selectMutation
            )
        }
        if viewModel.snapshot.phase == .extinct {
            gameOverOverlay(
                title: "Extinction",
                message: GameCopy.extinctionMessage(
                    totalBorn: viewModel.snapshot.lineage.totalBorn,
                    generation: viewModel.snapshot.lineage.generation
                )
            )
        }
        if viewModel.snapshot.phase == .victory {
            gameOverOverlay(
                title: "Victory!",
                message: "Goal achieved: \(viewModel.snapshot.victoryGoal.displayName)"
            )
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        #if os(macOS)
        ToolbarItemGroup {
            Button("Pause") { viewModel.togglePause() }
                .keyboardShortcut(" ", modifiers: [])
            Button("Step") { viewModel.stepOnce() }
                .keyboardShortcut("s", modifiers: [.command])
            Button("Reset") { viewModel.reset() }
                .keyboardShortcut("r", modifiers: [.command])
        }
        #endif
        ToolbarItem(placement: .automatic) {
            Button("How to Play") { viewModel.showHowToPlay = true }
        }
        ToolbarItem(placement: .automatic) {
            Toggle("Debug", isOn: $viewModel.showDebugOverlays)
                .accessibilityIdentifier("debugToggle")
        }
    }

    private func gameOverOverlay(title: String, message: String) -> some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()
            VStack(spacing: 16) {
                Text(title).font(.largeTitle.bold())
                Text(message).multilineTextAlignment(.center)
                Text("Fitness: \(Int(viewModel.snapshot.fitness.compositeScore))")
                Button("Play Again") { viewModel.resetToStartScreen() }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("playAgainButton")
            }
            .padding(32)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }
}

#if os(macOS)
struct GameCommands: Commands {
    @ObservedObject var viewModel: GameViewModel

    var body: some Commands {
        CommandMenu("Simulation") {
            Button("Pause / Resume") { viewModel.togglePause() }
                .keyboardShortcut(" ", modifiers: [])
            Button("Step Tick") { viewModel.stepOnce() }
                .keyboardShortcut("s", modifiers: [.command])
            Button("Reset") { viewModel.reset() }
                .keyboardShortcut("r", modifiers: [.command])
            Divider()
            Button("How to Play") { viewModel.showHowToPlay = true }
            Button("Restart Tutorial") { viewModel.beginTutorial() }
            Button("New Game") { viewModel.resetToStartScreen() }
            Divider()
            Button("Speed 1x") { viewModel.setSpeed(1) }
            Button("Speed 2x") { viewModel.setSpeed(2) }
            Button("Speed 4x") { viewModel.setSpeed(4) }
        }
    }
}
#endif

#Preview {
    ContentView()
        .environmentObject(GameViewModel())
}
