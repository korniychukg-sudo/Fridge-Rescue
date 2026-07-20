import SwiftUI
import WebKit

struct LarderWebPanel: UIViewRepresentable {
    let urlString: String

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .always
        webView.isOpaque = true
        webView.backgroundColor = .black
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
        return webView
    }

    // MUST stay empty — never reload on SwiftUI re-renders (infinite reload otherwise).
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

// MARK: - Privacy Policy sheet (Settings)
// Themed wrapper: light chrome, a loading indicator, and an offline fallback with the
// policy text so the sheet is never a blank screen.

enum LarderLoadState { case loading, loaded, failed }

struct LarderPolicySheet: View {
    let urlString: String
    @Environment(\.presentationMode) private var presentationMode
    @State private var loadState: LarderLoadState = .loading

    var body: some View {
        ZStack {
            Kitchen.bg.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Text("Privacy Policy")
                        .font(.kitchenRounded(17, .semibold))
                        .foregroundColor(Kitchen.primaryDk)
                    Spacer()
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        ZStack {
                            Circle().fill(Kitchen.accentSoft)
                            GlyphIcon(glyph: .close, size: 14, color: Kitchen.primary)
                        }
                        .frame(width: 30, height: 30)
                    }
                    .buttonStyle(PressableStyle())
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
                .background(Kitchen.bg)

                ZStack {
                    LarderPolicyWebView(urlString: urlString, state: $loadState)
                        .opacity(loadState == .loaded ? 1 : 0)

                    if loadState == .loading {
                        VStack(spacing: 14) {
                            DotsIndicator()
                            Text("Loading...")
                                .font(.kitchenRounded(14))
                                .foregroundColor(Kitchen.textMuted)
                        }
                    } else if loadState == .failed {
                        offlineFallback
                    }
                }
            }
        }
    }

    private var offlineFallback: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                CardContainer {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Your privacy, in short")
                            .font(.kitchenRounded(17, .semibold))
                            .foregroundColor(Kitchen.text)
                        Text("Fridgeful works fully offline. The ingredients you select and the recipes you save are stored only on this device.")
                            .font(.kitchenRounded(15))
                            .foregroundColor(Kitchen.text)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("The app does not collect personal data, does not use analytics or tracking, does not show ads, and does not create accounts. Removing the app removes all of its data.")
                            .font(.kitchenRounded(15))
                            .foregroundColor(Kitchen.text)
                            .fixedSize(horizontal: false, vertical: true)
                        Text("The full policy page could not be loaded right now. Please check your connection and reopen this screen to view it.")
                            .font(.kitchenRounded(13.5))
                            .foregroundColor(Kitchen.textMuted)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 8)
            .padding(.bottom, 30)
            .frame(maxWidth: Metrics.contentMaxWidth)
            .frame(maxWidth: .infinity)
        }
    }
}

struct LarderPolicyWebView: UIViewRepresentable {
    let urlString: String
    @Binding var state: LarderLoadState

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .always
        webView.isOpaque = true
        webView.backgroundColor = .white
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        } else {
            DispatchQueue.main.async { state = .failed }
        }
        return webView
    }

    // MUST stay empty — never reload on SwiftUI re-renders.
    func updateUIView(_ uiView: WKWebView, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(state: $state) }

    final class Coordinator: NSObject, WKNavigationDelegate {
        var state: Binding<LarderLoadState>
        init(state: Binding<LarderLoadState>) { self.state = state }
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            state.wrappedValue = .loaded
        }
        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            state.wrappedValue = .failed
        }
        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            state.wrappedValue = .failed
        }
    }
}
