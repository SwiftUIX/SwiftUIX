//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

#if canImport(UIKit)

public protocol CollectionViewLayout {
    func _toUICollectionViewLayout() -> UICollectionViewLayout
}

// MARK: - Implementations -

public struct CollectionViewFlowLayout: CollectionViewLayout {
    public init() {
        
    }
    
    public func _toUICollectionViewLayout() -> UICollectionViewLayout {
        UICollectionViewFlowLayout().then {
            $0.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
            $0.itemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
}

#endif
