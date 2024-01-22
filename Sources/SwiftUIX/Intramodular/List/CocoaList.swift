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
    private let _content: (Self) -> AnyView
    
    var _cocoaListPreferences: _CocoaListPreferences = nil
    
    public init<V: View>(_content: @escaping (Self) -> V) {
        self._content = { _content($0).eraseToAnyView() }
    }
    
    public var body: some View {
        _content(self)
            .transformEnvironment(\._cocoaListPreferences) {
                $0.mergeInPlace(with: _cocoaListPreferences)
            }
    }
    
    public init(
        @ViewBuilder content: () -> Content
    ) {
        let content = content()
        
        self.init(_content: { representable in
            _VariadicViewAdapter(content) { content in
                withEnvironmentValue(\._cocoaListPreferences) { preferences in                    
                    return _CocoaList(
                        configuration: _VariadicViewChildren._CocoaListContentAdapter(
                            content.children,
                            preferences: preferences.mergingInPlace(
                                with: representable._cocoaListPreferences
                            )
                        )
                    )
                }
            }
        })
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
 
public struct _CocoaListItemID: Hashable {
    public let id: AnyHashable
}
