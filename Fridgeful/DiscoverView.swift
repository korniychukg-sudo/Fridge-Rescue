import SwiftUI

// The showcase home tab: featured pick, world cuisines, curated collections, and
// "almost there" suggestions driven by the user's pantry.
struct DiscoverView: View {
    @EnvironmentObject var pantry: PantryStore

    // Deterministic daily pick: rotates once per calendar day, no stored state.
    private var featured: MatchResult {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let recipes = FoodLibrary.recipes
        let recipe = recipes[day % recipes.count]
        return pantry.match(for: recipe)
    }

    // Top near-misses: not ready, but only 1–2 ingredients short.
    private var almostThere: [MatchResult] {
        pantry.rankedMatches()
            .filter { !$0.isReady && $0.missingCount > 0 && $0.missingCount <= 2 }
            .prefix(3).map { $0 }
    }

    private var readyNow: [MatchResult] {
        pantry.rankedMatches().filter { $0.isReady }.prefix(5).map { $0 }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            CenteredContent {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    featuredCard
                    if !readyNow.isEmpty { readySection }
                    cuisinesSection
                    collectionsSection
                    if !almostThere.isEmpty { almostSection }
                }
                .padding(.horizontal, Metrics.gutter)
                .padding(.top, 8)
                .padding(.bottom, 28)
            }
        }
        .background(Kitchen.bg.ignoresSafeArea())
        .navigationBarHidden(true)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Discover")
                .font(.kitchenSerif(30, .semibold))
                .foregroundColor(Kitchen.primaryDk)
            Text("Cuisines, collections, and tonight's inspiration.")
                .font(.kitchenRounded(15))
                .foregroundColor(Kitchen.textMuted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Featured

    private var featuredCard: some View {
        let m = featured
        let cuisine = m.recipe.cuisine
        return NavigationLink(destination: RecipeDetailView(recipe: m.recipe)) {
            VStack(alignment: .leading, spacing: 0) {
                // Hero band: the recipe illustration under a cuisine-tinted gradient
                // so the white text stays legible over the light art.
                ZStack(alignment: .topLeading) {
                    if let ui = FoodArtLibrary.recipe(m.recipe.id) {
                        GeometryReader { geo in
                            Image(uiImage: ui)
                                .resizable()
                                .scaledToFill()
                                .frame(width: geo.size.width, height: geo.size.height)
                                .clipped()
                        }
                    } else {
                        LinearGradient(colors: [cuisine.color, cuisine.shade],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    }
                    LinearGradient(colors: [cuisine.shade.opacity(0.94),
                                            cuisine.shade.opacity(0.62), .clear],
                                   startPoint: .leading, endPoint: .trailing)
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 6) {
                            GlyphIcon(glyph: .star, size: 13, color: .white)
                            Text("TONIGHT'S PICK")
                                .font(.kitchenRounded(11, .bold)).tracking(1.2)
                                .foregroundColor(.white.opacity(0.95))
                        }
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Capsule().fill(Color.white.opacity(0.18)))

                        Text(m.recipe.name)
                            .font(.kitchenSerif(25, .semibold))
                            .foregroundColor(.white)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("\(cuisine.rawValue) · \(m.recipe.minutes) min · \(m.recipe.difficulty.rawValue)")
                            .font(.kitchenRounded(13.5, .medium))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .padding(18)
                }
                .frame(height: 170)
                .clipped()

                // Match strip
                HStack(spacing: 10) {
                    GlyphIcon(glyph: m.isReady ? .check : .cart, size: 15,
                              color: m.isReady ? Kitchen.ready : Kitchen.almost)
                    Text(m.isReady ? "You can cook this right now"
                         : "You have \(m.haveCount) of \(m.total) ingredients")
                        .font(.kitchenRounded(13.5, .medium))
                        .foregroundColor(Kitchen.text)
                    Spacer()
                    Text("\(m.percent)%")
                        .font(.kitchenRounded(14, .bold))
                        .foregroundColor(m.isReady ? Kitchen.ready : Kitchen.almost)
                    GlyphIcon(glyph: .chevronRight, size: 15, color: Kitchen.textMuted)
                }
                .padding(.horizontal, 16).padding(.vertical, 13)
                .background(Kitchen.card)
            }
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Kitchen.hairline, lineWidth: 1))
            .shadow(color: cuisine.shade.opacity(0.18), radius: 12, y: 6)
        }
        .buttonStyle(PressableStyle())
    }

    // MARK: - Ready now

    private var readySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderRow(title: "Ready to Cook", subtitle: "Full match from your kitchen")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(readyNow) { m in
                        NavigationLink(destination: RecipeDetailView(recipe: m.recipe)) {
                            MiniRecipeCard(match: m)
                        }
                        .buttonStyle(PressableStyle())
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    // MARK: - Cuisines

    private var cuisinesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderRow(title: "Cuisines of the World", subtitle: "Seven ways to travel from your stove")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Cuisine.allCases, id: \.self) { c in
                        NavigationLink(destination: CuisineDetailView(cuisine: c)) {
                            CuisineCard(cuisine: c)
                        }
                        .buttonStyle(PressableStyle())
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    // MARK: - Collections

    private var collectionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderRow(title: "Collections", subtitle: "Curated shelves for every mood")
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                      spacing: 12) {
                ForEach(FoodLibrary.collections) { col in
                    NavigationLink(destination: CollectionDetailView(collection: col)) {
                        CollectionCard(collection: col)
                    }
                    .buttonStyle(PressableStyle())
                }
            }
        }
    }

    // MARK: - Almost there

    private var almostSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderRow(title: "So Close", subtitle: "Just an ingredient or two away")
            VStack(spacing: 10) {
                ForEach(almostThere) { m in
                    NavigationLink(destination: RecipeDetailView(recipe: m.recipe)) {
                        AlmostRow(match: m)
                    }
                    .buttonStyle(PressableStyle())
                }
            }
        }
    }
}

