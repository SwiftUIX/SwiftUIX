//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct _CollectionViewConfiguration {
    public struct UnsafeFlags: OptionSet {
        public let rawValue: Int
        
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        
        public static let disableCellHostingControllerEmbed = Self(rawValue: 1 << 0)
        public static let ignorePreferredCellLayoutAttributes = Self(rawValue: 1 << 1)
        public static let reuseCellRender = Self(rawValue: 1 << 2)
    }
    
    var unsafeFlags = UnsafeFlags()
    
    var fixedSize: (vertical: Bool, horizontal: Bool) = (false, false)
    var allowsMultipleSelection: Bool = false
    var disableAnimatingDifferences: Bool = false
    #if !os(tvOS)
    var reorderingCadence: UICollectionView.ReorderingCadence = .immediate
    #endif
    var isDragActive: Binding<Bool>? = nil
    var dataSourceUpdateToken: AnyHashable?
    
    var ignorePreferredCellLayoutAttributes: Bool {
        unsafeFlags.contains(.ignorePreferredCellLayoutAttributes)
    }
}

// MARK: - Auxiliary Implementation -

struct _CollectionViewConfigurationEnvironmentKey: EnvironmentKey {
    static let defaultValue = _CollectionViewConfiguration()
}

extension EnvironmentValues {
    var _collectionViewConfiguration: _CollectionViewConfiguration {
        get {
            self[_CollectionViewConfigurationEnvironmentKey.self]
        } set {
            self[_CollectionViewConfigurationEnvironmentKey.self] = newValue
        }
    }
}

#endif
