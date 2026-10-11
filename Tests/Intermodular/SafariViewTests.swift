#if (os(iOS) && canImport(CoreTelephony)) || targetEnvironment(macCatalyst)

import SafariServices
import SwiftUI
import SwiftUIX
import XCTest

@MainActor
final class SafariViewTests: XCTestCase {
    private let url = URL(string: "https://example.invalid")!

    func testOnFinish() throws {
        var finishCount = 0
        let view = SafariView(url: url).onFinish {
            finishCount += 1
        }

        try withSafariViewController(view) { controller in
            controller.delegate?.safariViewControllerDidFinish?(controller)

            XCTAssertEqual(finishCount, 1)
        }
    }

    func testOnCompletingInitialLoad() throws {
        var results: [Bool] = []
        let view = SafariView(url: url).onCompletingInitialLoad {
            results.append($0)
        }

        try withSafariViewController(view) { controller in
            controller.delegate?.safariViewController?(controller, didCompleteInitialLoad: true)
            controller.delegate?.safariViewController?(controller, didCompleteInitialLoad: false)

            XCTAssertEqual(results, [true, false])
        }
    }

    func testOnInitialLoadRedirect() throws {
        let redirectedURL = try XCTUnwrap(URL(string: "https://example.invalid/redirected"))
        var redirects: [URL] = []
        let view = SafariView(url: url).onInitialLoadRedirect {
            redirects.append($0)
        }

        try withSafariViewController(view) { controller in
            controller.delegate?.safariViewController?(controller, initialLoadDidRedirectTo: redirectedURL)

            XCTAssertEqual(redirects, [redirectedURL])
        }
    }

    private func withSafariViewController(
        _ view: SafariView,
        perform: (SFSafariViewController) throws -> Void
    ) throws {
        let hostingController = UIHostingController(rootView: view)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        window.rootViewController = hostingController
        window.isHidden = false

        defer {
            window.isHidden = true
            window.rootViewController = nil
        }

        hostingController.view.layoutIfNeeded()

        let controller = try XCTUnwrap(safariViewController(in: hostingController))

        try perform(controller)
    }

    private func safariViewController(in controller: UIViewController) -> SFSafariViewController? {
        if let controller = controller as? SFSafariViewController {
            return controller
        }

        for child in controller.children {
            if let controller = safariViewController(in: child) {
                return controller
            }
        }

        return nil
    }
}

#endif
