import SwiftUI
import EvolutionSimCore

struct AppRootView: View {
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var viewModel: GameViewModel

    var body: some View {
        Group {
            switch viewModel.appPhase {
            case .startScreen:
                StartScreenView(
                    preferSkipTutorial: viewModel.preferSkipTutorial,
                    hasSavedRun: viewModel.hasSavedRun,
                    savedRunSummary: viewModel.savedRunSummary,
                    onContinue: viewModel.continueSavedRun,
                    onStartTutorial: viewModel.beginTutorial,
                    onNewGame: viewModel.requestNewGameFromStartScreen,
                    onShowHowToPlay: { viewModel.showHowToPlay = true }
                )
            case .newGameSetup(let skippedTutorial):
                NewGameSetupView(
                    skippedTutorial: skippedTutorial,
                    onStart: viewModel.requestStartGame,
                    onBack: { viewModel.appPhase = .startScreen }
                )
            case .tutorial, .playing:
                ContentView()
            }
        }
        .onAppear {
            viewModel.refreshSavedRunAvailability()
        }
        .onChange(of: scenePhase) { _, newPhase in
            viewModel.handleScenePhaseChange(newPhase)
        }
        .sheet(isPresented: $viewModel.showHowToPlay) {
            HowToPlayView()
        }
        .alert(item: $viewModel.runAlert, content: makeAlert)
    }

    private func makeAlert(for state: RunAlertState) -> Alert {
        switch state {
        case .confirmDiscardSavedRunAndOpenNewGame:
            return Alert(
                title: Text("Discard Saved Run?"),
                message: Text("Starting a new game removes the current saved run, but it does not change tutorial or accessibility preferences."),
                primaryButton: .destructive(Text("New Game")) {
                    viewModel.confirmDiscardSavedRunAndOpenNewGame()
                },
                secondaryButton: .cancel {
                    viewModel.dismissRunAlert()
                }
            )

        case let .confirmOverwriteSavedRunAndStartGame(config):
            return Alert(
                title: Text("Overwrite Saved Run?"),
                message: Text("Starting this run replaces the current saved progress in the single active slot."),
                primaryButton: .destructive(Text("Start Game")) {
                    viewModel.confirmOverwriteSavedRunAndStartGame(config)
                },
                secondaryButton: .cancel {
                    viewModel.dismissRunAlert()
                }
            )

        case .confirmResetRun:
            return Alert(
                title: Text("Reset Current Run?"),
                message: Text("This restarts the current run from the same config and overwrites the saved checkpoint."),
                primaryButton: .destructive(Text("Reset Run")) {
                    viewModel.confirmResetRun()
                },
                secondaryButton: .cancel {
                    viewModel.dismissRunAlert()
                }
            )

        case .confirmDeleteSavedRun:
            return Alert(
                title: Text("Delete Saved Run?"),
                message: Text("This discards the active run and returns to the start screen. Tutorial and app preferences stay untouched."),
                primaryButton: .destructive(Text("Delete Run")) {
                    viewModel.confirmDeleteSavedRun()
                },
                secondaryButton: .cancel {
                    viewModel.dismissRunAlert()
                }
            )

        case .confirmAbandonRunAndOpenNewGame:
            return Alert(
                title: Text("Leave Current Run?"),
                message: Text("Opening new game setup discards the current saved run. Tutorial and app preferences stay untouched."),
                primaryButton: .destructive(Text("Open New Game")) {
                    viewModel.confirmAbandonRunAndOpenNewGame()
                },
                secondaryButton: .cancel {
                    viewModel.dismissRunAlert()
                }
            )

        case let .continueFailed(message):
            return Alert(
                title: Text("Saved Run Unavailable"),
                message: Text("\(message)\n\nThe app returned to a safe start screen. You can begin a new game."),
                dismissButton: .default(Text("OK")) {
                    viewModel.dismissRunAlert()
                }
            )

        case let .saveFailed(message):
            return Alert(
                title: Text("Couldn't Save Run"),
                message: Text("\(message)\n\nYour current session is still open, but relaunch may not restore the latest progress."),
                dismissButton: .default(Text("OK")) {
                    viewModel.dismissRunAlert()
                }
            )
        }
    }
}

#Preview {
    AppRootView()
        .environmentObject(GameViewModel())
}
