//
// Copyright (c) Vatsal Manot
//

#if canImport(UIKit)
import SwiftUIX
import SwiftUI
import UIKit
import XCTest

@MainActor
final class FlowCollectionViewLayoutTests: XCTestCase {
    func testHorizontalLayoutUsesHorizontalScrollDirection() {
        let layout = FlowCollectionViewLayout(.horizontal)._toUICollectionViewLayout()

        XCTAssertEqual((layout as? UICollectionViewFlowLayout)?.scrollDirection, .horizontal)
    }

    func testVerticalLayoutUsesVerticalScrollDirection() {
        let layout = FlowCollectionViewLayout(.vertical)._toUICollectionViewLayout()

        XCTAssertEqual((layout as? UICollectionViewFlowLayout)?.scrollDirection, .vertical)
    }

    func testExplicitHorizontalLayoutOverridesTheDefaultVerticalScrollConfiguration() {
        let rootView = CollectionView([1, 2], id: \.self) { item in
            Text("Item \(item)")
        }
        .collectionViewLayout(FlowCollectionViewLayout(.horizontal))
        let hostingController = UIHostingController(rootView: rootView)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 320, height: 80))

        window.rootViewController = hostingController
        window.makeKeyAndVisible()
        defer { window.isHidden = true }

        let collectionView = waitForCollectionView(in: hostingController.view)

        XCTAssertNotNil(collectionView)
        XCTAssertEqual((collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection, .horizontal)
    }

    private func waitForCollectionView(in view: UIView) -> UICollectionView? {
        let deadline = Date().addingTimeInterval(1)

        while Date() < deadline {
            if let collectionView = findCollectionView(in: view) {
                return collectionView
            }

            RunLoop.main.run(until: Date().addingTimeInterval(0.01))
        }

        return nil
    }

    private func findCollectionView(in view: UIView) -> UICollectionView? {
        if let collectionView = view as? UICollectionView {
            return collectionView
        }

        for subview in view.subviews {
            if let collectionView = findCollectionView(in: subview) {
                return collectionView
            }
        }

        return nil
    }
}
#endif
