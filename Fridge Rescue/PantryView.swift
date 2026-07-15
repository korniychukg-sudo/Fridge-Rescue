import SwiftUI

struct PantryView: View {
    @EnvironmentObject var pantry: PantryStore
    @State private var query = ""

    private var groups: [(group: IngredientGroup, items: [Ingredient])] {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        return FoodLibrary.grouped().compactMap { entry in
            let items = q.isEmpty ? entry.items
                : entry.items.filter { $0.name.lowercased().contains(q) }
            return items.isEmpty ? nil : (entry.group, items)
        }
    }

    private var readyCount: Int {
        pantry.rankedMatches().filter { $0.isReady }.count
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            CenteredContent {
                VStack(alignment: .leading, spacing: 18) {
                    ScreenHeader(title: "My Kitchen",
                                 subtitle: "Tap everything you have on hand. Recipes update as you go.")

                    summaryCard

                    SearchField(text: $query, placeholder: "Search ingredients")

                    if groups.isEmpty {
                        EmptyStateView(glyph: .search,
                                       title: "No matches",
                                       message: "No ingredients match \"\(query)\". Try a different word.")
                            .frame(maxWidth: .infinity)
                            .padding(.top, 24)
                    } else {
                        ForEach(groups, id: \.group) { entry in
                            groupSection(entry.group, entry.items)
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

    private var summaryCard: some View {
        CardContainer {
            VStack(spacing: 14) {
                HStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(pantry.selectedNonStapleCount)")
                            .font(.kitchenSerif(30, .bold))
                            .foregroundColor(Kitchen.primaryDk)
                        Text("ingredients selected")
                            .font(.kitchenRounded(13))
                            .foregroundColor(Kitchen.textMuted)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        HStack(spacing: 6) {
                            GlyphIcon(glyph: .sparkle, size: 16, color: Kitchen.ready)
                            Text("\(readyCount)")
                                .font(.kitchenSerif(30, .bold))
                                .foregroundColor(Kitchen.ready)
                        }
                        Text("ready to cook")
                            .font(.kitchenRounded(13))
                            .foregroundColor(Kitchen.textMuted)
                    }
                }

                if pantry.selectedNonStapleCount > 0 {
                    Button(action: { withAnimation { pantry.clearSelection() } }) {
                        HStack(spacing: 6) {
                            GlyphIcon(glyph: .restart, size: 15, color: Kitchen.textMuted)
                            Text("Clear selection")
                                .font(.kitchenRounded(13.5, .medium))
                                .foregroundColor(Kitchen.textMuted)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Kitchen.accentSoft.opacity(0.6)))
                    }
                    .buttonStyle(PressableStyle())
                }
            }
        }
    }

    private func groupSection(_ group: IngredientGroup, _ items: [Ingredient]) -> some View {
        let selectedInGroup = items.filter { pantry.isSelected($0.id) }.count
        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                GroupEmblem(group: group, size: 34)
                Text(group.rawValue)
                    .font(.kitchenRounded(17, .semibold))
                    .foregroundColor(Kitchen.text)
                Spacer()
                if selectedInGroup > 0 {
                    Text("\(selectedInGroup)")
                        .font(.kitchenRounded(12.5, .bold))
                        .foregroundColor(group.color)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(group.color.opacity(0.14)))
                }
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 108), spacing: 10)], spacing: 10) {
                ForEach(items) { ing in
                    IngredientChip(ingredient: ing,
                                   selected: pantry.isSelected(ing.id)) {
                        withAnimation(.easeOut(duration: 0.12)) { pantry.toggle(ing.id) }
                    }
                }
            }
        }
    }
}

struct IngredientChip: View {
    let ingredient: Ingredient
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 7) {
                ZStack {
                    Circle()
                        .stroke(selected ? Color.clear : Kitchen.hairline, lineWidth: 1.4)
                        .background(Circle().fill(selected ? ingredient.group.color : Color.clear))
                        .frame(width: 20, height: 20)
                    if selected {
                        GlyphIcon(glyph: .check, size: 13, color: .white)
                    } else {
                        GlyphIcon(glyph: .plus, size: 12, color: Kitchen.textMuted.opacity(0.7))
                    }
                }
                Text(ingredient.name)
                    .font(.kitchenRounded(14, selected ? .semibold : .medium))
                    .foregroundColor(selected ? ingredient.group.color : Kitchen.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 11)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .fill(selected ? ingredient.group.color.opacity(0.12) : Kitchen.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 13, style: .continuous)
                    .stroke(selected ? ingredient.group.color.opacity(0.55) : Kitchen.hairline, lineWidth: 1)
            )
        }
        .buttonStyle(PressableStyle())
    }
}
