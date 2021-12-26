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
        
        public static let cacheCellContentHostingControllers = Self(rawValue: 1 << 0)
        public static let disableCellHostingControllerEmbed = Self(rawValue: 1 << 1)
        public static let ignorePreferredCellLayoutAttributes = Self(rawValue: 1 << 2)
        public static let reuseCellRender = Self(rawValue: 1 << 3)
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

struct _CollectionViewCellOrSupplementaryViewConfiguration<
    ItemType,
    ItemIdentifierType: Hashable,
    SectionType,
    SectionIdentifierType: Hashable
>: Identifiable {
    struct ID: Hashable {
        let reuseIdentifier: String
        let item: ItemIdentifierType?
        let section: SectionIdentifierType
    }
        
    let reuseIdentifier: String
    let item: ItemType?
    let section: SectionType
    let itemIdentifier: ItemIdentifierType?
    let sectionIdentifier: SectionIdentifierType
    let indexPath: IndexPath
    var makeContent: () -> AnyView
    let maximumSize: OptionalDimensions?
    
    var id: ID {
        .init(reuseIdentifier: reuseIdentifier, item: itemIdentifier, section: sectionIdentifier)
    }
    
    var collectionViewElementKind: String? {
        switch reuseIdentifier {
            case .hostingCollectionViewHeaderSupplementaryViewIdentifier:
                return UICollectionView.elementKindSectionHeader
            case .hostingCollectionViewCellIdentifier:
                return nil
            case .hostingTableViewFooterViewIdentifier:
                return UICollectionView.elementKindSectionFooter
            default:
                return nil
        }
    }
}

struct _CollectionViewCellOrSupplementaryViewState<
    ItemType,
    ItemIdentifierType: Hashable,
    SectionType,
    SectionIdentifierType: Hashable
>: Hashable {
    let isFocused: Bool
    let isHighlighted: Bool
    let isSelected: Bool
}

struct _CollectionViewCellOrSupplementaryViewPreferences<
    ItemType,
    ItemIdentifierType: Hashable,
    SectionType,
    SectionIdentifierType: Hashable
> {
    var _collectionOrListCellPreferences = _CollectionOrListCellPreferences()
    var dragItems: [DragItem]?
    var relativeFrame: RelativeFrame?
}

struct _CollectionViewCellOrSupplementaryViewCache<
    ItemType,
    ItemIdentifierType: Hashable,
    SectionType,
    SectionIdentifierType: Hashable
> {
    var content: AnyView?
    var contentSize: CGSize?
    var preferredContentSize: CGSize? {
        didSet {
            if oldValue != preferredContentSize {
                content = nil
            }
        }
    }
    
    init() {
        
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
