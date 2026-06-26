import SwiftUI
import EvolutionSimCore

struct InspectorPanelView: View {
    let snapshot: SimulationSnapshot
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        List {
            Section("Organism") {
                if let player = playerOrganism {
                    LabeledContent("Generation", value: "\(player.generation)")
                    LabeledContent("Age", value: "\(player.age)")
                    LabeledContent("Energy", value: String(format: "%.0f", player.energy))
                    LabeledContent("Health", value: String(format: "%.0f", player.health))
                    LabeledContent("Offspring", value: "\(player.offspringCount)")
                } else {
                    Text("No active organism")
                        .foregroundStyle(.secondary)
                }
            }

            Section("Traits") {
                if let player = playerOrganism {
                    TraitRow(name: "Speed", value: player.traits.speed, description: "Movement speed; tradeoff with size and armor.")
                    TraitRow(name: "Size", value: player.traits.size, description: "Larger body: more presence, slower movement.")
                    TraitRow(name: "Armor", value: player.traits.armor, description: "Reduces predator damage; slows you down.")
                    TraitRow(name: "Toxin Resistance", value: player.traits.toxinResistance, description: "Survive toxic pools better.")
                    TraitRow(name: "Swim Efficiency", value: player.traits.swimEfficiency, description: "Better in water; may hinder land travel.")
                    TraitRow(name: "Reproduction Rate", value: player.traits.reproductionRate, description: "Lower energy threshold for reproduction.")
                    TraitRow(name: "Sense Radius", value: player.traits.senseRadius, description: "Detect predators and food from farther away.")
                    TraitRow(name: "Metabolism", value: player.traits.metabolism, description: "Higher metabolism: faster but hungrier.")
                    if player.traits.nightVision > 0 {
                        TraitRow(name: "Night Vision", value: player.traits.nightVision, description: "See in low light.")
                    }
                    if player.traits.socialBehavior > 0 {
                        TraitRow(name: "Social Behavior", value: player.traits.socialBehavior, description: "Group predator avoidance.")
                    }
                }
            }

            Section("Biome Compatibility") {
                if let player = playerOrganism {
                    ForEach(viewModel.biomeCompatibility(for: player).filter { $0.1 > 0.01 }, id: \.0) { terrain, score in
                        HStack {
                            Text(terrain.displayName)
                            Spacer()
                            CompatibilityBar(score: score)
                        }
                    }
                }
            }

            Section("Lineage") {
                LabeledContent("Living", value: "\(snapshot.lineage.livingCount)")
                LabeledContent("Total Born", value: "\(snapshot.lineage.totalBorn)")
                LabeledContent("Fitness Score", value: String(format: "%.0f", snapshot.fitness.compositeScore))
                LabeledContent("Biomes Explored", value: "\(snapshot.fitness.biomesExplored.count)")
                LabeledContent("Era", value: snapshot.era.displayName)
                Text(EraContent.eraDescription(snapshot.era))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                LabeledContent("Victory Goal", value: snapshot.victoryGoal.displayName)
            }

            if viewModel.showDebugOverlays {
                Section("Debug Overlays") {
                    Picker("Overlay", selection: $viewModel.selectedDebugOverlay) {
                        ForEach(DebugOverlay.allCases) { overlay in
                            Text(overlay.displayName).tag(overlay)
                        }
                    }
                }
            }

            if snapshot.massExtinctionActive {
                Section("Mass Extinction Event") {
                    Label("Active — survive to win!", systemImage: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                }
            }

            Section("Game Settings") {
                Button("Reset (Seed 42)") { viewModel.reset(seed: 42) }
                    .accessibilityIdentifier("resetSeed42")
                Button("Reset (Random Seed)") { viewModel.reset(seed: UInt64.random(in: 1...UInt64.max)) }
                Text(victoryGoalDescription(snapshot.victoryGoal))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Evolutionary Pressure") {
                PressureRow(label: "Water", value: snapshot.pressure.water)
                PressureRow(label: "Predator", value: snapshot.pressure.predator)
                PressureRow(label: "Food Scarcity", value: snapshot.pressure.foodScarcity)
                PressureRow(label: "Exploration", value: snapshot.pressure.exploration)
                PressureRow(label: "Toxic", value: snapshot.pressure.toxic)
            }
        }
        .accessibilityIdentifier("inspectorPanel")
    }

    private var playerOrganism: Organism? {
        guard let id = snapshot.playerOrganismID else { return nil }
        return snapshot.organisms.first { $0.id == id }
    }
}

private func victoryGoalDescription(_ goal: VictoryGoal) -> String {
    switch goal {
    case .surviveMassExtinction:
        return "Survive the mass extinction event that begins around tick 2000."
    case .spreadToAllBiomes:
        return "Explore and adapt to at least 6 different biome types."
    case .reachPopulation:
        return "Grow your lineage to 15 living organisms."
    case .evolveIntelligence:
        return "Reach generation 10 with a fitness score of 500+."
    }
}

struct TraitRow: View {
    let name: String
    let value: Double
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(name)
                Spacer()
                Text(String(format: "%.0f%%", value * 100))
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
            }
            ProgressView(value: value)
            Text(description)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(name), \(Int(value * 100)) percent. \(description)")
    }
}

struct CompatibilityBar: View {
    let score: Double

    var body: some View {
        HStack(spacing: 4) {
            ProgressView(value: score)
                .frame(width: 60)
            Text(String(format: "%.0f%%", score * 100))
                .font(.caption2.monospaced())
                .foregroundStyle(score > 0.6 ? .green : (score > 0.3 ? .orange : .red))
        }
    }
}

struct PressureRow: View {
    let label: String
    let value: Double

    var body: some View {
        HStack {
            Text(label)
            Spacer()
            ProgressView(value: min(value, 1.0))
                .frame(width: 80)
        }
    }
}
