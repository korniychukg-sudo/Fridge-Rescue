import SwiftUI

struct MoreView: View {
    @EnvironmentObject var pantry: PantryStore
    @State private var showPrivacy = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            CenteredContent {
                VStack(alignment: .leading, spacing: 16) {
                    ScreenHeader(title: "More",
                                 subtitle: "Settings, your shopping list, and how it all works.")

                    settingsCard
                    shoppingLink
                    howItWorksCard
                    aboutCard
                }
                .padding(.horizontal, Metrics.gutter)
                .padding(.top, 8)
                .padding(.bottom, 28)
            }
        }
        .background(Kitchen.bg.ignoresSafeArea())
        .navigationBarHidden(true)
        .sheet(isPresented: $showPrivacy) {
            LarderPolicySheet(urlString: "https://example.com")
        }
    }

    private var settingsCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 14) {
                MiniSectionLabel(title: "Settings")
                Button(action: { withAnimation { pantry.assumeStaples.toggle() } }) {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Kitchen.grpStaple.opacity(0.15))
                            GlyphIcon(glyph: .jar, size: 20, color: Kitchen.grpStaple)
                        }
                        .frame(width: 38, height: 38)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Assume basic staples")
                                .font(.kitchenRounded(15.5, .semibold))
                                .foregroundColor(Kitchen.text)
                            Text("Count salt, oil, sugar and water as always on hand.")
                                .font(.kitchenRounded(12.5))
                                .foregroundColor(Kitchen.textMuted)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Spacer(minLength: 8)
                        CustomToggle(isOn: pantry.assumeStaples)
                    }
                }
                .buttonStyle(PressableStyle())
            }
        }
    }

    private var shoppingLink: some View {
        NavigationLink(destination: ShoppingListView()) {
            CardContainer {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Kitchen.primary.opacity(0.12))
                        GlyphIcon(glyph: .cart, size: 20, color: Kitchen.primary)
                    }
                    .frame(width: 38, height: 38)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Shopping list")
                            .font(.kitchenRounded(15.5, .semibold))
                            .foregroundColor(Kitchen.text)
                        Text("Everything your saved recipes still need.")
                            .font(.kitchenRounded(12.5))
                            .foregroundColor(Kitchen.textMuted)
                    }
                    Spacer(minLength: 0)
                    GlyphIcon(glyph: .chevronRight, size: 18, color: Kitchen.textMuted)
                }
            }
        }
        .buttonStyle(PressableStyle())
    }

    private var howItWorksCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                MiniSectionLabel(title: "How it works")
                howStep(1, "Add what you have", "Tap ingredients in the Kitchen tab as you check your fridge and cupboards.")
                howStep(2, "See what you can cook", "Recipes are ranked by how many ingredients you already have.")
                howStep(3, "Cook or shop", "Make the ready ones now, or add the missing items to your shopping list.")
            }
        }
    }

    private func howStep(_ n: Int, _ title: String, _ body: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(n)")
                .font(.kitchenRounded(13, .bold)).foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Circle().fill(Kitchen.accent))
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.kitchenRounded(15, .semibold)).foregroundColor(Kitchen.text)
                Text(body).font(.kitchenRounded(13.5)).foregroundColor(Kitchen.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var aboutCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 12) {
                MiniSectionLabel(title: "About")
                HStack(spacing: 8) {
                    Text("Fridge Rescue")
                        .font(.kitchenRounded(15, .semibold)).foregroundColor(Kitchen.text)
                    Spacer()
                    Text("Version 1.0").font(.kitchenRounded(13)).foregroundColor(Kitchen.textMuted)
                }
                Text("\(FoodLibrary.recipes.count) offline recipes · \(FoodLibrary.ingredients.count) ingredients. No accounts, no ads, no internet required.")
                    .font(.kitchenRounded(13.5)).foregroundColor(Kitchen.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
                Button(action: { showPrivacy = true }) {
                    HStack(spacing: 8) {
                        GlyphIcon(glyph: .info, size: 17, color: Kitchen.primary)
                        Text("Privacy Policy")
                            .font(.kitchenRounded(14.5, .medium)).foregroundColor(Kitchen.primary)
                        Spacer()
                        GlyphIcon(glyph: .chevronRight, size: 16, color: Kitchen.textMuted)
                    }
                    .padding(.top, 4)
                }
                .buttonStyle(PressableStyle())
            }
        }
    }
}

