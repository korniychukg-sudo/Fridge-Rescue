import SwiftUI

// MARK: - Ingredients

enum IngredientGroup: String, CaseIterable, Codable {
    case vegetables = "Vegetables"
    case fruits     = "Fruits"
    case proteins   = "Proteins"
    case dairy      = "Dairy & Eggs"
    case grains     = "Grains & Pasta"
    case staples    = "Pantry Staples"
    case herbs      = "Herbs & Spices"

    var color: Color {
        switch self {
        case .vegetables: return Kitchen.grpVeg
        case .fruits:     return Kitchen.grpFruit
        case .proteins:   return Kitchen.grpProtein
        case .dairy:      return Kitchen.grpDairy
        case .grains:     return Kitchen.grpGrain
        case .staples:    return Kitchen.grpStaple
        case .herbs:      return Kitchen.grpHerb
        }
    }

    var glyph: Glyph {
        switch self {
        case .vegetables: return .carrot
        case .fruits:     return .apple
        case .proteins:   return .drumstick
        case .dairy:      return .cheese
        case .grains:     return .wheat
        case .staples:    return .jar
        case .herbs:      return .herb
        }
    }
}

struct Ingredient: Identifiable, Hashable {
    let id: String
    let name: String
    let group: IngredientGroup
    // Staples are pervasive (salt, oil, water…). They can be assumed on-hand so recipes
    // aren't blocked by things nearly every kitchen already has.
    let isStaple: Bool

    init(_ id: String, _ name: String, _ group: IngredientGroup, staple: Bool = false) {
        self.id = id
        self.name = name
        self.group = group
        self.isStaple = staple
    }
}

// MARK: - Recipes

enum MealKind: String, CaseIterable, Codable {
    case breakfast = "Breakfast"
    case lunch     = "Lunch"
    case dinner    = "Dinner"
    case soup      = "Soup"
    case salad     = "Salad"
    case snack     = "Snack"
    case dessert   = "Dessert"
    case drink     = "Drink"

    var glyph: Glyph {
        switch self {
        case .breakfast: return .sunrise
        case .lunch:     return .sandwich
        case .dinner:    return .pot
        case .soup:      return .bowl
        case .salad:     return .leaf
        case .snack:     return .skillet
        case .dessert:   return .cake
        case .drink:     return .cup
        }
    }
}

// World cuisines used for browsing, filtering, and the Discover showcase.
enum Cuisine: String, CaseIterable, Codable {
    case italian       = "Italian"
    case french        = "French"
    case mediterranean = "Mediterranean"
    case mexican       = "Mexican"
    case american      = "American"
    case asian         = "Asian"
    case indian        = "Indian"

    var glyph: Glyph {
        switch self {
        case .italian:       return .pizza
        case .french:        return .croissant
        case .mediterranean: return .oliveBranch
        case .mexican:       return .chili
        case .american:      return .burger
        case .asian:         return .wok
        case .indian:        return .mortar
        }
    }

    // Each cuisine gets its own hue pair for hero cards and tags.
    var color: Color {
        switch self {
        case .italian:       return Color(red: 0.345, green: 0.545, blue: 0.341)
        case .french:        return Color(red: 0.435, green: 0.475, blue: 0.694)
        case .mediterranean: return Color(red: 0.216, green: 0.545, blue: 0.545)
        case .mexican:       return Color(red: 0.812, green: 0.373, blue: 0.227)
        case .american:      return Color(red: 0.769, green: 0.529, blue: 0.220)
        case .asian:         return Color(red: 0.639, green: 0.322, blue: 0.416)
        case .indian:        return Color(red: 0.827, green: 0.502, blue: 0.161)
        }
    }

    // Deeper companion shade for gradients.
    var shade: Color {
        switch self {
        case .italian:       return Color(red: 0.216, green: 0.388, blue: 0.235)
        case .french:        return Color(red: 0.290, green: 0.322, blue: 0.518)
        case .mediterranean: return Color(red: 0.125, green: 0.388, blue: 0.404)
        case .mexican:       return Color(red: 0.616, green: 0.243, blue: 0.145)
        case .american:      return Color(red: 0.573, green: 0.365, blue: 0.129)
        case .asian:         return Color(red: 0.459, green: 0.196, blue: 0.290)
        case .indian:        return Color(red: 0.635, green: 0.345, blue: 0.094)
        }
    }

    var tagline: String {
        switch self {
        case .italian:       return "Pasta, tomatoes & basil"
        case .french:        return "Butter, bistro classics"
        case .mediterranean: return "Olive oil, sun & herbs"
        case .mexican:       return "Bold, bright & spicy"
        case .american:      return "Comfort food favorites"
        case .asian:         return "Wok-fast & full of umami"
        case .indian:        return "Warm spice & rich curries"
        }
    }
}

enum Difficulty: String, Codable {
    case easy   = "Easy"
    case medium = "Medium"

    var color: Color {
        switch self {
        case .easy:   return Kitchen.ready
        case .medium: return Kitchen.honey
        }
    }
}

// One line in a recipe: which ingredient plus a human-readable amount.
struct RecipeItem: Hashable {
    let ingredientID: String
    let amount: String
    init(_ ingredientID: String, _ amount: String) {
        self.ingredientID = ingredientID
        self.amount = amount
    }
}

struct Recipe: Identifiable, Hashable {
    let id: String
    let name: String
    let blurb: String
    let kind: MealKind
    let minutes: Int
    let servings: Int
    let difficulty: Difficulty
    let items: [RecipeItem]
    let steps: [String]
    let tip: String?

    var ingredientIDs: [String] { items.map { $0.ingredientID } }

    var cuisine: Cuisine { FoodLibrary.cuisineByRecipe[id] ?? .american }

    // Vegetarian = contains no meat or fish (dairy, eggs, and plant proteins are fine).
    var isVegetarian: Bool {
        !items.contains { FoodLibrary.meatAndFishIDs.contains($0.ingredientID) }
    }

    var isQuick: Bool { minutes <= 20 }
}

// A themed, self-filtering shelf of recipes for the Discover tab.
struct RecipeCollection: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let glyph: Glyph
    let tint: Color
    let matches: (Recipe) -> Bool

    var recipes: [Recipe] { FoodLibrary.recipes.filter(matches) }
}

// MARK: - Match result

// Computed against the user's available ingredients (their selection + assumed staples).
struct MatchResult: Identifiable {
    let recipe: Recipe
    let haveIDs: Set<String>
    let missingIDs: [String]      // non-staple gaps the user still needs
    let missingStapleIDs: [String]

    var id: String { recipe.id }
    var total: Int { recipe.items.count }
    var haveCount: Int { haveIDs.count }
    var missingCount: Int { missingIDs.count }
    var ratio: Double { total == 0 ? 0 : Double(haveCount) / Double(total) }
    var isReady: Bool { missingIDs.isEmpty && missingStapleIDs.isEmpty }
    var percent: Int { Int((ratio * 100).rounded()) }
}
