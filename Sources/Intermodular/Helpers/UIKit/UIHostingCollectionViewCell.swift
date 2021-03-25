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
        let section: SectionType
        let itemIdentifier: ItemIdentifierType
        let sectionIdentifier: SectionIdentifierType
        let indexPath: IndexPath
        let makeContent: (SectionType, ItemType) -> Content
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
            
            update()
        }
    }
    
    var state: State {
        .init(
            isFocused: _isFocused ?? super.isFocused,
            isHighlighted: isHighlighted,
            isSelected: isSelected
        )
    }
    
    private var contentHostingController: ContentHostingController?
    private var preferredContentSize: CGSize?
    
    private weak var parentViewController: ParentViewControllerType?
    
    var preferences = Preferences() {
        didSet {
            guard let configuration = configuration, let parentViewController = parentViewController else {
                return
            }
            
            parentViewController.cache[preferencesFor: configuration.id] = preferences
        }
    }
    
    var _isFocused: Bool? = nil {
        didSet {
            guard oldValue != _isFocused else {
                return
            }
            
            update()
        }
    }
    
    override var isFocused: Bool {
        _isFocused ?? super.isFocused
    }
    
    override var isHighlighted: Bool {
        didSet {
            guard oldValue != isHighlighted else {
                return
            }
            
            update()
        }
    }
    
    override var isSelected: Bool {
        didSet {
            guard oldValue != isSelected else {
                return
            }
            
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
                contentHostingController.view.layoutIfNeeded()
            }
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
        return layoutAttributes
    }
}

extension UIHostingCollectionViewCell {
    func cellWillDisplay(
        inParent parentViewController: ParentViewControllerType?,
        isPrototype: Bool = false
    ) {
        guard let contentHostingController = contentHostingController else {
            assertionFailure()
            
            return
        }
        
        defer {
            self.parentViewController = parentViewController
        }
        
        if let parentViewController = parentViewController {
            if contentHostingController.parent == nil {
                contentHostingController.move(toParent: parentViewController, ofCell: self)
            }
        } else if !isPrototype {
            assertionFailure()
        }
    }
    
    func cellDidEndDisplaying() {
        
    }
    
    func update(forced: Bool = false) {
        if let contentHostingController = contentHostingController {
            contentHostingController.update()
        } else {
            contentHostingController = ContentHostingController(base: self)
        }
    }
}

// MARK: - Auxiliary Implementation -

extension UIHostingCollectionViewCell {
    private struct RootView: ExpressibleByNilLiteral, View {
        var dummy: Bool = false
        
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
                configuration.makeContent(configuration.section, configuration.item)
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
                    .edgesIgnoringSafeArea(.all)
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
        
        func update(forced: Bool = false) {
            guard let base = base else {
                return
            }
            
            if !forced {
                if let currentConfiguration = mainView.configuration, let newConfiguration = base.configuration {
                    guard currentConfiguration.id != newConfiguration.id || mainView.state != base.state else {
                        return
                    }
                }
            }
            
            mainView = .init(base: base)
            
            if forced {
                mainView.dummy.toggle()
            }
        }
    }
}

extension String {
    static let hostingCollectionViewCellIdentifier = "UIHostingCollectionViewCell"
}

#endif
