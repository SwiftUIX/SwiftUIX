//
// Copyright (c) Vatsal Manot
//

#if (os(iOS) && canImport(CoreTelephony)) || os(tvOS) || targetEnvironment(macCatalyst)

import SwiftUI
@testable import SwiftUIX
import XCTest

@MainActor
final class PaginationViewTests: XCTestCase {
    func testDeletingAPagePreservesCurrentPageOffset() throws {
        let pageViewController = UIHostingPageViewController<Text>(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )
        
        pageViewController.content = makeContent([0, 1, 2])
        
        let secondPageIndex = pageViewController.content!.data.index(
            pageViewController.content!.data.startIndex,
            offsetBy: 1
        )
        let secondPage = try XCTUnwrap(pageViewController.viewController(for: secondPageIndex))
        
        pageViewController.setViewControllers([secondPage], direction: .forward, animated: false)
        pageViewController.content = makeContent([0, 2])
        
        XCTAssertEqual(pageViewController.currentPageIndexOffset, 1)
    }
    
    private func makeContent(_ pages: [Int]) -> AnyForEach<Text> {
        AnyForEach(pages, id: \.self) { page in
            Text("Page \(page)")
        }
    }
}

#endif
