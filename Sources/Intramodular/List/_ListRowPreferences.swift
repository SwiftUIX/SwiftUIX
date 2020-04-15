//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// An internal structure used to manage cell preferences for `CocoaList` and `CollectionView`.
struct _ListRowPreferences: Equatable {
    var estimatedCellSize: CGSize? = nil
    
    var isHighlightable = true
    
    var onSelect: Action?
    var onDeselect: Action?
}

/// An internal preference key that defines a list row's preferences.
struct _ListRowPreferencesKey: PreferenceKey {
    static let defaultValue = _ListRowPreferences()
    
    static func reduce(value: inout _ListRowPreferences, nextValue: () -> _ListRowPreferences) {
        value = nextValue()
    }
}

// MARK: - API -

extension View {
    /// Sets the estimated size for the list row.
    public func estimatedListRowSize(_ estimatedCellSize: CGSize) -> some View {
        transformPreference(_ListRowPreferencesKey.self) { preferences in
            preferences.estimatedCellSize = estimatedCellSize
        }
    }
    
    /// Sets whether the list row is highlightable or not.
    public func listRowHighlightable(_ isHighlightable: Bool) -> some View {
        transformPreference(_ListRowPreferencesKey.self) { preferences in
            preferences.isHighlightable = isHighlightable
        }
    }
    
    /// Returns a version of `self` that will invoke `action` after
    /// recognizing a selection.
    public func onListRowSelect(perform action: @escaping () -> Void) -> some View {
        transformPreference(_ListRowPreferencesKey.self) { preferences in
            preferences.onSelect = .init(action)
        }
    }
    
    /// Returns a version of `self` that will invoke `action` after
    /// recognizing a deselection.
    public func onListRowDeselect(perform action: @escaping () -> Void) -> some View {
        transformPreference(_ListRowPreferencesKey.self) { preferences in
            preferences.onDeselect = .init(action)
        }
    }
}
