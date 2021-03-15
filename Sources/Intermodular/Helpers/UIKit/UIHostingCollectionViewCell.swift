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
            let section: SectionIdentifierType
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
    
    struct Preferences {
        var _collectionOrListCellPreferences = _CollectionOrListCellPreferences()
        var _namedViewDescription: _NamedViewDescription?
        var relativeFrame: RelativeFrame?
        
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
                preferences = .init()
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
    
    private weak var parentViewController: ParentViewControllerType?
    
    var preferences = Preferences() {
        didSet {
            guard let configuration = configuration, let parentViewController = parentViewController else {
                return
            }
            
            parentViewController.cellMetadataCache[preferencesFor: configuration.id] = preferences
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
        preferences._collectionOrListCellPreferences.isFocusable
    }
    
    var isHighlightable: Bool {
        preferences._collectionOrListCellPreferences.isHighlightable
    }
    
    var isReorderable: Bool {
        preferences._collectionOrListCellPreferences.isReorderable
    }
    
    var isSelectable: Bool {
        preferences._collectionOrListCellPreferences.isSelectable
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
        if let relativeFrame = preferences.relativeFrame {
            return relativeFrame.resolve(in: targetSize)
        }
        
        return contentHostingController?.systemLayoutSizeFitting(targetSize) ?? .init(width: 1, height: 1)
    }
    
    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        if let relativeFrame = preferences.relativeFrame {
            return relativeFrame.resolve(in: targetSize)
        }
        
        guard let contentHostingController = contentHostingController else {
            return .init(width: 1, height: 1)
        }
        
        return contentHostingController.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: horizontalFittingPriority,
            verticalFittingPriority: verticalFittingPriority
        )
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        systemLayoutSizeFitting(size)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        super.isHighlighted = false
        super.isSelected = false
    }
    
    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        if let relativeFrame = preferences.relativeFrame {
            layoutAttributes.size = relativeFrame.resolve(in: layoutAttributes.size)
        } else if let preferredLayoutAttributesSize = preferences.preferredCellLayoutAttributesSize {
            layoutAttributes.size = preferredLayoutAttributesSize
        } else {
            layoutAttributes.size = systemLayoutSizeFitting(layoutAttributes.size)
            
            preferences.preferredCellLayoutAttributesSize = layoutAttributes.size
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
        var preferences: Binding<Preferences>?
        
        init(base: UIHostingCollectionViewCell?) {
            configuration = base?.configuration
            state = base?.state
            preferences = .init(
                get: { [weak base] in base?.preferences ?? .init() },
                set: { [weak base] in base?.preferences = $0 }
            )
        }
        
        public init(nilLiteral: ()) {
            
        }
        
        public var body: some View {
            if let configuration = configuration, let state = state, let preferences = preferences {
                configuration.makeContent(configuration.item)
                    .edgesIgnoringSafeArea(.all)
                    .environment(\.isCellFocused, state.isFocused)
                    .environment(\.isCellHighlighted, state.isHighlighted)
                    .environment(\.isCellSelected, state.isSelected)
                    .onPreferenceChange(_CollectionOrListCellPreferences.PreferenceKey.self) {
                        preferences._collectionOrListCellPreferences.wrappedValue = $0
                    }
                    .onPreferenceChange(_NamedViewDescription.PreferenceKey.self) {
                        preferences._namedViewDescription.wrappedValue = $0.last
                    }
                    .onPreferenceChange(RelativeFrame.PreferenceKey.self) {
                        preferences.relativeFrame.wrappedValue = $0.last
                    }
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
            sizeThatFits(
                in: targetSize,
                withHorizontalFittingPriority: nil,
                verticalFittingPriority: nil
            )
        }
        
        public func systemLayoutSizeFitting(
            _ targetSize: CGSize,
            withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
            verticalFittingPriority: UILayoutPriority
        ) -> CGSize {
            sizeThatFits(
                in: targetSize,
                withHorizontalFittingPriority: horizontalFittingPriority,
                verticalFittingPriority: verticalFittingPriority
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
            guard let base = base else {
                return
            }
            
            if let currentConfiguration = mainView.configuration, let newConfiguration = base.configuration {
                guard currentConfiguration.id != newConfiguration.id else {
                    return
                }
            }
            
            mainView = .init(base: base)
            
            view.setNeedsDisplay()
        }
    }
}

extension String {
    static let hostingCollectionViewCellIdentifier = "UIHostingCollectionViewCell"
}

#endif
