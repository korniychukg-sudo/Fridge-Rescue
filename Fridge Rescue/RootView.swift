import SwiftUI

struct RootView: View {
    @EnvironmentObject var pantry: PantryStore
    @State private var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            Kitchen.bg.ignoresSafeArea()

            VStack(spacing: 0) {
                Group {
                    switch selectedTab {
                    case 0: NavigationView { PantryView() }.navigationViewStyle(StackNavigationViewStyle())
                    case 1: NavigationView { RecipesView() }.navigationViewStyle(StackNavigationViewStyle())
                    case 2: NavigationView { SavedView() }.navigationViewStyle(StackNavigationViewStyle())
                    default: NavigationView { MoreView() }.navigationViewStyle(StackNavigationViewStyle())
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                tabBar
            }
        }
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabButton(0, "Kitchen", .basket)
            tabButton(1, "Recipes", .pot)
            tabButton(2, "Saved", .bookmark)
            tabButton(3, "More", .sliders)
        }
        .padding(.top, 8)
        .padding(.bottom, 4)
        .background(
            Kitchen.card
                .overlay(Rectangle().fill(Kitchen.hairline).frame(height: 1), alignment: .top)
                .edgesIgnoringSafeArea(.bottom)
        )
    }

    private func tabButton(_ index: Int, _ label: String, _ glyph: Glyph) -> some View {
        let active = selectedTab == index
        return Button(action: { selectedTab = index }) {
            VStack(spacing: 4) {
                ZStack {
                    if active {
                        Capsule().fill(Kitchen.primary.opacity(0.12))
                            .frame(width: 46, height: 30)
                    }
                    // "Saved" uses a filled bookmark when active for a clear on/off state.
                    GlyphIcon(glyph: (index == 2 && active) ? .bookmarkFill : glyph,
                              size: 22,
                              color: active ? Kitchen.primary : Kitchen.textMuted.opacity(0.8))
                }
                .frame(height: 30)
                Text(label)
                    .font(.kitchenRounded(11, active ? .semibold : .medium))
                    .foregroundColor(active ? Kitchen.primary : Kitchen.textMuted.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PressableStyle())
    }
}
