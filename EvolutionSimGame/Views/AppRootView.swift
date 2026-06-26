import SwiftUI
import EvolutionSimCore

struct AppRootView: View {
    @EnvironmentObject private var viewModel: GameViewModel

    var body: some View {
        Group {
            switch viewModel.appPhase {
            case .startScreen:
                StartScreenView(
                    preferSkipTutorial: viewModel.preferSkipTutorial,
                    onStartTutorial: viewModel.beginTutorial,
                    onSkipTutorial: viewModel.skipTutorial,
                    onShowHowToPlay: { viewModel.showHowToPlay = true }
                )
            case .newGameSetup(let skippedTutorial):
                NewGameSetupView(
                    skippedTutorial: skippedTutorial,
                    onStart: viewModel.startGame,
                    onBack: { viewModel.appPhase = .startScreen }
                )
            case .tutorial, .playing:
                ContentView()
            }
        }
        .sheet(isPresented: $viewModel.showHowToPlay) {
            HowToPlayView()
        }
    }
}

#Preview {
    AppRootView()
        .environmentObject(GameViewModel())
}
