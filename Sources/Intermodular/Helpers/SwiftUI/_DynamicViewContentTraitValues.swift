//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

struct _DynamicViewContentTraitValues {
    var onDelete: ((IndexSet) -> Void)? = nil
    var onMove: ((IndexSet, Int) -> Void)? = nil
    
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    var onDrop: (([DragItem], Int) -> Void)? = nil
    @available(tvOS, unavailable)
    var collectionViewDropDelegate: CollectionViewDropDelegate?
    #endif
}

// MARK: - Auxiliary Implementation -

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
