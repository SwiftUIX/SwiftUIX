//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// An internal structure used to manage cell preferences for `CocoaList` and `CollectionView`.
@usableFromInline
struct _CollectionOrListCellPreferences: Equatable {
    var estimatedCellSize: CGSize? = nil
    var isHighlightable = true
    var allowsCustomLayoutAttributeSizeOverride: Bool = false
}

extension _CollectionOrListCellPreferences {
    /// An internal preference key that defines a list row's preferences.
    struct PreferenceKey: SwiftUI.PreferenceKey {
        static let defaultValue = _CollectionOrListCellPreferences()
        
        static func reduce(value: inout _CollectionOrListCellPreferences, nextValue: () -> _CollectionOrListCellPreferences) {
            value = nextValue()
        }
    }
}

extension View {
    public func customResizableCollectionViewCell() -> some View {
        transformPreference(_CollectionOrListCellPreferences.PreferenceKey.self) { value in
            value.allowsCustomLayoutAttributeSizeOverride = true
        }
    }
    
    public func collectionViewCellHighlightable(_ highlightable: Bool) -> some View {
        transformPreference(_CollectionOrListCellPreferences.PreferenceKey.self) { value in
            value.isHighlightable = highlightable
        }
    }
}