// MARK: - Discover building blocks

struct SectionHeaderRow: View {
    let title: String
    var subtitle: String? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.kitchenSerif(20, .semibold))
                .foregroundColor(Kitchen.primaryDk)
            if let s = subtitle {
                Text(s)
                    .font(.kitchenRounded(13))
                    .foregroundColor(Kitchen.textMuted)
            }
        }
    }
}

struct CuisineCard: View {
    let cuisine: Cuisine
    private var count: Int { FoodLibrary.recipes(in: cuisine).count }
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottomTrailing) {
                CuisineArtBackground(cuisine: cuisine)
                VStack(alignment: .leading, spacing: 3) {
                    GlyphIcon(glyph: cuisine.glyph, size: 24, color: .white)
                    Spacer(minLength: 0)
                    Text(cuisine.rawValue)
                        .font(.kitchenRounded(16, .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                    Text("\(count) recipes")
                        .font(.kitchenRounded(12, .medium))
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(14)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            .frame(width: 148, height: 128)
        }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: cuisine.shade.opacity(0.22), radius: 8, y: 4)
    }
}

struct CollectionCard: View {
    let collection: RecipeCollection
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .fill(collection.tint.opacity(0.15))
                    GlyphIcon(glyph: collection.glyph, size: 20, color: collection.tint)
                }
                .frame(width: 38, height: 38)
                Spacer()
                Text("\(collection.recipes.count)")
                    .font(.kitchenRounded(12.5, .bold))
                    .foregroundColor(collection.tint)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Capsule().fill(collection.tint.opacity(0.13)))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(collection.title)
                    .font(.kitchenRounded(15, .semibold))
                    .foregroundColor(Kitchen.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                Text(collection.subtitle)
                    .font(.kitchenRounded(11.5))
                    .foregroundColor(Kitchen.textMuted)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Kitchen.card))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Kitchen.hairline, lineWidth: 1))
        .shadow(color: Color.black.opacity(0.04), radius: 6, y: 3)
    }
}

struct MiniRecipeCard: View {
    let match: MatchResult
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topTrailing) {
                RecipeArtView(recipe: match.recipe, corner: 12)
                    .frame(height: 92)
                HStack(spacing: 4) {
                    GlyphIcon(glyph: .check, size: 12, color: Kitchen.ready)
                    Text("100%")
                        .font(.kitchenRounded(11.5, .bold))
                        .foregroundColor(Kitchen.ready)
                }
                .padding(.horizontal, 8).padding(.vertical, 4)
                .background(Capsule().fill(Color.white.opacity(0.92)))
                .padding(6)
            }
            Text(match.recipe.name)
                .font(.kitchenRounded(14.5, .semibold))
                .foregroundColor(Kitchen.text)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, minHeight: 36, alignment: .topLeading)
            HStack(spacing: 8) {
                MetaChip(glyph: .clock, text: "\(match.recipe.minutes)m")
                Text(match.recipe.cuisine.rawValue)
                    .font(.kitchenRounded(11.5, .medium))
                    .foregroundColor(match.recipe.cuisine.color)
            }
        }
        .padding(13)
        .frame(width: 168, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 17, style: .continuous).fill(Kitchen.card))
        .overlay(RoundedRectangle(cornerRadius: 17, style: .continuous).stroke(Kitchen.hairline, lineWidth: 1))
        .shadow(color: Color.black.opacity(0.04), radius: 6, y: 3)
    }
}

struct AlmostRow: View {
    let match: MatchResult
    private var missingNames: String {
        match.missingIDs.map { FoodLibrary.name(for: $0) }.joined(separator: ", ")
    }
    var body: some View {
        HStack(spacing: 12) {
            RecipeArtView(recipe: match.recipe, corner: 12)
                .frame(width: 52, height: 52)
            VStack(alignment: .leading, spacing: 3) {
                Text(match.recipe.name)
                    .font(.kitchenRounded(15, .semibold))
                    .foregroundColor(Kitchen.text)
                    .lineLimit(1)
                Text("Just add \(missingNames)")
                    .font(.kitchenRounded(12.5))
                    .foregroundColor(Kitchen.almost)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            Text("\(match.percent)%")
                .font(.kitchenRounded(13.5, .bold))
                .foregroundColor(Kitchen.almost)
            GlyphIcon(glyph: .chevronRight, size: 15, color: Kitchen.textMuted)
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Kitchen.card))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Kitchen.hairline, lineWidth: 1))
        .shadow(color: Color.black.opacity(0.04), radius: 6, y: 3)
    }
}
