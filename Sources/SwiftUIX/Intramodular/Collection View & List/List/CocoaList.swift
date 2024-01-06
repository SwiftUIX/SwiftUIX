//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS)

import Swift
import SwiftUI

#if os(macOS)
/// `CocoaList` is a port of `NSTableView` for SwiftUI.
///
/// Use it with the `View.cocoaListItem(id:)` modifier to build a high-performance plain list in SwiftUI.
///
/// Usage:
///
/// ```swift
/// struct ContentView: View {
///     var body: some View {
///         CocoaList {
///             ForEach(0..<100, id: \.self) { index in
///                 Text(verbatim: "Item \(index)")
///                     .cocoaListItem(id: index)
///             }
///         }
///     }
/// }
/// ```
public struct CocoaList<Content: View>: View {
    private let _content: AnyView
    
    var _cocoaListPreferences: _CocoaListPreferences = nil
    
    public init(_content: AnyView) {
        self._content = _content
    }
    
    public var body: some View {
        _content
            .transformEnvironment(\._cocoaListPreferences) {
                $0.mergeInPlace(with: _cocoaListPreferences)
            }
    }
    
    public init(
        @ViewBuilder content: () -> Content
    ) {
        let content = _VariadicViewAdapter(content) { content in
            withEnvironmentValue(\._cocoaListPreferences) { preferences in
                _CocoaList(
                    configuration: _VariadicViewChildren._CocoaListContentAdapter(
                        content.children,
                        preferences: preferences
                    )
                )
            }
        }
        
        self.init(_content: content.eraseToAnyView())
    }
}
#else
extension CocoaList {
    public init<Content: View>(
        @ViewBuilder content: () -> Content
    ) where SectionType == Never, SectionHeader == Never, SectionFooter == Never, ItemType == Never, RowContent == Never, Data == AnyRandomAccessCollection<ListSection<SectionType, ItemType>> {
        fatalError()
    }
}
#endif

#endif

extension View {
    public func cocoaListItem<ID: Hashable>(
        id: ID
    ) -> some View {
        _trait(_CocoaListItemID.self, _CocoaListItemID(id: id))
    }
}

// MARK: - Auxiliary

struct _CocoaListItemID: Hashable {
    let id: AnyHashable
}
