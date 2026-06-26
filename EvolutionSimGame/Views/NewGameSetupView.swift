import SwiftUI
import EvolutionSimCore

struct NewGameSetupView: View {
    let skippedTutorial: Bool
    let onStart: (SimulationConfig) -> Void
    let onBack: () -> Void

    @State private var victoryGoal: VictoryGoal = .spreadToAllBiomes
    @State private var useRandomSeed = false
    @State private var fixedSeed: UInt64 = 42

    var body: some View {
        VStack(spacing: 24) {
            Text("New Game")
                .font(.largeTitle.bold())

            if skippedTutorial {
                Text("Configure your run, then start when ready.")
                    .foregroundStyle(.secondary)
            } else {
                Text("Tutorial complete! Start a full run or adjust settings.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Form {
                Picker("Victory Goal", selection: $victoryGoal) {
                    ForEach(VictoryGoal.allCases, id: \.self) { goal in
                        Text(goal.displayName).tag(goal)
                    }
                }

                Toggle("Random Seed", isOn: $useRandomSeed)

                if !useRandomSeed {
                    Stepper("Seed: \(fixedSeed)", value: $fixedSeed, in: 1...9999)
                }

                Text(GameCopy.victoryGoalDescription(victoryGoal))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: 420)

            HStack(spacing: 16) {
                Button("Back", action: onBack)
                    .buttonStyle(.bordered)
                Button("Start Game") {
                    let seed = useRandomSeed ? UInt64.random(in: 1...UInt64.max) : fixedSeed
                    onStart(SimulationConfig(seed: seed, victoryGoal: victoryGoal))
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("confirmStartGame")
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.08, green: 0.1, blue: 0.08))
    }
}

#Preview {
    NewGameSetupView(skippedTutorial: true, onStart: { _ in }, onBack: {})
}
