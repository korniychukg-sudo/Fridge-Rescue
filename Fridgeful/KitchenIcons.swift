import SwiftUI

// All in-app iconography is hand-drawn in a 24x24 space with Canvas and scaled to fit.
// No SF Symbols, no emoji, no system imagery anywhere in the UI.

enum Glyph {
    // Ingredient groups
    case carrot, apple, drumstick, cheese, wheat, jar, herb
    // Meal kinds
    case sunrise, sandwich, pot, bowl, leaf, skillet, cake, cup
    // UI / status
    case chevronRight, chevronLeft, check, close, plus, minus, search, trash
    case bookmark, bookmarkFill, sliders, cart, clock, flame, people, info
    case restart, sparkle, basket
    // Cuisines & cook mode
    case globe, pizza, croissant, oliveBranch, chili, burger, wok, mortar
    case star, play
}

struct GlyphIcon: View {
    let glyph: Glyph
    var size: CGFloat = 24
    var color: Color = Kitchen.text

    var body: some View {
        Canvas { ctx, csize in
            let s = csize.width / 24.0
            let lw = max(1.4, csize.width / 13.0)
            let style = StrokeStyle(lineWidth: lw, lineCap: .round, lineJoin: .round)
            let P: (CGFloat, CGFloat) -> CGPoint = { CGPoint(x: $0 * s, y: $1 * s) }

            func stroke(_ build: (inout Path) -> Void) {
                var p = Path(); build(&p)
                ctx.stroke(p, with: .color(color), style: style)
            }
            func fill(_ build: (inout Path) -> Void) {
                var p = Path(); build(&p)
                ctx.fill(p, with: .color(color))
            }
            func dot(_ x: CGFloat, _ y: CGFloat, _ r: CGFloat) {
                let rect = CGRect(x: (x - r) * s, y: (y - r) * s, width: 2 * r * s, height: 2 * r * s)
                ctx.fill(Path(ellipseIn: rect), with: .color(color))
            }
            func ellipse(_ x: CGFloat, _ y: CGFloat, _ w: CGFloat, _ h: CGFloat) {
                stroke { p in p.addEllipse(in: CGRect(x: x * s, y: y * s, width: w * s, height: h * s)) }
            }

            switch glyph {

            case .carrot:
                fill { p in
                    p.move(to: P(6.5, 17.5))
                    p.addLine(to: P(16, 8))
                    p.addQuadCurve(to: P(8.5, 19.5), control: P(13, 15))
                    p.closeSubpath()
                }
                stroke { p in
                    p.move(to: P(15, 9)); p.addLine(to: P(18, 6))
                    p.move(to: P(16, 8)); p.addLine(to: P(19.5, 8.5))
                    p.move(to: P(15.2, 7)); p.addLine(to: P(15.5, 4))
                }

            case .apple:
                stroke { p in
                    p.move(to: P(12, 7))
                    p.addQuadCurve(to: P(6, 10), control: P(8, 6.5))
                    p.addQuadCurve(to: P(8, 19), control: P(4, 15))
                    p.addQuadCurve(to: P(12, 18), control: P(10, 20))
                    p.addQuadCurve(to: P(16, 19), control: P(14, 20))
                    p.addQuadCurve(to: P(18, 10), control: P(20, 15))
                    p.addQuadCurve(to: P(12, 7), control: P(16, 6.5))
                }
                stroke { p in
                    p.move(to: P(12, 7)); p.addLine(to: P(12.5, 4))
                    p.move(to: P(12.5, 4.5)); p.addQuadCurve(to: P(16, 4), control: P(15, 3))
                }

            case .drumstick:
                fill { p in
                    p.addEllipse(in: CGRect(x: 11 * s, y: 4.5 * s, width: 8.5 * s, height: 8.5 * s))
                }
                stroke { p in
                    p.move(to: P(12.5, 11)); p.addLine(to: P(6.5, 17))
                }
                stroke { p in
                    p.move(to: P(6.5, 17)); p.addLine(to: P(4.5, 16.5))
                    p.move(to: P(6.5, 17)); p.addLine(to: P(6, 19.5))
                    p.move(to: P(6.5, 17)); p.addLine(to: P(4.8, 19))
                }

            case .cheese:
                stroke { p in
                    p.move(to: P(4, 16))
                    p.addLine(to: P(4, 12))
                    p.addLine(to: P(19, 8))
                    p.addLine(to: P(19, 16))
                    p.closeSubpath()
                }
                dot(8, 13.5, 1.1)
                dot(13, 12.6, 1.1)
                dot(11, 14.6, 0.9)

            case .wheat:
                stroke { p in p.move(to: P(12, 20)); p.addLine(to: P(12, 6)) }
                for yy in stride(from: CGFloat(7.5), through: 13.5, by: 2.0) {
                    stroke { p in
                        p.move(to: P(12, yy)); p.addQuadCurve(to: P(8, yy - 1.5), control: P(9, yy + 0.5))
                        p.move(to: P(12, yy)); p.addQuadCurve(to: P(16, yy - 1.5), control: P(15, yy + 0.5))
                    }
                }
                stroke { p in
                    p.move(to: P(12, 6)); p.addQuadCurve(to: P(9.5, 3.5), control: P(10, 5))
                    p.move(to: P(12, 6)); p.addQuadCurve(to: P(14.5, 3.5), control: P(14, 5))
                }

            case .jar:
                stroke { p in
                    p.addRoundedRect(in: CGRect(x: 6 * s, y: 7 * s, width: 12 * s, height: 13 * s),
                                     cornerSize: CGSize(width: 2.4 * s, height: 2.4 * s))
                }
                stroke { p in
                    p.move(to: P(8, 7)); p.addLine(to: P(8, 4.5)); p.addLine(to: P(16, 4.5)); p.addLine(to: P(16, 7))
                }
                stroke { p in p.move(to: P(6, 11)); p.addLine(to: P(18, 11)) }

            case .herb:
                stroke { p in p.move(to: P(12, 20)); p.addLine(to: P(12, 8)) }
                fill { p in
                    p.move(to: P(12, 13)); p.addQuadCurve(to: P(6, 10.5), control: P(7.5, 14.5))
                    p.addQuadCurve(to: P(12, 13), control: P(9.5, 9))
                }
                fill { p in
                    p.move(to: P(12, 11)); p.addQuadCurve(to: P(18, 8.5), control: P(16.5, 12.5))
                    p.addQuadCurve(to: P(12, 11), control: P(14.5, 7))
                }
                fill { p in
                    p.move(to: P(12, 9)); p.addQuadCurve(to: P(9, 5.5), control: P(9.5, 8.5))
                    p.addQuadCurve(to: P(12, 9), control: P(11.5, 6))
                }

            case .sunrise:
                stroke { p in p.move(to: P(3, 18)); p.addLine(to: P(21, 18)) }
                stroke { p in
                    p.addArc(center: P(12, 18), radius: 4.5 * s,
                             startAngle: .degrees(180), endAngle: .degrees(360), clockwise: false)
                }
                for a in stride(from: 200.0, through: 340.0, by: 35.0) {
                    let rad = a * Double.pi / 180
                    let x1 = 12 + 6.5 * CGFloat(cos(rad)), y1 = 18 + 6.5 * CGFloat(sin(rad))
                    let x2 = 12 + 8.6 * CGFloat(cos(rad)), y2 = 18 + 8.6 * CGFloat(sin(rad))
                    stroke { p in p.move(to: P(x1, y1)); p.addLine(to: P(x2, y2)) }
                }

            case .sandwich:
                stroke { p in
                    p.move(to: P(4, 9)); p.addQuadCurve(to: P(20, 9), control: P(12, 4)); p.closeSubpath()
                }
                stroke { p in p.move(to: P(4, 12.5)); p.addLine(to: P(20, 12.5)) }
                stroke { p in
                    p.move(to: P(4.5, 15.5)); p.addLine(to: P(19.5, 15.5))
                    p.addLine(to: P(18.5, 17.5)); p.addLine(to: P(5.5, 17.5)); p.closeSubpath()
                }

            case .pot:
                stroke { p in
                    p.addRoundedRect(in: CGRect(x: 5 * s, y: 9 * s, width: 14 * s, height: 9 * s),
                                     cornerSize: CGSize(width: 2 * s, height: 2 * s))
                }
                stroke { p in
                    p.move(to: P(3.5, 8)); p.addLine(to: P(20.5, 8))
                }
                stroke { p in
                    p.move(to: P(6.5, 8)); p.addLine(to: P(6.5, 6.5))
                    p.move(to: P(17.5, 8)); p.addLine(to: P(17.5, 6.5))
                }
                stroke { p in
                    p.move(to: P(9, 4.5)); p.addQuadCurve(to: P(9, 2.8), control: P(10, 3.5))
                    p.move(to: P(12, 4.5)); p.addQuadCurve(to: P(12, 2.8), control: P(13, 3.5))
                    p.move(to: P(15, 4.5)); p.addQuadCurve(to: P(15, 2.8), control: P(16, 3.5))
                }

            case .bowl:
                stroke { p in
                    p.move(to: P(4, 10.5))
                    p.addQuadCurve(to: P(20, 10.5), control: P(12, 20))
                }
                stroke { p in p.move(to: P(3, 10.5)); p.addLine(to: P(21, 10.5)) }
                stroke { p in
                    p.move(to: P(9, 7)); p.addQuadCurve(to: P(9, 4.5), control: P(10.2, 5.5))
                    p.move(to: P(12, 7)); p.addQuadCurve(to: P(12, 4.5), control: P(13.2, 5.5))
                    p.move(to: P(15, 7)); p.addQuadCurve(to: P(15, 4.5), control: P(16.2, 5.5))
                }

            case .leaf:
                stroke { p in
                    p.move(to: P(12, 3))
                    p.addQuadCurve(to: P(19, 13), control: P(19, 5))
                    p.addQuadCurve(to: P(12, 21), control: P(19, 19))
                    p.addQuadCurve(to: P(5, 13), control: P(5, 19))
                    p.addQuadCurve(to: P(12, 3), control: P(5, 5))
                }
                stroke { p in p.move(to: P(12, 5)); p.addLine(to: P(12, 19)) }

            case .skillet:
                ellipse(4, 9, 12, 8)
                stroke { p in p.move(to: P(16, 13)); p.addLine(to: P(22, 13)) }

            case .cake:
                stroke { p in
                    p.addRoundedRect(in: CGRect(x: 5 * s, y: 11 * s, width: 14 * s, height: 8 * s),
                                     cornerSize: CGSize(width: 1.6 * s, height: 1.6 * s))
                }
                stroke { p in p.move(to: P(5, 14.5)); p.addQuadCurve(to: P(9.5, 14.5), control: P(7.25, 16.5))
                    p.addQuadCurve(to: P(14, 14.5), control: P(11.75, 16.5))
                    p.addQuadCurve(to: P(19, 14.5), control: P(16.5, 16.5)) }
                stroke { p in p.move(to: P(12, 11)); p.addLine(to: P(12, 7.5)) }
                dot(12, 6.5, 1.0)

            case .cup:
                stroke { p in
                    p.move(to: P(6, 6)); p.addLine(to: P(7, 18))
                    p.addQuadCurve(to: P(13, 20), control: P(10, 20))
                    p.addLine(to: P(14, 6)); p.closeSubpath()
                }
                stroke { p in
                    p.move(to: P(14, 9)); p.addQuadCurve(to: P(18, 12), control: P(18.5, 9))
                    p.addQuadCurve(to: P(13.5, 14), control: P(17.5, 14))
                }

            case .chevronRight:
                stroke { p in p.move(to: P(9.5, 5.5)); p.addLine(to: P(15.5, 12)); p.addLine(to: P(9.5, 18.5)) }

            case .chevronLeft:
                stroke { p in p.move(to: P(14.5, 5.5)); p.addLine(to: P(8.5, 12)); p.addLine(to: P(14.5, 18.5)) }

            case .check:
                stroke { p in p.move(to: P(5, 12.5)); p.addLine(to: P(10, 17.5)); p.addLine(to: P(19, 7)) }

            case .close:
                stroke { p in
                    p.move(to: P(6, 6)); p.addLine(to: P(18, 18))
                    p.move(to: P(18, 6)); p.addLine(to: P(6, 18))
                }

            case .plus:
                stroke { p in
                    p.move(to: P(12, 5)); p.addLine(to: P(12, 19))
                    p.move(to: P(5, 12)); p.addLine(to: P(19, 12))
                }

            case .minus:
                stroke { p in p.move(to: P(5, 12)); p.addLine(to: P(19, 12)) }

            case .search:
                ellipse(5, 5, 11, 11)
                stroke { p in p.move(to: P(15, 15)); p.addLine(to: P(19.5, 19.5)) }

            case .trash:
                stroke { p in p.move(to: P(5.5, 7)); p.addLine(to: P(18.5, 7)) }
                stroke { p in p.move(to: P(9, 7)); p.addLine(to: P(9.5, 4.5)); p.addLine(to: P(14.5, 4.5)); p.addLine(to: P(15, 7)) }
                stroke { p in p.move(to: P(7, 7)); p.addLine(to: P(7.8, 19.5)); p.addLine(to: P(16.2, 19.5)); p.addLine(to: P(17, 7)) }
                stroke { p in
                    p.move(to: P(10, 10)); p.addLine(to: P(10.3, 16.5))
                    p.move(to: P(14, 10)); p.addLine(to: P(13.7, 16.5))
                }

            case .bookmark:
                stroke { p in
                    p.move(to: P(7, 4)); p.addLine(to: P(17, 4)); p.addLine(to: P(17, 20))
                    p.addLine(to: P(12, 15.5)); p.addLine(to: P(7, 20)); p.closeSubpath()
                }

            case .bookmarkFill:
                fill { p in
                    p.move(to: P(7, 4)); p.addLine(to: P(17, 4)); p.addLine(to: P(17, 20))
                    p.addLine(to: P(12, 15.5)); p.addLine(to: P(7, 20)); p.closeSubpath()
                }

            case .sliders:
                stroke { p in
                    p.move(to: P(4, 8.5)); p.addLine(to: P(20, 8.5))
                    p.move(to: P(4, 15.5)); p.addLine(to: P(20, 15.5))
                }
                dot(15, 8.5, 2.4)
                dot(9, 15.5, 2.4)

            case .cart:
                stroke { p in
                    p.move(to: P(3.5, 4.5)); p.addLine(to: P(5.5, 4.5)); p.addLine(to: P(8, 15.5))
                    p.addLine(to: P(17.5, 15.5)); p.addLine(to: P(19, 7.5)); p.addLine(to: P(6.5, 7.5))
                }
                dot(9.5, 18.5, 1.4)
                dot(16.5, 18.5, 1.4)

            case .clock:
                ellipse(4, 4, 16, 16)
                stroke { p in p.move(to: P(12, 7.5)); p.addLine(to: P(12, 12)); p.addLine(to: P(15.2, 14)) }

            case .flame:
                stroke { p in
                    p.move(to: P(12, 3.5))
                    p.addQuadCurve(to: P(17, 12), control: P(17.5, 7))
                    p.addQuadCurve(to: P(12, 20.5), control: P(17, 18))
                    p.addQuadCurve(to: P(7, 12), control: P(7, 18))
                    p.addQuadCurve(to: P(10, 9), control: P(8.5, 12.5))
                    p.addQuadCurve(to: P(12, 3.5), control: P(11, 6))
                }

            case .people:
                dot(8.5, 8, 2.4)
                dot(15.5, 8, 2.4)
                stroke { p in
                    p.move(to: P(4.5, 18)); p.addQuadCurve(to: P(12.5, 18), control: P(8.5, 12.5))
                    p.move(to: P(11.5, 18)); p.addQuadCurve(to: P(19.5, 18), control: P(15.5, 12.5))
                }

            case .info:
                ellipse(4, 4, 16, 16)
                dot(12, 8, 1.1)
                stroke { p in p.move(to: P(12, 11.5)); p.addLine(to: P(12, 16.5)) }

            case .restart:
                let cx: CGFloat = 12, cy: CGFloat = 12, r: CGFloat = 7.2
                let startA = -0.55 * Double.pi, endA = 1.35 * Double.pi
                var pts: [CGPoint] = []
                for i in 0...46 {
                    let a = startA + (endA - startA) * Double(i) / 46.0
                    pts.append(P(cx + r * CGFloat(cos(a)), cy + r * CGFloat(sin(a))))
                }
                stroke { p in p.addLines(pts) }
                let ax = cx + r * CGFloat(cos(startA)), ay = cy + r * CGFloat(sin(startA))
                stroke { p in
                    p.move(to: P(ax - 2.6, ay - 1.2)); p.addLine(to: P(ax, ay)); p.addLine(to: P(ax + 1.2, ay - 2.6))
                }

            case .sparkle:
                fill { p in
                    p.move(to: P(12, 4))
                    p.addQuadCurve(to: P(13, 11), control: P(12.4, 9.6))
                    p.addQuadCurve(to: P(20, 12), control: P(14.4, 11.6))
                    p.addQuadCurve(to: P(13, 13), control: P(14.4, 12.4))
                    p.addQuadCurve(to: P(12, 20), control: P(12.4, 14.4))
                    p.addQuadCurve(to: P(11, 13), control: P(11.6, 14.4))
                    p.addQuadCurve(to: P(4, 12), control: P(9.6, 12.4))
                    p.addQuadCurve(to: P(11, 11), control: P(9.6, 11.6))
                    p.addQuadCurve(to: P(12, 4), control: P(11.6, 9.6))
                }

            case .basket:
                stroke { p in
                    p.move(to: P(5, 9)); p.addLine(to: P(19, 9))
                    p.addLine(to: P(17.5, 19)); p.addLine(to: P(6.5, 19)); p.closeSubpath()
                }
                stroke { p in
                    p.move(to: P(8.5, 9)); p.addLine(to: P(11, 4.5))
                    p.move(to: P(15.5, 9)); p.addLine(to: P(13, 4.5))
                }
                stroke { p in
                    p.move(to: P(10, 12)); p.addLine(to: P(10.4, 16))
                    p.move(to: P(14, 12)); p.addLine(to: P(13.6, 16))
                }

            case .globe:
                ellipse(4, 4, 16, 16)
                ellipse(8.5, 4, 7, 16)
                stroke { p in
                    p.move(to: P(4.6, 9)); p.addLine(to: P(19.4, 9))
                    p.move(to: P(4.6, 15)); p.addLine(to: P(19.4, 15))
                }

            case .pizza:
                // A slice pointing down with a crust arc and topping dots.
                stroke { p in
                    p.move(to: P(5, 7)); p.addLine(to: P(12, 20.5)); p.addLine(to: P(19, 7))
                }
                stroke { p in
                    p.move(to: P(5, 7))
                    p.addQuadCurve(to: P(19, 7), control: P(12, 3.5))
                }
                dot(10, 9.5, 1.2)
                dot(14.3, 10.5, 1.2)
                dot(11.8, 14, 1.2)

            case .croissant:
                // Horizontal crescent with segment creases and downturned tips.
                stroke { p in
                    p.move(to: P(4, 15))
                    p.addQuadCurve(to: P(20, 15), control: P(12, 3))
                    p.addQuadCurve(to: P(4, 15), control: P(12, 10.5))
                }
                stroke { p in
                    p.move(to: P(8.6, 7.8)); p.addLine(to: P(9.2, 12.6))
                    p.move(to: P(15.4, 7.8)); p.addLine(to: P(14.8, 12.6))
                }
                stroke { p in
                    p.move(to: P(4, 15)); p.addQuadCurve(to: P(5.2, 18), control: P(3.8, 17))
                    p.move(to: P(20, 15)); p.addQuadCurve(to: P(18.8, 18), control: P(20.2, 17))
                }

            case .oliveBranch:
                stroke { p in
                    p.move(to: P(5, 19))
                    p.addQuadCurve(to: P(19, 5), control: P(9, 9))
                }
                fill { p in
                    p.move(to: P(10, 12.5))
                    p.addQuadCurve(to: P(5.5, 12), control: P(7, 14.5))
                    p.addQuadCurve(to: P(10, 12.5), control: P(7.5, 10.5))
                }
                fill { p in
                    p.move(to: P(13.5, 9))
                    p.addQuadCurve(to: P(12, 4.5), control: P(11.5, 7.5))
                    p.addQuadCurve(to: P(13.5, 9), control: P(14.5, 6.5))
                }
                dot(15.5, 12.5, 1.7)
                dot(18.5, 9.8, 1.4)

            case .chili:
                // Curved pepper body with a little stem.
                stroke { p in
                    p.move(to: P(15.5, 6.5))
                    p.addQuadCurve(to: P(6, 18.5), control: P(16.5, 15.5))
                    p.addQuadCurve(to: P(12.5, 8), control: P(9.5, 12))
                    p.addQuadCurve(to: P(15.5, 6.5), control: P(13.8, 6.6))
                }
                stroke { p in
                    p.move(to: P(15.5, 6.5))
                    p.addQuadCurve(to: P(18.5, 4), control: P(15.8, 4.2))
                }

            case .burger:
                stroke { p in
                    p.move(to: P(4.5, 10))
                    p.addQuadCurve(to: P(19.5, 10), control: P(12, 3.5))
                }
                stroke { p in p.move(to: P(4.5, 13)); p.addLine(to: P(19.5, 13)) }
                stroke { p in
                    p.move(to: P(4.5, 16))
                    p.addLine(to: P(19.5, 16))
                    p.addQuadCurve(to: P(17.5, 19), control: P(19.5, 19))
                    p.addLine(to: P(6.5, 19))
                    p.addQuadCurve(to: P(4.5, 16), control: P(4.5, 19))
                }
                dot(9, 7.4, 0.8)
                dot(12.5, 6.8, 0.8)
                dot(15.5, 7.6, 0.8)

            case .wok:
                stroke { p in
                    p.move(to: P(5, 11))
                    p.addQuadCurve(to: P(19, 11), control: P(12, 19.5))
                }
                stroke { p in p.move(to: P(3, 11)); p.addLine(to: P(21, 11)) }
                stroke { p in
                    p.move(to: P(9.5, 8)); p.addQuadCurve(to: P(9.5, 4.5), control: P(11, 6))
                    p.move(to: P(14, 8)); p.addQuadCurve(to: P(14, 4.5), control: P(15.5, 6))
                }

            case .mortar:
                stroke { p in
                    p.move(to: P(5, 11))
                    p.addLine(to: P(19, 11))
                    p.addQuadCurve(to: P(14.5, 19), control: P(18.5, 17))
                    p.addLine(to: P(9.5, 19))
                    p.addQuadCurve(to: P(5, 11), control: P(5.5, 17))
                }
                stroke { p in
                    p.move(to: P(9.5, 10.5)); p.addLine(to: P(16.5, 3.5))
                }
                dot(17.2, 3.2, 1.6)

            case .star:
                var pts: [CGPoint] = []
                for i in 0..<10 {
                    let a = Double(i) * .pi / 5 - .pi / 2
                    let r: CGFloat = i % 2 == 0 ? 8.5 : 3.6
                    pts.append(P(12 + r * CGFloat(cos(a)), 12 + r * CGFloat(sin(a))))
                }
                fill { p in p.addLines(pts); p.closeSubpath() }

            case .play:
                ellipse(4, 4, 16, 16)
                fill { p in
                    p.move(to: P(10, 8.2)); p.addLine(to: P(16.2, 12)); p.addLine(to: P(10, 15.8))
                    p.closeSubpath()
                }
            }
        }
        .frame(width: size, height: size)
    }
}
