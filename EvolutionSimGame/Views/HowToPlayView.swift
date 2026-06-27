import SwiftUI
import EvolutionSimCore

struct HowToPlayView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("Goal") {
                    Text("Guide a lineage from a single organism through survival, reproduction, and strategic mutations. If your organism dies, control passes to a descendant.")
                }

                Section("Core Loop") {
                    Label("Move with the D-pad, touch pad, or arrow keys.", systemImage: "arrow.up.and.down.and.arrow.left.and.right")
                    Label("Eat green food particles to gain energy.", systemImage: "leaf.fill")
                    Label("Avoid red predators — they damage your health.", systemImage: "exclamationmark.triangle.fill")
                    Label("Reproduction happens automatically when energy is high and the site is safe.", systemImage: "heart.fill")
                    Label("Choose a guided mutation for the offspring, then keep playing as the parent.", systemImage: "sparkles")
                }

                Section("Biomes & Terrain") {
                    Text("Colored regions on the map are different terrains. Each affects movement speed, energy drain, and damage. Check the biome chip in the HUD and Biome Compatibility in the inspector.")
                    Label("Water costs less energy to cross, but swim traits are needed for speed.", systemImage: "drop.fill")
                    Label("Toxic pools deal damage unless you resist toxins.", systemImage: "aqi.high")
                    Label("Mud slows movement and drains energy.", systemImage: "circle.grid.cross.fill")
                    Label("Damaging terrain blocks safe reproduction until you move away or adapt.", systemImage: "exclamationmark.octagon")
                }

                Section("Evolution Choices") {
                    Text("Your recent survival experiences build evolutionary pressure — time in water, predator near-misses, food scarcity, exploration, and toxic exposure.")
                    Text("When you reproduce, three adaptation options appear. Options are weighted by your recent pressure. Each choice shows stat changes and biome helps/hurts.")
                }

                Section("Lineage") {
                    Text("Mutations apply to offspring, not you. Keep playing as the parent until death, then control transfers to a living descendant.")
                    Text("Offspring seek visible food, flee visible predators, and survive longer when born near food, away from hazards, or boosted by Parental Care.")
                }

                Section("Eras & Progression") {
                    Text("Fitness from survival, offspring, food, biomes explored, and predator near-misses drives era progression.")
                    Label("Primordial Pool → Reef / Shallows → Landfall → Biomes → Ecosystem Dominance", systemImage: "arrow.triangle.branch")
                    Text("Higher eras increase predator count, speed, damage, and sense radius. The Biomes era unlocks the full terrain set on the world map.")
                }

                Section("Victory Goals") {
                    ForEach(VictoryGoal.allCases, id: \.self) { goal in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(goal.displayName)
                                .font(.subheadline.bold())
                            Text(GameCopy.victoryGoalDescription(goal))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Mass Extinction") {
                    Text("When enabled at new game setup, a global extinction phase begins around tick 2000. Predators move faster and chase more aggressively; the world tint shifts to signal danger.")
                    Text("Surviving through tick 3000 satisfies the Survive Mass Extinction victory goal.")
                }
            }
            .navigationTitle("How to Play")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .frame(minWidth: 360, minHeight: 480)
    }
}

#Preview {
    HowToPlayView()
}
