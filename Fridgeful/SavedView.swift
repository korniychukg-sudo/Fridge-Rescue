import SwiftUI

struct SavedView: View {
    @EnvironmentObject var pantry: PantryStore

    private var saved: [MatchResult] {
        pantry.savedRecipes
            .map { pantry.match(for: $0) }
            .sorted { a, b in
                if a.ratio != b.ratio { return a.ratio > b.ratio }
                return a.recipe.name < b.recipe.name
            }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            CenteredContent {
                VStack(alignment: .leading, spacing: 16) {
                    ScreenHeader(title: "Saved",
                                 subtitle: saved.isEmpty ? nil : "\(saved.count) recipe\(saved.count == 1 ? "" : "s") in your collection.")

                    if saved.isEmpty {
                        EmptyStateView(glyph: .bookmark,
                                       title: "No saved recipes yet",
                                       message: "Tap the bookmark on any recipe to keep it here for later.")
                            .frame(maxWidth: .infinity)
                            .padding(.top, 30)
                    } else {
                        LazyVStack(spacing: 14) {
                            ForEach(saved) { m in
                                NavigationLink(destination: RecipeDetailView(recipe: m.recipe)) {
                                    RecipeMatchCard(match: m)
                                }
                                .buttonStyle(PressableStyle())
                            }
                        }
                    }
                }
                .padding(.horizontal, Metrics.gutter)
                .padding(.top, 8)
                .padding(.bottom, 28)
            }
        }
        .background(Kitchen.bg.ignoresSafeArea())
        .navigationBarHidden(true)
    }
}
