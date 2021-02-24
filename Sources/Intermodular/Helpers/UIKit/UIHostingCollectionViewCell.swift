//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension UIHostingCollectionViewCell {
    struct Configuration: Identifiable {
        struct ID: Hashable {
            let item: ItemIdentifierType
            let section: AnyHashable
        }
        
        let item: ItemType
        let itemIdentifier: ItemIdentifierType
        let sectionIdentifier: SectionIdentifierType
        let indexPath: IndexPath
        let makeContent: (ItemType) -> Content
        let maximumSize: OptionalDimensions?
        
        var id: ID {
            .init(item: itemIdentifier, section: sectionIdentifier)
        }
    }
    
    struct State: Hashable {
        let isFocused: Bool
        let isHighlighted: Bool
        let isSelected: Bool
    }
    
    struct PreferenceValues {
        var _collectionOrListCellPreferences = _CollectionOrListCellPreferences()
        var _namedViewDescription: _NamedViewDescription?
        
        var preferredCellLayoutAttributesSize: CGSize?
    }
}

class UIHostingCollectionViewCell<
    SectionType,
    SectionIdentifierType: Hashable,
    ItemType,
    ItemIdentifierType: Hashable,
    SectionHeaderContent: View,
    SectionFooterContent: View,
    Content: View
>: UICollectionViewCell {
    typealias ParentViewControllerType = UIHostingCollectionViewController<
        SectionType,
        SectionIdentifierType,
        ItemType,
        ItemIdentifierType,
        SectionHeaderContent,
        SectionFooterContent,
        Content
    >
    
    var configuration: Configuration? {
        didSet {
            if oldValue?.id != configuration?.id {
                preferenceValues = .init()
            }
        }
    }
    
    var state: State {
        .init(
            isFocused: isFocused,
            isHighlighted: isHighlighted,
            isSelected: isSelected
        )
    }
    
    private var contentHostingController: ContentHostingController?
    private var parentViewController: ParentViewControllerType?
    private var preferenceValues = PreferenceValues() {
        didSet {
            guard let configuration = configuration, let parentViewController = parentViewController else {
                return
            }
            
            parentViewController.cellMetadataCache[section: configuration.sectionIdentifier, item: configuration.itemIdentifier] = preferenceValues
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            update()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            update()
        }
    }
    
    var isFocusable: Bool {
        preferenceValues._collectionOrListCellPreferences.isFocusable
    }
    
    var isHighlightable: Bool {
        preferenceValues._collectionOrListCellPreferences.isHighlightable
    }
    
    var isReorderable: Bool {
        preferenceValues._collectionOrListCellPreferences.isReorderable
    }
    
    var isSelectable: Bool {
        preferenceValues._collectionOrListCellPreferences.isSelectable
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        backgroundView = .init()
        contentView.backgroundColor = .clear
        contentView.bounds.origin = .zero
        layoutMargins = .zero
        selectedBackgroundView = .init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if let contentHostingController = contentHostingController {
            if contentHostingController.view.frame != contentView.bounds {
                contentHostingController.view.frame = contentView.bounds
                contentHostingController.view.setNeedsLayout()
            }
            
            contentHostingController.view.layoutIfNeeded()
        }
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .required
        )
    }
    
    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        contentHostingController?.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: verticalFittingPriority
        ) ?? CGSize(width: 1, height: 1)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        systemLayoutSizeFitting(size)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        isHighlighted = false
        isSelected = false
    }
    
    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        if let preferredLayoutAttributesSize = preferenceValues.preferredCellLayoutAttributesSize {
            layoutAttributes.size = preferredLayoutAttributesSize
        } else {
            layoutAttributes.size = systemLayoutSizeFitting(layoutAttributes.size)
            
            preferenceValues.preferredCellLayoutAttributesSize = layoutAttributes.size
        }
        
        return layoutAttributes
    }
}

