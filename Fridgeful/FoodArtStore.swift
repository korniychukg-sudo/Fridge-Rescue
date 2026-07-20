import SwiftUI

// Loader for the bundled illustration library (FoodArt/ folder reference).
// Every accessor is optional — views always fall back to the glyph emblems,
// so a missing file can never break the UI.
enum FoodArtLibrary {
    private static let cache = NSCache<NSString, UIImage>()

    static func image(_ name: String) -> UIImage? {
        if let hit = cache.object(forKey: name as NSString) { return hit }
        guard let url = Bundle.main.url(forResource: name, withExtension: "png",
                                        subdirectory: "FoodArt"),
              let img = UIImage(contentsOfFile: url.path) else { return nil }
        cache.setObject(img, forKey: name as NSString)
        return img
    }

    static func recipe(_ id: String) -> UIImage? { image("recipe_" + id) }
    static func cuisine(_ c: Cuisine) -> UIImage? { image("cuisine_" + c.rawValue.lowercased()) }
    static func collection(_ id: String) -> UIImage? { image("collection_" + id) }
}

// A recipe cover: the illustration when available, the old glyph emblem otherwise.
struct RecipeArtView: View {
    let recipe: Recipe
    var corner: CGFloat = 14

    var body: some View {
        GeometryReader { geo in
            Group {
                if let ui = FoodArtLibrary.recipe(recipe.id) {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFill()
                } else {
                    ZStack {
                        LinearGradient(colors: [recipe.cuisine.color.opacity(0.20),
                                                recipe.cuisine.shade.opacity(0.30)],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                        GlyphIcon(glyph: recipe.kind.glyph,
                                  size: min(geo.size.width, geo.size.height) * 0.45,
                                  color: recipe.cuisine.color)
                    }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
        }
    }
}

// A cuisine banner background with a legibility gradient for overlaid text.
struct CuisineArtBackground: View {
    let cuisine: Cuisine

    var body: some View {
        GeometryReader { geo in
            ZStack {
                if let ui = FoodArtLibrary.cuisine(cuisine) {
                    Image(uiImage: ui)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                } else {
                    LinearGradient(colors: [cuisine.color, cuisine.shade],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                }
                LinearGradient(colors: [cuisine.shade.opacity(0.75), Color.clear],
                               startPoint: .bottomLeading, endPoint: .topTrailing)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}
