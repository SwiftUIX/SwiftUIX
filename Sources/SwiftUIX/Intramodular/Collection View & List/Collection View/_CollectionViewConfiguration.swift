//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if (os(iOS) && canImport(CoreTelephony)) || os(tvOS) || targetEnvironment(macCatalyst)

public struct _CollectionViewConfiguration: ExpressibleByNilLiteral {
    public enum UnsafeFlag {
        case cacheCellContentHostingControllers
        case disableCellHostingControllerEmbed
        case ignorePreferredCellLayoutAttributes
        case reuseCellRender
    }
    
    var unsafeFlags = Set<UnsafeFlag>()
    
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

    public init(nilLiteral: ()) {

    }
}

struct _CollectionViewCellOrSupplementaryViewConfiguration<
    ItemType,
    ItemIdentifierType: Hashable,
    SectionType,
    SectionIdentifierType: Hashable
>: Identifiable {
    struct ID: CustomStringConvertible, Hashable {
        let reuseIdentifier: String
        let item: ItemIdentifierType?
        let section: SectionIdentifierType
        
        var description: String {
            "(item: \(item.map(String.init(describing:)) ?? "nil"), section: \(section))"
        }
    }
            
    let reuseIdentifier: String
    let item: ItemType?
    let section: SectionType
    let itemIdentifier: ItemIdentifierType?
    let sectionIdentifier: SectionIdentifierType
    let indexPath: IndexPath
    let makeContent: () -> _CollectionViewItemContent.ResolvedView
    
    var maximumSize: OptionalDimensions?
    
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
>: Equatable {
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
    var content: _CollectionViewItemContent.ResolvedView?
    var contentSize: CGSize?
    var preferredContentSize: CGSize? 
    
    init() {
        
    }
}

// MARK: - Auxiliary

struct _CollectionViewConfigurationEnvironmentKey: EnvironmentKey {
    static let defaultValue: _CollectionViewConfiguration = nil
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
