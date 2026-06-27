import SwiftUI
import EvolutionSimCore

struct NewGameSetupView: View {
    let skippedTutorial: Bool
    let onStart: (SimulationConfig) -> Void
    let onBack: () -> Void

    @State private var victoryGoal: VictoryGoal = .spreadToAllBiomes
    @State private var useRandomSeed = false
    @State private var fixedSeed: UInt64 = 42
    @State private var enableMassExtinctionEvents = true

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
                Section {
                    Picker("Victory Goal", selection: $victoryGoal) {
                        ForEach(VictoryGoal.allCases, id: \.self) { goal in
                            Text(goal.displayName).tag(goal)
                        }
                    }
                    .accessibilityIdentifier("victoryGoalPicker")

                    Text(GameCopy.victoryGoalDescription(victoryGoal))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("World & Difficulty") {
                    Toggle("Random Seed", isOn: $useRandomSeed)
                        .accessibilityIdentifier("randomSeedToggle")

                    if !useRandomSeed {
                        Stepper("Seed: \(fixedSeed)", value: $fixedSeed, in: 1...9999)
                            .accessibilityIdentifier("fixedSeedStepper")
                    }

                    Text(GameCopy.seedExplanation(useRandomSeed: useRandomSeed))
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(GameCopy.eraProgressionExplanation())
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Toggle("Mass Extinction Events", isOn: $enableMassExtinctionEvents)
                        .accessibilityIdentifier("massExtinctionToggle")

                    Text(GameCopy.massExtinctionExplanation(enabled: enableMassExtinctionEvents))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Tutorial vs Standard") {
                    Text(GameCopy.tutorialPresetExplanation())
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: 420)

            HStack(spacing: 16) {
                Button("Back", action: onBack)
                    .buttonStyle(.bordered)
                    .accessibilityIdentifier("newGameBackButton")
                Button("Start Game") {
                    let seed = useRandomSeed ? UInt64.random(in: 1...UInt64.max) : fixedSeed
                    onStart(
                        SimulationConfig(
                            seed: seed,
                            victoryGoal: victoryGoal,
                            enableMassExtinctionEvents: enableMassExtinctionEvents
                        )
                    )
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
