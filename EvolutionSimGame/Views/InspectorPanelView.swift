import SwiftUI
import EvolutionSimCore

struct InspectorPanelView: View {
    let snapshot: SimulationSnapshot
    @ObservedObject var viewModel: GameViewModel

    var body: some View {
        List {
            Section("Organism") {
                if let player = playerOrganism {
                    HStack(spacing: 12) {
                        OrganismThumbnail(traits: player.traits, isPlayer: true)
                        Text("Traits shape your organism's appearance.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
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

            Section("Reproduction") {
                if let player = playerOrganism {
                    LabeledContent("Status", value: reproductionStatus(for: player))
                    LabeledContent("Energy Needed", value: String(format: "%.0f", player.traits.reproductionThreshold))
                    LabeledContent("Energy Cost", value: String(format: "%.0f", SimulationTuning.reproductionEnergyCost))
                    LabeledContent("Safe Radius", value: "\(Int(SimulationTuning.safeSiteMinDistanceFromPredator))")
                    Text("Reproduction is automatic once energy is high enough, predators are outside the safe radius, and the terrain is not damaging. Mutations apply to the offspring.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
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
                    TraitRow(name: "Social Behavior", value: player.traits.socialBehavior, description: "Nearby allies reduce predator damage.")
                    TraitRow(name: "Parental Care", value: player.traits.parentalCare, description: "Offspring start with more energy.")
                }
            }

            Section {
                Text("Compatibility combines movement, energy cost, and damage in each terrain.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } header: {
                Text("Biome Compatibility")
            } footer: {
                EmptyView()
            }

            if let player = playerOrganism {
                ForEach(viewModel.biomeCompatibility(for: player).filter { $0.1 > 0.01 }, id: \.0) { terrain, score in
                    BiomeCompatibilityRow(
                        terrain: terrain,
                        score: score,
                        breakdown: viewModel.terrainEffectBreakdown(for: player, terrain: terrain)
                    )
                }
            }

            Section("Lineage") {
                LabeledContent("Living", value: "\(snapshot.lineage.livingCount)")
                LabeledContent("Living Descendants", value: "\(max(0, snapshot.lineage.livingCount - 1))")
                LabeledContent("Total Born", value: "\(snapshot.lineage.totalBorn)")
                LabeledContent("Fitness Score", value: String(format: "%.0f", snapshot.fitness.compositeScore))
                LabeledContent("Biomes Explored", value: "\(snapshot.fitness.biomesExplored.count)")
                LabeledContent("Era", value: snapshot.era.displayName)
                Text(EraContent.eraDescription(snapshot.era))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                PredatorThreatInspectorRow(presentation: PredatorThreatPresentation.make(from: snapshot))
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

            Section("Save & Run") {
                LabeledContent("Seed", value: "\(viewModel.currentRunSeed)")
                LabeledContent("Saved Slot", value: viewModel.hasSavedRun ? "Active" : "Empty")
                Button("Copy Seed") { viewModel.copyCurrentSeed() }
                    .accessibilityIdentifier("copySeedButton")
                ShareLink(item: viewModel.currentSeedShareText) {
                    Label("Share Seed", systemImage: "square.and.arrow.up")
                }
                .accessibilityIdentifier("shareSeedButton")
                Text("Share the seed when reporting balance issues or bugs so the same world layout can be reproduced.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Run Management") {
                Button("Reset Run") { viewModel.requestResetRun() }
                    .accessibilityIdentifier("resetRunButton")
                Button("New Game") { viewModel.requestNewGameFromPlaying() }
                    .accessibilityIdentifier("newGameFromInspector")
                Button("Delete Saved Run", role: .destructive) { viewModel.requestDeleteSavedRun() }
                    .accessibilityIdentifier("deleteSavedRunButton")
                Text(GameCopy.victoryGoalDescription(snapshot.victoryGoal))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section {
                Text("Recent pressure shapes which adaptations appear when you reproduce.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                PressureRow(label: "Water", value: snapshot.pressure.water, isDominant: isDominant("Water exposure"))
                PressureRow(label: "Predator", value: snapshot.pressure.predator, isDominant: isDominant("Predator encounters"))
                PressureRow(label: "Food Scarcity", value: snapshot.pressure.foodScarcity, isDominant: isDominant("Food scarcity"))
                PressureRow(label: "Exploration", value: snapshot.pressure.exploration, isDominant: isDominant("Exploration"))
                PressureRow(label: "Toxic", value: snapshot.pressure.toxic, isDominant: isDominant("Toxic exposure"))
            } header: {
                Text("Evolutionary Pressure")
            }
        }
        .accessibilityIdentifier("inspectorPanel")
    }

    private var playerOrganism: Organism? {
        snapshot.playerOrganism
    }

    private func isDominant(_ label: String) -> Bool {
        snapshot.pressure.dominantPressureLabel == label
    }

    private func reproductionStatus(for player: Organism) -> String {
        if snapshot.playerCanReproduceSafely {
            return "Automatic when play resumes"
        }
        if player.canReproduce {
            return "Unsafe site"
        }
        return "Needs energy"
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

struct BiomeCompatibilityRow: View {
    let terrain: TerrainType
    let score: Double
    let breakdown: (speed: Double, energyDrain: Double, damage: Double)

    @State private var isExpanded = false

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: 4) {
                breakdownRow("Speed", value: breakdown.speed, higherIsBetter: true)
                breakdownRow("Energy use", value: breakdown.energyDrain, higherIsBetter: false)
                if breakdown.damage > 0 {
                    breakdownRow("Damage/tick", value: breakdown.damage, higherIsBetter: false, isRaw: true)
                }
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
        } label: {
            HStack {
                Text(terrain.displayName)
                Spacer()
                CompatibilityBar(score: score)
            }
        }
    }

    private func breakdownRow(_ label: String, value: Double, higherIsBetter: Bool, isRaw: Bool = false) -> some View {
        HStack {
            Text(label)
            Spacer()
            if isRaw {
                Text(String(format: "%.2f", value))
            } else {
                Text(String(format: "%.0f%%", value * 100))
                    .foregroundStyle(colorFor(value: value, higherIsBetter: higherIsBetter))
            }
        }
    }

    private func colorFor(value: Double, higherIsBetter: Bool) -> Color {
        let good = higherIsBetter ? value >= 0.7 : value <= 1.1
        let ok = higherIsBetter ? value >= 0.45 : value <= 1.4
        if good { return .green }
        if ok { return .orange }
        return .red
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
    var isDominant: Bool = false

    var body: some View {
        HStack {
            Text(label)
                .fontWeight(isDominant ? .semibold : .regular)
            Spacer()
            ProgressView(value: min(value, 1.0))
                .frame(width: 80)
                .tint(isDominant ? .blue : nil)
        }
    }
}
