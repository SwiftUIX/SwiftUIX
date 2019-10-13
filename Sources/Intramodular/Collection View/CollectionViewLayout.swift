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

// MARK: - Implementations -

public struct CollectionViewFlowLayout: CollectionViewLayout {
    public let minimumLineSpacing: CGFloat
    public let minimumInteritemSpacing: CGFloat
    
    public init(
        minimumLineSpacing: CGFloat = 10,
        minimumInteritemSpacing: CGFloat = 10
    ) {
        self.minimumLineSpacing = minimumLineSpacing
        self.minimumInteritemSpacing = minimumInteritemSpacing
    }
    
    public func _toUICollectionViewLayout() -> UICollectionViewLayout {
        UICollectionViewFlowLayout().then {
            $0.minimumLineSpacing = minimumLineSpacing
            $0.minimumInteritemSpacing = minimumInteritemSpacing
            $0.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            $0.itemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
}

#endif
