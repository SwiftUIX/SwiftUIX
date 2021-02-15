//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// An internal structure used to manage cell preferences for `CocoaList` and `CollectionView`.
@usableFromInline
struct _ListRowPreferences: Equatable {
    var estimatedCellSize: CGSize? = nil
    var isHighlightable = true
}

/// An internal preference key that defines a list row's preferences.
struct _ListRowPreferencesKey: PreferenceKey {
    static let defaultValue = _ListRowPreferences()
    
    static func reduce(value: inout _ListRowPreferences, nextValue: () -> _ListRowPreferences) {
        value = nextValue()
    }
}
