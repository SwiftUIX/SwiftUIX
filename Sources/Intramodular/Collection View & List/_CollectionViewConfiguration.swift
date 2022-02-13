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
        
        /// A flag that indicates that cell content-hosting controllers should be cached separately, using a priority queue.
        ///
        /// Default caching behavior is to cache up to 100 cell content-hosting controllers.
        /// You can think of this as overriding the default `UICollectionView` reuse strategy.
        public static let cacheCellContentHostingControllers = Self(rawValue: 1 << 0)
        
        /// A flag that indicates that cell content-hosting controllers should not be embedded into the parent `UIViewController` that holds the `UICollectionView`.
        ///
        /// This may be desirable in some cases where embedding the `UIHostingController` causes random issues with the navigation bar.
        public static let disableCellHostingControllerEmbed = Self(rawValue: 1 << 1)
        
        /// A flag that indicates `preferredLayoutAttributesFitting(_:)` should return the layout attributes passed to it (i.e. effectively be a no-op).
        ///
        /// This may be desirable in cases where the height of your cells are guaranteed to remain constant, and you want to avoid an extra expensive layout pass.
        public static let ignorePreferredCellLayoutAttributes = Self(rawValue: 1 << 2)
        
        /// A flag that indicates the cell content container should *not* destroy the SwiftUI identity of the view upon reuse via `View.id(_:)`.
        ///
        /// This may be desirable if your cell's content view hierarchy has a `UIViewRepresentable` or `UIViewControllerRepresentable`. 
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

struct _CollectionViewCellOrSupplementaryViewContent: View {
    private let base: Any
    private let baseAsErasedView: AnyView
    
    var body: some View {
        baseAsErasedView
    }
    
    init<T: View>(_ base: T) {
        self.base = base
        self.baseAsErasedView = base.eraseToAnyView()
    }
    
    func _precomputedDimensionsThatFit(
        in dimensions: OptionalDimensions
    ) -> OptionalDimensions? {
        if let base = base as? _opaque_FrameModifiedContent {
            return base._opaque_frameModifier.dimensionsThatFit(in: dimensions)
        } else {
            return nil
        }
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
    let makeContent: () -> _CollectionViewCellOrSupplementaryViewContent
    
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
    var content: _CollectionViewCellOrSupplementaryViewContent?
    var contentSize: CGSize?
    var preferredContentSize: CGSize? 
    
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
