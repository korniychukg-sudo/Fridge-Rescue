import SwiftUI

// Full-screen guided cooking: one step at a time, progress up top, finish celebration.
struct CookModeView: View {
    @EnvironmentObject var pantry: PantryStore
    @Environment(\.presentationMode) private var presentationMode
    let recipe: Recipe

    @State private var step = 0
    @State private var finished = false

    private var total: Int { recipe.steps.count }

    var body: some View {
        ZStack {
            LinearGradient(colors: [Kitchen.bg, Kitchen.bgDeep],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            if finished {
                doneScreen
            } else {
                cookingScreen
            }
        }
    }

    // MARK: - Cooking

    private var cookingScreen: some View {
        VStack(spacing: 0) {
            // Top bar
            HStack {
                Button(action: { presentationMode.wrappedValue.dismiss() }) {
                    ZStack {
                        Circle().fill(Kitchen.card)
                        GlyphIcon(glyph: .close, size: 15, color: Kitchen.text)
                    }
                    .frame(width: 34, height: 34)
                    .overlay(Circle().stroke(Kitchen.hairline, lineWidth: 1))
                }
                .buttonStyle(PressableStyle())
                Spacer()
                Text(recipe.name)
                    .font(.kitchenRounded(15, .semibold))
                    .foregroundColor(Kitchen.primaryDk)
                    .lineLimit(1)
                Spacer()
                Color.clear.frame(width: 34, height: 34)
            }
            .padding(.horizontal, Metrics.gutter)
            .padding(.top, 10)

            // Progress capsules
            HStack(spacing: 6) {
                ForEach(0..<total, id: \.self) { i in
                    Capsule()
                        .fill(i <= step ? Kitchen.primary : Kitchen.primary.opacity(0.18))
                        .frame(height: 5)
                }
            }
            .padding(.horizontal, Metrics.gutter)
            .padding(.top, 16)

            Spacer()

            // Step content
            CenteredContent {
                VStack(spacing: 22) {
                    Text("STEP \(step + 1) OF \(total)")
                        .font(.kitchenRounded(12, .bold)).tracking(1.4)
                        .foregroundColor(Kitchen.textMuted)

                    ZStack {
                        Circle().fill(Kitchen.accentSoft)
                        Text("\(step + 1)")
                            .font(.kitchenSerif(34, .bold))
                            .foregroundColor(Kitchen.primary)
                    }
                    .frame(width: 76, height: 76)

                    Text(recipe.steps[step])
                        .font(.kitchenRounded(20, .medium))
                        .foregroundColor(Kitchen.text)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 8)
                        .animation(nil, value: step)

                    if step == total - 1, let tip = recipe.tip {
                        HStack(alignment: .top, spacing: 8) {
                            GlyphIcon(glyph: .sparkle, size: 15, color: Kitchen.honey)
                            Text(tip)
                                .font(.kitchenRounded(13.5))
                                .foregroundColor(Kitchen.textMuted)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Kitchen.honey.opacity(0.10)))
                    }
                }
                .padding(.horizontal, Metrics.gutter + 8)
            }

            Spacer()

            // Controls
            HStack(spacing: 12) {
                if step > 0 {
                    Button(action: { withAnimation(.easeOut(duration: 0.18)) { step -= 1 } }) {
                        HStack(spacing: 6) {
                            GlyphIcon(glyph: .chevronLeft, size: 16, color: Kitchen.primary)
                            Text("Back").font(.kitchenRounded(16, .semibold)).foregroundColor(Kitchen.primary)
                        }
                        .frame(width: 110)
                        .padding(.vertical, 15)
                        .background(RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Kitchen.accentSoft.opacity(0.7)))
                    }
                    .buttonStyle(PressableStyle())
                }
                Button(action: advance) {
                    HStack(spacing: 8) {
                        Text(step == total - 1 ? "Finish" : "Next step")
                            .font(.kitchenRounded(16.5, .semibold)).foregroundColor(.white)
                        GlyphIcon(glyph: step == total - 1 ? .check : .chevronRight,
                                  size: 16, color: .white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Kitchen.primary))
                }
                .buttonStyle(PressableStyle())
            }
            .padding(.horizontal, Metrics.gutter)
            .padding(.bottom, 18)
            .frame(maxWidth: Metrics.contentMaxWidth)
        }
    }

    private func advance() {
        if step < total - 1 {
            withAnimation(.easeOut(duration: 0.18)) { step += 1 }
        } else {
            pantry.markCooked(recipe.id)
            withAnimation(.easeOut(duration: 0.25)) { finished = true }
        }
    }

    // MARK: - Done

    private var doneScreen: some View {
        CenteredContent {
            VStack(spacing: 20) {
                Spacer()
                RecipeArtView(recipe: recipe, corner: 22)
                    .frame(height: 190)
                    .padding(.horizontal, Metrics.gutter)
                    .shadow(color: Color.black.opacity(0.08), radius: 10, y: 5)
                ZStack {
                    Circle().fill(Kitchen.ready.opacity(0.14)).frame(width: 72, height: 72)
                    Circle().stroke(Kitchen.ready.opacity(0.3), lineWidth: 2).frame(width: 72, height: 72)
                    GlyphIcon(glyph: .check, size: 34, color: Kitchen.ready)
                }
                Text("Enjoy your meal!")
                    .font(.kitchenSerif(28, .semibold))
                    .foregroundColor(Kitchen.primaryDk)
                Text("\(recipe.name) is done. That's meal number \(pantry.cookedTotal) cooked with Fridgeful.")
                    .font(.kitchenRounded(15))
                    .foregroundColor(Kitchen.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                Spacer()
                PrimaryButton(title: "Done", leadingGlyph: .check) {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding(.horizontal, Metrics.gutter)
                .padding(.bottom, 24)
            }
        }
    }
}
