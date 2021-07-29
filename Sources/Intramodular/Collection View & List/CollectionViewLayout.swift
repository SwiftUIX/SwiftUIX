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
            self[_CollectionViewLayoutEnvironmentKey.self]
        } set {
            self[_CollectionViewLayoutEnvironmentKey.self] = newValue
        }
    }
}

// MARK: - Conformances -

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct FlowCollectionViewLayout: Hashable, CollectionViewLayout {
    public let axes: Axis.Set
    public let minimumLineSpacing: CGFloat?
    public let minimumInteritemSpacing: CGFloat?
    public let sectionInsets: EdgeInsets?
    
    public init(
        _ axes: Axis.Set = .vertical,
        minimumLineSpacing: CGFloat? = nil,
        minimumInteritemSpacing: CGFloat? = nil,
        sectionInsets: EdgeInsets? = nil
    ) {
        self.axes = axes
        self.minimumLineSpacing = minimumLineSpacing
        self.minimumInteritemSpacing = minimumInteritemSpacing
        self.sectionInsets = sectionInsets
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(axes.rawValue)
        hasher.combine(minimumLineSpacing)
        hasher.combine(minimumInteritemSpacing)
        hasher.combine(sectionInsets?.top)
        hasher.combine(sectionInsets?.leading)
        hasher.combine(sectionInsets?.bottom)
        hasher.combine(sectionInsets?.trailing)
    }

    public func _toUICollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        
        if axes == .horizontal {
            layout.scrollDirection = .horizontal
        } else if axes == .vertical {
            layout.scrollDirection = .vertical
        }
                
        if let minimumLineSpacing = minimumLineSpacing {
            layout.minimumLineSpacing = minimumLineSpacing
        }
        
        if let minimumInteritemSpacing = minimumInteritemSpacing {
            layout.minimumInteritemSpacing = minimumInteritemSpacing
        }
        
        if let sectionInsets = sectionInsets {
            layout.sectionInset = .init(sectionInsets)
        }
        
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        layout.itemSize = UICollectionViewFlowLayout.automaticSize
        
        return layout
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

extension UICollectionViewLayout: CollectionViewLayout {
    public func _toUICollectionViewLayout() -> UICollectionViewLayout {
        self
    }
}

#elseif os(macOS)

public struct FlowCollectionViewLayout: Hashable, CollectionViewLayout {
    public init() {
        
    }
    
    public func _toNSCollectionViewLayout() -> NSCollectionViewLayout {
        NSCollectionViewLayout()
    }
}

#endif

#endif
