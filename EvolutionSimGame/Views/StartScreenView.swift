import SwiftUI
import EvolutionSimCore

struct StartScreenView: View {
    let preferSkipTutorial: Bool
    let onStartTutorial: () -> Void
    let onSkipTutorial: () -> Void
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
                if preferSkipTutorial {
                    Button("New Game", action: onSkipTutorial)
                        .buttonStyle(.borderedProminent)
                        .accessibilityIdentifier("newGameButton")
                    Button("Restart Tutorial", action: onStartTutorial)
                        .buttonStyle(.bordered)
                        .accessibilityIdentifier("startTutorialButton")
                } else {
                    Button("Start Tutorial", action: onStartTutorial)
                        .buttonStyle(.borderedProminent)
                        .accessibilityIdentifier("startTutorialButton")
                    Button("Skip Tutorial", action: onSkipTutorial)
                        .buttonStyle(.bordered)
                        .accessibilityIdentifier("skipTutorialButton")
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
        onStartTutorial: {},
        onSkipTutorial: {},
        onShowHowToPlay: {}
    )
}
