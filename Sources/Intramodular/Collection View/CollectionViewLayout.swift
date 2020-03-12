//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public protocol CollectionViewLayout {
    func _toUICollectionViewLayout() -> UICollectionViewLayout
}

private struct _CollectionViewLayoutEnvironmentKey: EnvironmentKey {
    static let defaultValue: CollectionViewLayout = CollectionViewFlowLayout()
}

extension EnvironmentValues {
    var collectionViewLayout: CollectionViewLayout {
        get {
            self[_CollectionViewLayoutEnvironmentKey]
        } set {
            self[_CollectionViewLayoutEnvironmentKey] = newValue
        }
    }
}

// MARK: - API -

extension View {
    public func collectionViewLayout(_ layout: CollectionViewLayout) -> some View {
        environment(\.collectionViewLayout, layout)
    }
}

// MARK: - Concrete Implementations -

public struct CollectionViewFlowLayout: CollectionViewLayout {
    public let minimumLineSpacing: CGFloat?
    public let minimumInteritemSpacing: CGFloat?
    
    public init(
        minimumLineSpacing: CGFloat? = nil,
        minimumInteritemSpacing: CGFloat? = nil
    ) {
        self.minimumLineSpacing = minimumLineSpacing
        self.minimumInteritemSpacing = minimumInteritemSpacing
    }
    
    public func _toUICollectionViewLayout() -> UICollectionViewLayout {
        UICollectionViewFlowLayout().then {
            if let minimumLineSpacing = minimumLineSpacing {
                $0.minimumLineSpacing = minimumLineSpacing
            }
            
            if let minimumInteritemSpacing = minimumInteritemSpacing {
                $0.minimumInteritemSpacing = minimumInteritemSpacing
            }
            
            $0.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            $0.itemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
}

#endif
