import SwiftUI

struct RecipeDetailView: View {
    @EnvironmentObject var pantry: PantryStore
    @Environment(\.presentationMode) private var presentationMode
    let recipe: Recipe

    private var match: MatchResult { pantry.match(for: recipe) }

    private var tint: Color {
        let m = match
        if m.isReady { return Kitchen.ready }
        if m.missingCount <= 2 { return Kitchen.almost }
        return Kitchen.far
    }

    var body: some View {
        ZStack(alignment: .top) {
            Kitchen.bg.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                CenteredContent {
                    VStack(alignment: .leading, spacing: 18) {
                        titleBlock
                        matchCard
                        ingredientsCard
                        stepsCard
                        if let tip = recipe.tip { tipCard(tip) }
                        saveButton
                    }
                    .padding(.horizontal, Metrics.gutter)
                    .padding(.top, 64)
                    .padding(.bottom, 30)
                }
            }

            topBar
        }
        .navigationBarHidden(true)
    }

    // MARK: - Top bar with custom back control

    private var topBar: some View {
        HStack {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                HStack(spacing: 4) {
                    GlyphIcon(glyph: .chevronLeft, size: 18, color: Kitchen.primary)
                    Text("Back").font(.kitchenRounded(15, .medium)).foregroundColor(Kitchen.primary)
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 8)
            }
            .buttonStyle(PressableStyle())
            Spacer()
            Button(action: { withAnimation { pantry.toggleSaved(recipe.id) } }) {
                GlyphIcon(glyph: pantry.isSaved(recipe.id) ? .bookmarkFill : .bookmark,
                          size: 20, color: Kitchen.primary)
                    .padding(8)
            }
            .buttonStyle(PressableStyle())
        }
        .padding(.horizontal, Metrics.gutter - 4)
        .padding(.top, 6)
        .background(Kitchen.bg.opacity(0.96).edgesIgnoringSafeArea(.top))
    }

    // MARK: - Sections

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                MealEmblem(kind: recipe.kind, size: 52)
                VStack(alignment: .leading, spacing: 4) {
                    MealTag(kind: recipe.kind)
                    Text(recipe.name)
                        .font(.kitchenSerif(26, .semibold))
                        .foregroundColor(Kitchen.primaryDk)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
            }
            Text(recipe.blurb)
                .font(.kitchenRounded(15))
                .foregroundColor(Kitchen.textMuted)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 16) {
                MetaChip(glyph: .clock, text: "\(recipe.minutes) min")
                MetaChip(glyph: .people, text: "Serves \(recipe.servings)")
                MetaChip(glyph: .flame, text: recipe.difficulty.rawValue, tint: recipe.difficulty.color)
            }
        }
    }

    private var matchCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(match.isReady ? "You can make this now" : "Your match")
                        .font(.kitchenRounded(16, .semibold))
                        .foregroundColor(Kitchen.text)
                    Spacer()
                    Text("\(match.percent)%")
                        .font(.kitchenSerif(22, .bold))
                        .foregroundColor(tint)
                }
                MatchMeter(ratio: match.ratio, color: tint, height: 10)
                Text("You have \(match.haveCount) of \(match.total) ingredients.")
                    .font(.kitchenRounded(13.5))
                    .foregroundColor(Kitchen.textMuted)
            }
        }
    }

    private var ingredientsCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    MiniSectionLabel(title: "Ingredients")
                    Spacer()
                    if !match.missingIDs.isEmpty {
                        Text("Tap to add what you have")
                            .font(.kitchenRounded(11.5))
                            .foregroundColor(Kitchen.textMuted)
                    }
                }
                VStack(spacing: 0) {
                    ForEach(Array(recipe.items.enumerated()), id: \.offset) { idx, item in
                        ingredientRow(item)
                        if idx < recipe.items.count - 1 {
                            Rectangle().fill(Kitchen.hairline).frame(height: 1).padding(.vertical, 2)
                        }
                    }
                }
            }
        }
    }

    private func ingredientRow(_ item: RecipeItem) -> some View {
        let id = item.ingredientID
        let available = pantry.availableIDs.contains(id)
        let isStaple = FoodLibrary.stapleIDs.contains(id)
        let name = FoodLibrary.name(for: id)
        // Missing, non-staple ingredients can be tapped to mark "I have this" — adding
        // them straight to the kitchen without leaving the recipe.
        let tappable = !available && !isStaple

        return Button(action: {
            if tappable { withAnimation { pantry.toggle(id) } }
        }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(available ? Kitchen.ready.opacity(0.15)
                              : (isStaple ? Kitchen.far.opacity(0.12) : Kitchen.almost.opacity(0.15)))
                        .frame(width: 26, height: 26)
                    if available {
                        GlyphIcon(glyph: .check, size: 15, color: Kitchen.ready)
                    } else {
                        GlyphIcon(glyph: .plus, size: 14, color: isStaple ? Kitchen.far : Kitchen.almost)
                    }
                }
                VStack(alignment: .leading, spacing: 1) {
                    Text(name)
                        .font(.kitchenRounded(15, .medium))
                        .foregroundColor(available ? Kitchen.text : Kitchen.text.opacity(0.85))
                    if !available {
                        Text(isStaple ? "Pantry staple" : "Not in your kitchen")
                            .font(.kitchenRounded(11.5))
                            .foregroundColor(isStaple ? Kitchen.far : Kitchen.almost)
                    }
                }
                Spacer(minLength: 0)
                Text(item.amount)
                    .font(.kitchenRounded(13.5))
                    .foregroundColor(Kitchen.textMuted)
                    .multilineTextAlignment(.trailing)
            }
            .padding(.vertical, 9)
            .contentShape(Rectangle())
        }
        .buttonStyle(PressableStyle())
        .disabled(!tappable)
    }

    private var stepsCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 14) {
                MiniSectionLabel(title: "Method")
                ForEach(Array(recipe.steps.enumerated()), id: \.offset) { idx, step in
                    NumberedRow(index: idx + 1, text: step)
                }
            }
        }
    }

    private func tipCard(_ tip: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle().fill(Kitchen.honey.opacity(0.16))
                GlyphIcon(glyph: .sparkle, size: 18, color: Kitchen.honey)
            }
            .frame(width: 38, height: 38)
            VStack(alignment: .leading, spacing: 3) {
                Text("Chef's tip")
                    .font(.kitchenRounded(13, .bold))
                    .foregroundColor(Kitchen.primaryDk)
                Text(tip)
                    .font(.kitchenRounded(14.5))
                    .foregroundColor(Kitchen.text)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Kitchen.honey.opacity(0.09)))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(Kitchen.honey.opacity(0.3), lineWidth: 1))
    }

    private var saveButton: some View {
        Group {
            if pantry.isSaved(recipe.id) {
                SecondaryButton(title: "Saved", leadingGlyph: .bookmarkFill) {
                    withAnimation { pantry.toggleSaved(recipe.id) }
                }
            } else {
                PrimaryButton(title: "Save recipe", leadingGlyph: .bookmark) {
                    withAnimation { pantry.toggleSaved(recipe.id) }
                }
            }
        }
        .padding(.top, 2)
    }
}
