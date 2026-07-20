import SwiftUI

// MARK: - Reusable building blocks shared across screens.

struct CardContainer<Content: View>: View {
    var padding: CGFloat = 18
    @ViewBuilder var content: () -> Content
    var body: some View {
        content()
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous).fill(Kitchen.card)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(Kitchen.hairline, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.04), radius: 7, y: 3)
    }
}

struct ScreenHeader: View {
    let title: String
    var subtitle: String? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.kitchenSerif(30, .semibold))
                .foregroundColor(Kitchen.primaryDk)
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.kitchenRounded(15))
                    .foregroundColor(Kitchen.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// Subtle press feedback without relying on system button chrome.
struct PressableStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

struct PrimaryButton: View {
    let title: String
    var leadingGlyph: Glyph? = nil
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let g = leadingGlyph { GlyphIcon(glyph: g, size: 18, color: .white) }
                Text(title).font(.kitchenRounded(16.5, .semibold)).foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Kitchen.primary))
        }
        .buttonStyle(PressableStyle())
    }
}

struct SecondaryButton: View {
    let title: String
    var leadingGlyph: Glyph? = nil
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let g = leadingGlyph { GlyphIcon(glyph: g, size: 18, color: Kitchen.primary) }
                Text(title).font(.kitchenRounded(16, .semibold)).foregroundColor(Kitchen.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Kitchen.accentSoft.opacity(0.7)))
            .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Kitchen.primary.opacity(0.22), lineWidth: 1))
        }
        .buttonStyle(PressableStyle())
    }
}

struct GroupEmblem: View {
    let group: IngredientGroup
    var size: CGFloat = 40
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .fill(group.color.opacity(0.15))
            GlyphIcon(glyph: group.glyph, size: size * 0.56, color: group.color)
        }
        .frame(width: size, height: size)
    }
}

struct MealEmblem: View {
    let kind: MealKind
    var size: CGFloat = 44
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .fill(Kitchen.primary.opacity(0.12))
            GlyphIcon(glyph: kind.glyph, size: size * 0.55, color: Kitchen.primary)
        }
        .frame(width: size, height: size)
    }
}

// A progress meter drawn with shapes to express how well a recipe matches the pantry.
struct MatchMeter: View {
    let ratio: Double
    let color: Color
    var height: CGFloat = 8
    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule().fill(color.opacity(0.16))
                Capsule().fill(color)
                    .frame(width: max(height, geo.size.width * CGFloat(min(max(ratio, 0), 1))))
            }
        }
        .frame(height: height)
    }
}

struct MetaChip: View {
    let glyph: Glyph
    let text: String
    var tint: Color = Kitchen.textMuted
    var body: some View {
        HStack(spacing: 5) {
            GlyphIcon(glyph: glyph, size: 14, color: tint)
            Text(text).font(.kitchenRounded(12.5, .medium)).foregroundColor(tint)
        }
    }
}

struct MealTag: View {
    let kind: MealKind
    var body: some View {
        Text(kind.rawValue.uppercased())
            .font(.kitchenRounded(10.5, .bold))
            .tracking(0.6)
            .foregroundColor(Kitchen.primaryDk)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Capsule().fill(Kitchen.primary.opacity(0.12)))
    }
}

struct CuisineTag: View {
    let cuisine: Cuisine
    var body: some View {
        HStack(spacing: 4) {
            GlyphIcon(glyph: cuisine.glyph, size: 11, color: cuisine.color)
            Text(cuisine.rawValue.uppercased())
                .font(.kitchenRounded(10.5, .bold))
                .tracking(0.6)
                .foregroundColor(cuisine.color)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().fill(cuisine.color.opacity(0.12)))
    }
}

struct NumberedRow: View {
    let index: Int
    let text: String
    var accent: Color = Kitchen.primary
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(index)")
                .font(.kitchenRounded(13, .bold)).foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Circle().fill(accent))
            Text(text)
                .font(.kitchenRounded(15.5)).foregroundColor(Kitchen.text)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct MiniSectionLabel: View {
    let title: String
    var body: some View {
        Text(title.uppercased())
            .font(.kitchenRounded(12, .bold)).tracking(0.8)
            .foregroundColor(Kitchen.textMuted)
    }
}

// Constrains and centers content — keeps things readable on wide iPad screens.
struct CenteredContent<Content: View>: View {
    @ViewBuilder var content: () -> Content
    var body: some View {
        HStack(spacing: 0) {
            Spacer(minLength: 0)
            content().frame(maxWidth: Metrics.contentMaxWidth)
            Spacer(minLength: 0)
        }
    }
}

struct EmptyStateView: View {
    let glyph: Glyph
    let title: String
    let message: String
    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle().fill(Kitchen.accentSoft)
                GlyphIcon(glyph: glyph, size: 40, color: Kitchen.primary.opacity(0.7))
            }
            .frame(width: 84, height: 84)
            Text(title)
                .font(.kitchenRounded(18, .semibold)).foregroundColor(Kitchen.text)
            Text(message)
                .font(.kitchenRounded(14.5)).foregroundColor(Kitchen.textMuted)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(28)
        .frame(maxWidth: 420)
    }
}

// A rounded search field built without system components.
struct SearchField: View {
    @Binding var text: String
    var placeholder: String = "Search"
    var body: some View {
        HStack(spacing: 10) {
            GlyphIcon(glyph: .search, size: 18, color: Kitchen.textMuted)
            TextField(placeholder, text: $text)
                .font(.kitchenRounded(15.5))
                .foregroundColor(Kitchen.text)
                .autocorrectionDisabled(true)
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    GlyphIcon(glyph: .close, size: 16, color: Kitchen.textMuted)
                }
                .buttonStyle(PressableStyle())
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Kitchen.card))
        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Kitchen.hairline, lineWidth: 1))
    }
}
