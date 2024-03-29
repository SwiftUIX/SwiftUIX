//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

extension UICollectionView {
    enum ElementKind: String {
        case sectionHeader
        case sectionFooter
        
        var rawValue: String {
            switch self {
                case .sectionHeader:
                    return UICollectionView.elementKindSectionHeader
                case .sectionFooter:
                    return UICollectionView.elementKindSectionFooter
            }
        }
        
        init?(rawValue: String) {
            switch rawValue {
                case UICollectionView.elementKindSectionHeader:
                    self = .sectionHeader
                case UICollectionView.elementKindSectionFooter:
                    self = .sectionFooter
                default:
                    return nil
            }
        }
    }
}

extension UICollectionView {
    /// Deselect all selected items.
    public func _deselectAllItems(animated: Bool = true) {
        indexPathsForSelectedItems?.forEach {
            deselectItem(at: $0, animated: true)
        }
    }
}

#endif
