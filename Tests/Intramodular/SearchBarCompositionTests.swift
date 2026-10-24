//
// Copyright (c) Vatsal Manot
//

#if os(macOS)
import AppKit
import SwiftUI
import XCTest
@testable import SwiftUIX

final class SearchBarCompositionTests: XCTestCase {
    @MainActor
    func testUpdatePreservesActiveMarkedText() async throws {
        _ = NSApplication.shared
        var text = ""
        let binding = Binding(get: { text }, set: { text = $0 })
        let host = NSHostingView(rootView: SearchBar(text: binding))
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 100),
            styleMask: [.titled],
            backing: .buffered,
            defer: false
        )
        window.isReleasedWhenClosed = false
        window.contentView = host
        defer { window.close() }
        host.layoutSubtreeIfNeeded()

        func searchField(in view: NSView) -> NSSearchField? {
            if let field = view as? NSSearchField { return field }
            return view.subviews.lazy.compactMap { searchField(in: $0) }.first
        }

        let field = try XCTUnwrap(searchField(in: host))
        window.makeFirstResponder(field)
        field.selectText(nil)
        let editor = try XCTUnwrap(field.currentEditor() as? NSTextView)
        editor.setMarkedText(
            "ni",
            selectedRange: NSRange(location: 2, length: 0),
            replacementRange: NSRange(location: NSNotFound, length: 0)
        )
        XCTAssertTrue(editor.hasMarkedText())

        text = "n"
        host.rootView = SearchBar(text: binding)
        host.layoutSubtreeIfNeeded()
        let updated = expectation(description: "SwiftUI update completed")
        DispatchQueue.main.async { updated.fulfill() }
        await fulfillment(of: [updated], timeout: 2)

        XCTAssertTrue(editor.hasMarkedText())
        XCTAssertEqual(editor.string, "ni")
        XCTAssertTrue(window.firstResponder === editor)

        editor.unmarkText()
        text = "committed"
        host.rootView = SearchBar("After composition", text: binding)
        host.layoutSubtreeIfNeeded()
        let committed = expectation(description: "Unmarked text update completed")
        DispatchQueue.main.async { committed.fulfill() }
        await fulfillment(of: [committed], timeout: 2)
        XCTAssertEqual(field.stringValue, "committed")
    }
}
#endif
