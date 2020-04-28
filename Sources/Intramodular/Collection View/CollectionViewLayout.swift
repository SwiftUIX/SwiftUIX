//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

/// A set of properties for determining whether to recompute the size of items or their position in the layout.
public protocol CollectionViewLayout {
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    func _toUICollectionViewLayout() -> UICollectionViewLayout
    #elseif os(macOS)
    func _toNSCollectionViewLayout() -> NSCollectionViewLayout
    #endif
}

// MARK: - API -

extension View {
    public func collectionViewLayout(_ layout: CollectionViewLayout) -> some View {
        environment(\.collectionViewLayout, layout)
    }
}

// MARK: - Auxiliary Implementation -

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

// MARK: - Concrete Implementations -

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct CollectionViewFlowLayout: CollectionViewLayout {
    public let uiCollectionViewLayout: UICollectionViewFlowLayout
    
    public init(
        minimumLineSpacing: CGFloat? = nil,
        minimumInteritemSpacing: CGFloat? = nil
    ) {
        self.uiCollectionViewLayout = UICollectionViewFlowLayout().then {
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
    
    public func _toUICollectionViewLayout() -> UICollectionViewLayout {
        uiCollectionViewLayout
    }
}

#elseif os(macOS)

public struct CollectionViewFlowLayout: CollectionViewLayout {
    public let nsCollectionViewLayout: NSCollectionViewLayout
    
    public init() {
        self.nsCollectionViewLayout = NSCollectionViewLayout()
    }
    
    public func _toNSCollectionViewLayout() -> NSCollectionViewLayout {
        nsCollectionViewLayout
    }
}

#endif

#endif
