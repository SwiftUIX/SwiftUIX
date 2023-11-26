//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

struct _DynamicViewContentTraitValues {
    var onDelete: ((IndexSet) -> Void)? = nil
    var onMove: ((IndexSet, Int) -> Void)? = nil
    
    #if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
    var onDrop: (([DragItem], Int) -> Void)? = nil
    private var _collectionViewDropDelegate: Any?
    #if !os(tvOS)
    var collectionViewDropDelegate: CollectionViewDropDelegate? {
        get {
            _collectionViewDropDelegate.flatMap({ $0 as? CollectionViewDropDelegate })
        } set {
            _collectionViewDropDelegate = newValue
        }
    }
    #endif
    #endif
}

// MARK: - Auxiliary

struct _DynamicViewContentTraitValuesEnvironmentKey: EnvironmentKey {
    static let defaultValue = _DynamicViewContentTraitValues()
}

extension EnvironmentValues {
    var _dynamicViewContentTraitValues: _DynamicViewContentTraitValues {
        get {
            self[_DynamicViewContentTraitValuesEnvironmentKey.self]
        } set {
            self[_DynamicViewContentTraitValuesEnvironmentKey.self] = newValue
        }
    }
}
