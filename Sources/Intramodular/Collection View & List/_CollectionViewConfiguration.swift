//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

@usableFromInline
struct _CollectionViewConfiguration {
    @usableFromInline
    var allowsMultipleSelection: Bool = false
    @usableFromInline
    var disableAnimatingDifferences: Bool = false
    #if !os(tvOS)
    @usableFromInline
    var reorderingCadence: UICollectionView.ReorderingCadence = .immediate
    #endif
    @usableFromInline
    var isDragActive: Binding<Bool>? = nil
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
