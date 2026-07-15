import SwiftUI

struct SkilletLoadingScreen: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [Kitchen.bg, Kitchen.bgDeep],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 22) {
                ZStack {
                    Circle()
                        .fill(Kitchen.accentSoft)
                        .frame(width: 108, height: 108)
                        .scaleEffect(pulse ? 1.06 : 0.94)
                    Circle()
                        .stroke(Kitchen.primary.opacity(0.25), lineWidth: 2)
                        .frame(width: 108, height: 108)
                    GlyphIcon(glyph: .pot, size: 52, color: Kitchen.primary)
                }

                VStack(spacing: 6) {
                    Text("Fridge Rescue")
                        .font(.kitchenSerif(28, .semibold))
                        .foregroundColor(Kitchen.primaryDk)
                    Text("Cook with what you already have")
                        .font(.kitchenRounded(14.5))
                        .foregroundColor(Kitchen.textMuted)
                }

                DotsIndicator().padding(.top, 4)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                pulse = true
            }
        }
    }
}

// Three-dot progress made from custom shapes (no system spinner).
struct DotsIndicator: View {
    @State private var active = 0
    private let timer = Timer.publish(every: 0.35, on: .main, in: .common).autoconnect()
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(i == active ? Kitchen.primary : Kitchen.primary.opacity(0.25))
                    .frame(width: 8, height: 8)
            }
        }
        .onReceive(timer) { _ in active = (active + 1) % 3 }
    }
}
