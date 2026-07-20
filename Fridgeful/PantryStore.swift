import SwiftUI
import Combine

// Single source of truth for what the user has, what they've saved, and how recipes
// score against their kitchen. Everything persists locally via UserDefaults.
final class PantryStore: ObservableObject {

    @Published private(set) var selected: Set<String> = []
    @Published private(set) var saved: Set<String> = []
    // When on, universal staples (salt, oil, water…) are assumed on hand so recipes
    // aren't blocked by things nearly every kitchen already has.
    @Published var assumeStaples: Bool {
        didSet { defaults.set(assumeStaples, forKey: Keys.assumeStaples) }
    }

    @Published private(set) var cookedTotal: Int = 0

    private let defaults = UserDefaults.standard
    private enum Keys {
        static let selected = "fr_selected_ingredients"
        static let saved = "fr_saved_recipes"
        static let assumeStaples = "fr_assume_staples"
        static let cookedTotal = "fr_cooked_total"
    }

    init() {
        // Default the staples toggle to ON for first-time users.
        if defaults.object(forKey: Keys.assumeStaples) == nil {
            self.assumeStaples = true
        } else {
            self.assumeStaples = defaults.bool(forKey: Keys.assumeStaples)
        }

        if let arr = defaults.array(forKey: Keys.selected) as? [String] {
            selected = Set(arr)
        }
        if let arr = defaults.array(forKey: Keys.saved) as? [String] {
            saved = Set(arr)
        }
        cookedTotal = defaults.integer(forKey: Keys.cookedTotal)
    }

    // MARK: - Cooking log

    func markCooked(_ recipeID: String) {
        cookedTotal += 1
        defaults.set(cookedTotal, forKey: Keys.cookedTotal)
    }

    // MARK: - Available set

    // Everything treated as on-hand: explicit selections plus assumed staples.
    var availableIDs: Set<String> {
        assumeStaples ? selected.union(FoodLibrary.stapleIDs) : selected
    }

    // Selections that are real, user-chosen ingredients (staples excluded from the count).
    var selectedNonStapleCount: Int {
        selected.subtracting(FoodLibrary.stapleIDs).count
    }

    var selectedCount: Int { selected.count }

    // MARK: - Selection

    func isSelected(_ id: String) -> Bool { selected.contains(id) }

    func toggle(_ id: String) {
        if selected.contains(id) { selected.remove(id) } else { selected.insert(id) }
        persistSelected()
    }

    func clearSelection() {
        selected.removeAll()
        persistSelected()
    }

    private func persistSelected() {
        defaults.set(Array(selected), forKey: Keys.selected)
    }

    // MARK: - Saved recipes

    func isSaved(_ id: String) -> Bool { saved.contains(id) }

    func toggleSaved(_ id: String) {
        if saved.contains(id) { saved.remove(id) } else { saved.insert(id) }
        defaults.set(Array(saved), forKey: Keys.saved)
    }

    var savedRecipes: [Recipe] {
        FoodLibrary.recipes.filter { saved.contains($0.id) }
    }

    // MARK: - Matching engine

    func match(for recipe: Recipe) -> MatchResult {
        let available = availableIDs
        var have = Set<String>()
        var missing: [String] = []
        var missingStaples: [String] = []

        for item in recipe.items {
            let id = item.ingredientID
            if available.contains(id) {
                have.insert(id)
            } else if FoodLibrary.stapleIDs.contains(id) {
                missingStaples.append(id)
            } else {
                missing.append(id)
            }
        }
        return MatchResult(recipe: recipe, haveIDs: have,
                           missingIDs: missing, missingStapleIDs: missingStaples)
    }

    // All recipes scored and ranked best-match first. Ties break toward fewer missing
    // items, then alphabetically for a stable order.
    func rankedMatches() -> [MatchResult] {
        FoodLibrary.recipes
            .map { match(for: $0) }
            .sorted { a, b in
                if a.ratio != b.ratio { return a.ratio > b.ratio }
                if a.missingCount != b.missingCount { return a.missingCount < b.missingCount }
                return a.recipe.name < b.recipe.name
            }
    }
}
