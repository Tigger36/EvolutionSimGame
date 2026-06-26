import SwiftUI

struct PredatorThreatLevelBar: View {
    let level: Int
    let accent: Color

    var body: some View {
        HStack(spacing: 3) {
            ForEach(1...5, id: \.self) { segment in
                RoundedRectangle(cornerRadius: 2)
                    .fill(segment <= level ? accent : Color.secondary.opacity(0.25))
                    .frame(height: 6)
            }
        }
        .accessibilityHidden(true)
    }
}

struct PredatorThreatInspectorRow: View {
    let presentation: PredatorThreatPresentation

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            LabeledContent {
                HStack(spacing: 6) {
                    if presentation.massExtinctionActive {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                            .accessibilityHidden(true)
                    }
                    Text(presentation.tierLabel)
                        .foregroundStyle(tierColor)
                }
            } label: {
                Label("Predator Threat", systemImage: "pawprint.fill")
            }

            PredatorThreatLevelBar(level: presentation.relativeLevel, accent: tierColor)

            Text(presentation.summary)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(presentation.activePredatorCaption)
                .font(.caption2)
                .foregroundStyle(.secondary)

            if presentation.massExtinctionActive {
                Text("Mass extinction event — predators hunt faster than usual.")
                    .font(.caption2)
                    .foregroundStyle(.orange)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("predatorThreatTier")
        .accessibilityLabel(presentation.accessibilityLabel)
    }

    private var tierColor: Color {
        if presentation.massExtinctionActive { return .orange }
        switch presentation.relativeLevel {
        case 1: return .green
        case 2: return .secondary
        case 3: return .yellow
        case 4: return .orange
        default: return .red
        }
    }
}

struct PredatorThreatHUDChip: View {
    let presentation: PredatorThreatPresentation

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: presentation.massExtinctionActive ? "exclamationmark.triangle.fill" : "pawprint.fill")
                .font(.caption2)
                .foregroundStyle(tierColor)
            Text(presentation.tierLabel)
                .font(.caption2.bold())
                .foregroundStyle(tierColor)
                .lineLimit(1)
        }
        .accessibilityIdentifier("predatorThreatHUD")
        .accessibilityLabel("Predator threat: \(presentation.tierLabel)")
    }

    private var tierColor: Color {
        if presentation.massExtinctionActive { return .orange }
        switch presentation.relativeLevel {
        case 1: return .green
        case 2: return .secondary
        case 3: return .yellow
        case 4: return .orange
        default: return .red
        }
    }
}