// A pill toggle drawn without the system Toggle control.
struct CustomToggle: View {
    let isOn: Bool
    var body: some View {
        ZStack(alignment: isOn ? .trailing : .leading) {
            Capsule()
                .fill(isOn ? Kitchen.accent : Kitchen.hairline)
                .frame(width: 48, height: 28)
            Circle()
                .fill(Color.white)
                .frame(width: 22, height: 22)
                .padding(3)
                .shadow(color: Color.black.opacity(0.12), radius: 1.5, y: 1)
        }
        .animation(.easeOut(duration: 0.16), value: isOn)
    }
}

// MARK: - Shopping list

struct ShoppingListView: View {
    @EnvironmentObject var pantry: PantryStore
    @Environment(\.presentationMode) private var presentationMode

    // Aggregate the non-staple ingredients that saved recipes still need, with how many
    // saved recipes call for each — so the most useful buys sort to the top.
    private var needed: [(ingredient: Ingredient, count: Int)] {
        var tally: [String: Int] = [:]
        for recipe in pantry.savedRecipes {
            let m = pantry.match(for: recipe)
            for id in m.missingIDs { tally[id, default: 0] += 1 }
        }
        return tally.compactMap { key, value in
            guard let ing = FoodLibrary.ingredient(key) else { return nil }
            return (ing, value)
        }
        .sorted { a, b in
            if a.count != b.count { return a.count > b.count }
            return a.ingredient.name < b.ingredient.name
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            Kitchen.bg.ignoresSafeArea()
            ScrollView(showsIndicators: false) {
                CenteredContent {
                    VStack(alignment: .leading, spacing: 16) {
                        if needed.isEmpty {
                            EmptyStateView(glyph: .cart,
                                           title: "Nothing to buy",
                                           message: pantry.savedRecipes.isEmpty
                                            ? "Save a few recipes and anything they're missing will gather here as a shopping list."
                                            : "You already have everything your saved recipes need. Time to cook!")
                                .frame(maxWidth: .infinity)
                                .padding(.top, 40)
                        } else {
                            Text("Tap an item once you've bought it to add it to your kitchen.")
                                .font(.kitchenRounded(13.5))
                                .foregroundColor(Kitchen.textMuted)
                                .fixedSize(horizontal: false, vertical: true)
                            LazyVStack(spacing: 10) {
                                ForEach(needed, id: \.ingredient.id) { entry in
                                    shoppingRow(entry.ingredient, entry.count)
                                }
                            }
                        }
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

    private var topBar: some View {
        HStack {
            Button(action: { presentationMode.wrappedValue.dismiss() }) {
                HStack(spacing: 4) {
                    GlyphIcon(glyph: .chevronLeft, size: 18, color: Kitchen.primary)
                    Text("More").font(.kitchenRounded(15, .medium)).foregroundColor(Kitchen.primary)
                }
                .padding(.vertical, 6).padding(.horizontal, 8)
            }
            .buttonStyle(PressableStyle())
            Spacer()
            Text("Shopping List")
                .font(.kitchenRounded(16, .semibold)).foregroundColor(Kitchen.primaryDk)
            Spacer()
            Color.clear.frame(width: 64, height: 1)
        }
        .padding(.horizontal, Metrics.gutter - 4)
        .padding(.top, 6)
        .background(Kitchen.bg.opacity(0.96).edgesIgnoringSafeArea(.top))
    }

    private func shoppingRow(_ ing: Ingredient, _ count: Int) -> some View {
        Button(action: { withAnimation { pantry.toggle(ing.id) } }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle().stroke(Kitchen.hairline, lineWidth: 1.6).frame(width: 24, height: 24)
                    GlyphIcon(glyph: .plus, size: 13, color: Kitchen.textMuted.opacity(0.7))
                }
                GroupEmblem(group: ing.group, size: 30)
                VStack(alignment: .leading, spacing: 1) {
                    Text(ing.name)
                        .font(.kitchenRounded(15.5, .medium)).foregroundColor(Kitchen.text)
                    Text(ing.group.rawValue)
                        .font(.kitchenRounded(12)).foregroundColor(ing.group.color)
                }
                Spacer(minLength: 0)
                Text("\(count) recipe\(count == 1 ? "" : "s")")
                    .font(.kitchenRounded(12, .medium))
                    .foregroundColor(Kitchen.textMuted)
                    .padding(.horizontal, 9).padding(.vertical, 4)
                    .background(Capsule().fill(Kitchen.accentSoft.opacity(0.7)))
            }
            .padding(.horizontal, 14).padding(.vertical, 11)
            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Kitchen.card))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Kitchen.hairline, lineWidth: 1))
        }
        .buttonStyle(PressableStyle())
    }
}
