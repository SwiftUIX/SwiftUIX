//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

struct _CollectionViewConfiguration {
    var allowsMultipleSelection: Bool = false
    var disableAnimatingDifferences: Bool = false
    #if !os(tvOS)
    var reorderingCadence: UICollectionView.ReorderingCadence = .immediate
    #endif
}

// MARK: - Auxiliary Implementation -

struct _CollectionViewConfigurationEnvironmentKey: EnvironmentKey {
    static let defaultValue = _CollectionViewConfiguration()
}

extension EnvironmentValues {
    var _collectionViewConfiguration: _CollectionViewConfiguration {
        get {
            self[_CollectionViewConfigurationEnvironmentKey]
        } set {
            self[_CollectionViewConfigurationEnvironmentKey] = newValue
        }
    }
}

#endif
