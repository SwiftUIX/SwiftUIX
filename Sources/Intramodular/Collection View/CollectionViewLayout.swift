//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

/// A set of properties for determining whether to recompute the size of items or their position in the layout.
public protocol CollectionViewLayout {
    var hashValue: Int { get }
    
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
    static let defaultValue: CollectionViewLayout = FlowCollectionViewLayout()
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

// MARK: - Conformances -

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct FlowCollectionViewLayout: Hashable, CollectionViewLayout {
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

extension UICollectionViewLayout: CollectionViewLayout {
    public func _toUICollectionViewLayout() -> UICollectionViewLayout {
        self
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
