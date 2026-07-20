import SwiftUI

// MARK: - Cuisine detail

struct CuisineDetailView: View {
    @EnvironmentObject var pantry: PantryStore
    @Environment(\.presentationMode) private var presentationMode
    let cuisine: Cuisine

    private var matches: [MatchResult] {
        FoodLibrary.recipes(in: cuisine)
            .map { pantry.match(for: $0) }
            .sorted { a, b in
                if a.ratio != b.ratio { return a.ratio > b.ratio }
                return a.recipe.name < b.recipe.name
            }
    }

    var body: some View {
        ZStack(alignment: .top) {
            Kitchen.bg.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                CenteredContent {
                    VStack(alignment: .leading, spacing: 16) {
                        hero
                        LazyVStack(spacing: 14) {
                            ForEach(matches) { m in
                                NavigationLink(destination: RecipeDetailView(recipe: m.recipe)) {
                                    RecipeMatchCard(match: m)
                                }
                                .buttonStyle(PressableStyle())
                            }
                        }
                    }
                    .padding(.horizontal, Metrics.gutter)
                    .padding(.top, 58)
                    .padding(.bottom, 30)
                }
            }
            FloatingBackBar(title: cuisine.rawValue) {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .navigationBarHidden(true)
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            CuisineArtBackground(cuisine: cuisine)
            VStack(alignment: .leading, spacing: 6) {
                Text(cuisine.rawValue)
                    .font(.kitchenSerif(28, .semibold))
                    .foregroundColor(.white)
                Text(cuisine.tagline)
                    .font(.kitchenRounded(14, .medium))
                    .foregroundColor(.white.opacity(0.85))
                Text("\(matches.count) recipes")
                    .font(.kitchenRounded(12, .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10).padding(.vertical, 4)
                    .background(Capsule().fill(Color.white.opacity(0.18)))
                    .padding(.top, 4)
            }
            .padding(18)
        }
        .frame(height: 160)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: cuisine.shade.opacity(0.2), radius: 12, y: 6)
    }
}

// MARK: - Collection detail

struct CollectionDetailView: View {
    @EnvironmentObject var pantry: PantryStore
    @Environment(\.presentationMode) private var presentationMode
    let collection: RecipeCollection

    private var matches: [MatchResult] {
        collection.recipes
            .map { pantry.match(for: $0) }
            .sorted { a, b in
                if a.ratio != b.ratio { return a.ratio > b.ratio }
                return a.recipe.name < b.recipe.name
            }
    }

    var body: some View {
        ZStack(alignment: .top) {
            Kitchen.bg.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                CenteredContent {
                    VStack(alignment: .leading, spacing: 16) {
                        header
                        LazyVStack(spacing: 14) {
                            ForEach(matches) { m in
                                NavigationLink(destination: RecipeDetailView(recipe: m.recipe)) {
                                    RecipeMatchCard(match: m)
                                }
                                .buttonStyle(PressableStyle())
                            }
                        }
                    }
                    .padding(.horizontal, Metrics.gutter)
                    .padding(.top, 58)
                    .padding(.bottom, 30)
                }
            }
            FloatingBackBar(title: collection.title) {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .navigationBarHidden(true)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            if let ui = FoodArtLibrary.collection(collection.id) {
                GeometryReader { geo in
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                }
                .frame(height: 130)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Kitchen.hairline, lineWidth: 1))
                .shadow(color: Color.black.opacity(0.06), radius: 8, y: 4)
            }
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(collection.tint.opacity(0.15))
                    GlyphIcon(glyph: collection.glyph, size: 26, color: collection.tint)
                }
                .frame(width: 52, height: 52)
                VStack(alignment: .leading, spacing: 3) {
                    Text(collection.title)
                        .font(.kitchenSerif(23, .semibold))
                        .foregroundColor(Kitchen.primaryDk)
                    Text("\(collection.subtitle) · \(matches.count) recipes")
                        .font(.kitchenRounded(13))
                        .foregroundColor(Kitchen.textMuted)
                }
                Spacer(minLength: 0)
            }
        }
    }
}

// MARK: - Shared floating back bar

struct FloatingBackBar: View {
    let title: String
    let onBack: () -> Void
    var body: some View {
        HStack {
            Button(action: onBack) {
                HStack(spacing: 4) {
                    GlyphIcon(glyph: .chevronLeft, size: 18, color: Kitchen.primary)
                    Text("Back").font(.kitchenRounded(15, .medium)).foregroundColor(Kitchen.primary)
                }
                .padding(.vertical, 6).padding(.horizontal, 8)
            }
            .buttonStyle(PressableStyle())
            Spacer()
            Text(title)
                .font(.kitchenRounded(16, .semibold))
                .foregroundColor(Kitchen.primaryDk)
                .lineLimit(1)
            Spacer()
            Color.clear.frame(width: 64, height: 1)
        }
        .padding(.horizontal, Metrics.gutter - 4)
        .padding(.top, 6)
        .padding(.bottom, 8)
        .background(Kitchen.bg.opacity(0.97).edgesIgnoringSafeArea(.top))
    }
}
