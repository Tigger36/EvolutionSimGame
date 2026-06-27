import SwiftUI
import EvolutionSimCore

struct StartScreenView: View {
    let preferSkipTutorial: Bool
    let hasSavedRun: Bool
    let savedRunSummary: SavedRunSummary?
    let onContinue: () -> Void
    let onStartTutorial: () -> Void
    let onNewGame: () -> Void
    let onShowHowToPlay: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 8) {
                Text("EvolutionSim")
                    .font(.largeTitle.bold())
                Text("Survive, adapt, and evolve your lineage")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 10) {
                loopRow("Move, eat, and flee predators")
                loopRow("Reproduce automatically at safe, high-energy moments")
                loopRow("Choose offspring mutations shaped by your survival")
                loopRow("Continue as a descendant if you die")
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            .frame(maxWidth: 420)

            Text("Advance through fitness-driven eras, pick victory goals, and guide your lineage — not just one organism.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 420)

            VStack(spacing: 12) {
                if hasSavedRun {
                    Button(action: onContinue) {
                        VStack(spacing: 4) {
                            Text("Continue")
                                .font(.headline)
                            if let savedRunSummary {
                                Text(continueSubtitle(savedRunSummary))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            } else {
                                Text("Resume your active run.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .accessibilityIdentifier("continueSavedRunButton")
                }

                if preferSkipTutorial {
                    if hasSavedRun {
                        Button("New Game", action: onNewGame)
                            .buttonStyle(.bordered)
                            .accessibilityIdentifier("newGameButton")
                    } else {
                        Button("New Game", action: onNewGame)
                            .buttonStyle(.borderedProminent)
                            .accessibilityIdentifier("newGameButton")
                    }
                    Button("Restart Tutorial", action: onStartTutorial)
                        .buttonStyle(.bordered)
                        .accessibilityIdentifier("startTutorialButton")
                } else {
                    if hasSavedRun {
                        Button("Start Tutorial", action: onStartTutorial)
                            .buttonStyle(.bordered)
                            .accessibilityIdentifier("startTutorialButton")
                    } else {
                        Button("Start Tutorial", action: onStartTutorial)
                            .buttonStyle(.borderedProminent)
                            .accessibilityIdentifier("startTutorialButton")
                    }
                    Button("New Game", action: onNewGame)
                        .buttonStyle(.bordered)
                        .accessibilityIdentifier("newGameButton")
                }

                Button("How to Play", action: onShowHowToPlay)
                    .font(.subheadline)
                    .accessibilityIdentifier("howToPlayButton")
            }
            .frame(maxWidth: 280)

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.08, green: 0.1, blue: 0.08))
    }

    private func continueSubtitle(_ summary: SavedRunSummary) -> String {
        "Seed \(summary.seed) • Tick \(summary.tick) • \(summary.phase.displayName) • \(summary.victoryGoal.displayName)"
    }

    private func loopRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "circle.fill")
                .font(.system(size: 6))
                .padding(.top, 6)
            Text(text)
                .font(.subheadline)
        }
    }
}

#Preview {
    StartScreenView(
        preferSkipTutorial: false,
        hasSavedRun: true,
        savedRunSummary: nil,
        onContinue: {},
        onStartTutorial: {},
        onNewGame: {},
        onShowHowToPlay: {}
    )
}