extension UIHostingCollectionViewCell {
    func cellWillDisplay(inParent parentViewController: ParentViewControllerType?, isPrototype: Bool = false) {
        defer {
            self.parentViewController = parentViewController
        }
        
        if let contentHostingController = contentHostingController {
            contentHostingController.update()
        } else {
            contentHostingController = ContentHostingController(base: self)
        }
        
        if let parentViewController = parentViewController {
            if contentHostingController?.parent == nil {
                contentHostingController?.move(toParent: parentViewController, ofCell: self)
            }
        } else if !isPrototype {
            assertionFailure()
        }
    }
    
    func cellDidEndDisplaying() {
        defer {
            self.parentViewController = nil
        }
        
        contentHostingController?.move(toParent: nil, ofCell: self)
    }
    
    func update() {
        contentHostingController?.update()
    }
}

// MARK: - Auxiliary Implementation -

extension UIHostingCollectionViewCell {
    private struct RootView: ExpressibleByNilLiteral, View {
        var configuration: Configuration?
        var state: State?
        var preferenceValues: Binding<PreferenceValues>?
        
        init(base: UIHostingCollectionViewCell?) {
            configuration = base?.configuration
            state = base?.state
            preferenceValues = .init(get: { [weak base] in base?.preferenceValues ?? .init() }, set: { [weak base] in base?.preferenceValues = $0 })
        }
        
        public init(nilLiteral: ()) {
            
        }
        
        public var body: some View {
            if let configuration = configuration, let state = state, let preferenceValues = preferenceValues {
                configuration
                    .makeContent(configuration.item)
                    .environment(\.isCellFocused, state.isFocused)
                    .environment(\.isCellHighlighted, state.isHighlighted)
                    .environment(\.isCellSelected, state.isSelected)
                    .edgesIgnoringSafeArea(.all)
                    .onPreferenceChange(_CollectionOrListCellPreferences.PreferenceKey.self, perform: { preferenceValues._collectionOrListCellPreferences.wrappedValue = $0 })
                    .onPreferenceChange(_NamedViewDescription.PreferenceKey.self, perform: { preferenceValues._namedViewDescription.wrappedValue = $0.last })
                    .id(configuration.id)
            }
        }
    }
    
    private class ContentHostingController: CocoaHostingController<RootView> {
        weak var base: UIHostingCollectionViewCell?
        
        init(base: UIHostingCollectionViewCell?) {
            self.base = base
            
            super.init(mainView: nil)
            
            update()
        }
        
        @objc required public init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        public func systemLayoutSizeFitting(
            _ targetSize: CGSize
        ) -> CGSize {
            _fixed_sizeThatFits(
                in: .init(targetSize),
                maximumSize: base?.configuration?.maximumSize ?? nil
            )
        }
        
        public func systemLayoutSizeFitting(
            _ targetSize: CGSize,
            withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
            verticalFittingPriority: UILayoutPriority
        ) -> CGSize {
            _fixed_sizeThatFits(
                in: .init(targetSize),
                maximumSize: base?.configuration?.maximumSize ?? nil
            )
        }
        
        func move(toParent parent: _opaque_UIHostingCollectionViewController?, ofCell cell: UIHostingCollectionViewCell) {
            if let parent = parent {
                if let existingParent = self.parent, existingParent !== parent {
                    move(toParent: nil, ofCell: cell)
                }
                
                if self.parent == nil {
                    self.willMove(toParent: parent)
                    parent.addChild(self)
                    cell.contentView.addSubview(view)
                    view.frame = cell.contentView.bounds
                    didMove(toParent: parent)
                } else {
                    assertionFailure()
                }
            } else {
                willMove(toParent: nil)
                view.removeFromSuperview()
                removeFromParent()
            }
        }
        
        func update() {
            rootView.content = .init(base: base)
            
            view.setNeedsDisplay()
        }
    }
}

extension String {
    static let hostingCollectionViewCellIdentifier = "UIHostingCollectionViewCell"
}

#endif
