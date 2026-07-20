import SwiftUI

enum MatchFilter: String, CaseIterable {
    case ready = "Ready"
    case almost = "Almost"
    case all = "All"
}

struct RecipesView: View {
    @EnvironmentObject var pantry: PantryStore
    @State private var filter: MatchFilter = .all
    @State private var kind: MealKind? = nil
    @State private var cuisine: Cuisine? = nil

    private var matches: [MatchResult] {
        pantry.rankedMatches().filter { m in
            let passKind = kind == nil || m.recipe.kind == kind
            let passCuisine = cuisine == nil || m.recipe.cuisine == cuisine
            let passFilter: Bool
            switch filter {
            case .ready:  passFilter = m.isReady
            case .almost: passFilter = !m.isReady && m.missingCount <= 2
            case .all:    passFilter = true
            }
            return passKind && passCuisine && passFilter
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            CenteredContent {
                VStack(alignment: .leading, spacing: 16) {
                    ScreenHeader(title: "Recipes",
                                 subtitle: "Ranked by how much you can already make.")

                    filterBar
                    cuisineBar
                    kindBar

                    if matches.isEmpty {
                        emptyState.frame(maxWidth: .infinity).padding(.top, 20)
                    } else {
                        LazyVStack(spacing: 14) {
                            ForEach(matches) { m in
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

    private var filterBar: some View {
        HStack(spacing: 8) {
            ForEach(MatchFilter.allCases, id: \.self) { f in
                Button(action: { withAnimation { filter = f } }) {
                    Text(f.rawValue)
                        .font(.kitchenRounded(14, .semibold))
                        .foregroundColor(filter == f ? .white : Kitchen.text)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(filter == f ? Kitchen.primary : Kitchen.card)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(filter == f ? Color.clear : Kitchen.hairline, lineWidth: 1)
                        )
                }
                .buttonStyle(PressableStyle())
            }
        }
    }

    private var cuisineBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                cuisineChip(nil, "All Cuisines", .globe, Kitchen.primaryDk)
                ForEach(Cuisine.allCases, id: \.self) { c in
                    cuisineChip(c, c.rawValue, c.glyph, c.color)
                }
            }
            .padding(.vertical, 2)
        }
    }

    private func cuisineChip(_ c: Cuisine?, _ label: String, _ glyph: Glyph, _ tint: Color) -> some View {
        let active = cuisine == c
        return Button(action: { withAnimation { cuisine = c } }) {
            HStack(spacing: 6) {
                GlyphIcon(glyph: glyph, size: 14, color: active ? .white : tint)
                Text(label)
                    .font(.kitchenRounded(13, .medium))
                    .foregroundColor(active ? .white : Kitchen.text)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Capsule().fill(active ? tint : Kitchen.card))
            .overlay(Capsule().stroke(active ? Color.clear : Kitchen.hairline, lineWidth: 1))
        }
        .buttonStyle(PressableStyle())
    }

    private var kindBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                kindChip(nil, "All Meals", .basket)
                ForEach(MealKind.allCases, id: \.self) { k in
                    kindChip(k, k.rawValue, k.glyph)
                }
            }
            .padding(.vertical, 2)
        }
    }

    private func kindChip(_ k: MealKind?, _ label: String, _ glyph: Glyph) -> some View {
        let active = kind == k
        return Button(action: { withAnimation { kind = k } }) {
            HStack(spacing: 6) {
                GlyphIcon(glyph: glyph, size: 14, color: active ? .white : Kitchen.textMuted)
                Text(label)
                    .font(.kitchenRounded(13, .medium))
                    .foregroundColor(active ? .white : Kitchen.text)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule().fill(active ? Kitchen.accent : Kitchen.card)
            )
            .overlay(
                Capsule().stroke(active ? Color.clear : Kitchen.hairline, lineWidth: 1)
            )
        }
        .buttonStyle(PressableStyle())
    }

    private var emptyState: some View {
        Group {
            if pantry.selectedNonStapleCount == 0 {
                EmptyStateView(glyph: .basket,
                               title: "Start with your kitchen",
                               message: "Add a few ingredients in the Kitchen tab and matching recipes will appear here.")
            } else if filter == .ready {
                EmptyStateView(glyph: .sparkle,
                               title: "Almost there",
                               message: "Nothing is a perfect match yet. Try the \"Almost\" filter to see recipes you're just an ingredient or two away from.")
            } else {
                EmptyStateView(glyph: .search,
                               title: "No recipes here",
                               message: "No recipes fit this filter. Try a different meal type or add more ingredients.")
            }
        }
    }
}

// Shared card used by Recipes and Saved lists.
struct RecipeMatchCard: View {
    @EnvironmentObject var pantry: PantryStore
    let match: MatchResult

    private var tint: Color {
        if match.isReady { return Kitchen.ready }
        if match.missingCount <= 2 { return Kitchen.almost }
        return Kitchen.far
    }

    private var statusText: String {
        if match.isReady { return "Ready to cook" }
        if match.missingCount == 1 { return "Missing 1 ingredient" }
        return "Missing \(match.missingCount) ingredients"
    }

    var body: some View {
        CardContainer(padding: 16) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .top, spacing: 12) {
                    RecipeArtView(recipe: match.recipe)
                        .frame(width: 62, height: 62)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(match.recipe.name)
                            .font(.kitchenRounded(17, .semibold))
                            .foregroundColor(Kitchen.text)
                            .lineLimit(2)
                        HStack(spacing: 12) {
                            MetaChip(glyph: .clock, text: "\(match.recipe.minutes) min")
                            MetaChip(glyph: .flame, text: match.recipe.difficulty.rawValue,
                                     tint: match.recipe.difficulty.color)
                            MetaChip(glyph: match.recipe.cuisine.glyph,
                                     text: match.recipe.cuisine.rawValue,
                                     tint: match.recipe.cuisine.color)
                        }
                    }
                    Spacer(minLength: 0)
                    Button(action: { withAnimation { pantry.toggleSaved(match.recipe.id) } }) {
                        GlyphIcon(glyph: pantry.isSaved(match.recipe.id) ? .bookmarkFill : .bookmark,
                                  size: 20, color: Kitchen.primary)
                            .padding(4)
                    }
                    .buttonStyle(PressableStyle())
                }

                HStack(spacing: 10) {
                    MatchMeter(ratio: match.ratio, color: tint)
                    Text("\(match.percent)%")
                        .font(.kitchenRounded(13, .bold))
                        .foregroundColor(tint)
                        .frame(width: 40, alignment: .trailing)
                }

                HStack(spacing: 6) {
                    GlyphIcon(glyph: match.isReady ? .check : .cart, size: 14, color: tint)
                    Text(statusText)
                        .font(.kitchenRounded(13, .medium))
                        .foregroundColor(tint)
                    if !match.isReady && !match.missingIDs.isEmpty {
                        Text("· " + missingPreview)
                            .font(.kitchenRounded(13))
                            .foregroundColor(Kitchen.textMuted)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 0)
                }
            }
        }
    }

    private var missingPreview: String {
        let names = match.missingIDs.prefix(3).map { FoodLibrary.name(for: $0) }
        var text = names.joined(separator: ", ")
        if match.missingIDs.count > 3 { text += "…" }
        return text
    }
}
