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
