import SwiftUI
import EvolutionSimCore

@main
struct EvolutionSimGameApp: App {
    @StateObject private var viewModel = GameViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
        #if os(macOS)
        .commands {
            GameCommands(viewModel: viewModel)
        }
        #endif
    }
}
