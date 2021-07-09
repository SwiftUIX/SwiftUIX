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
        var viewProvider: ParentViewControllerType._SwiftUIType.ViewProvider
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
    
    struct Preferences: Hashable {
        var _collectionOrListCellPreferences = _CollectionOrListCellPreferences()
        var _namedViewDescription: _NamedViewDescription?
        
        var dragItems: [DragItem]?
        var relativeFrame: RelativeFrame?
    }
    
    struct Cache {
        var content: Content?
        var contentSize: CGSize?
        var preferredContentSize: CGSize? {
            didSet {
                if oldValue != preferredContentSize {
                    content = nil
                }
            }
        }
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
    
    var preferences = Preferences() {
        didSet {
            clipsToBounds = preferences._collectionOrListCellPreferences.isClipped
        }
    }
    
    var cache = Cache()
    
    var content: Content {
        if let content = cache.content {
            return content
        } else if let configuration = configuration {
            let content = configuration.viewProvider.rowContent(configuration.section, configuration.item)
            
            self.cache.content = content
            
            updateCollectionCache()
            
            return content
        } else {
            fatalError()
        }
    }
    
    private var contentHostingController: ContentHostingController?
    private weak var parentViewController: ParentViewControllerType?
    
    var _isFocused: Bool? = nil
    
    override var isFocused: Bool {
        get {
            _isFocused ?? super.isFocused
        } set {
            guard newValue != _isFocused else {
                return
            }
            
            _isFocused = newValue
            
            update(disableAnimation: true, forced: false)
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            guard oldValue != isHighlighted else {
                return
            }
            
            update(disableAnimation: true, forced: false)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            guard oldValue != isSelected else {
                return
            }
            
            update(disableAnimation: true, forced: false)
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
                
                if contentHostingController.view.frame.rounded(.up) != contentView.bounds.rounded(.up) {
                    contentHostingController.view.setNeedsLayout()
                    contentHostingController.view.layoutIfNeeded()
                }
            }
        }
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        var targetSize = targetSize
        
        if let maximumSize = configuration?.maximumSize, let dimensions = content._precomputedDimensionsThatFit(in: maximumSize) {
            if let size = CGSize(dimensions), size.fits(targetSize) {
                return size
            } else {
                targetSize = CGSize(dimensions, default: targetSize)
                    .clamped(to: configuration?.maximumSize?.rounded(.down))
            }
        }
        
        guard let contentHostingController = contentHostingController else {
            return .init(width: 1, height: 1)
        }
        
        return contentHostingController.systemLayoutSizeFitting(targetSize)
    }
    
    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        var targetSize = targetSize
        
        if let maximumSize = configuration?.maximumSize, let dimensions = content._precomputedDimensionsThatFit(in: maximumSize) {
            if let size = CGSize(dimensions), size.fits(targetSize) {
                return size
            } else {
                targetSize = CGSize(dimensions, default: targetSize)
                    .clamped(to: configuration?.maximumSize?.rounded(.down))
            }
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
        
        _isFocused = false
        
        super.isHighlighted = false
        super.isSelected = false
    }
    
    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        if let size = cache.preferredContentSize {
            layoutAttributes.size = size
                .rounded(.up)
                .clamped(to: configuration?.maximumSize?.rounded(.down))
            
            return layoutAttributes
        } else if let relativeFrame = preferences.relativeFrame {
            let size = relativeFrame.sizeThatFits(in: layoutAttributes.size)
                .rounded(.up)
                .clamped(to: configuration?.maximumSize?.rounded(.down))
            
            layoutAttributes.size = size
            
            cache.content = nil
            cache.preferredContentSize = size
            
            updateCollectionCache()
            
            update(disableAnimation: true, forced: true)
            
            return layoutAttributes
        } else {
            guard let parentViewController = parentViewController else {
                return layoutAttributes
            }
            
            if !parentViewController.configuration._ignorePreferredCellLayoutAttributes {
                let result = super.preferredLayoutAttributesFitting(layoutAttributes)
                
                if cache.preferredContentSize == nil || result.size != bounds.size {
                    cache.preferredContentSize = result.size
                        .clamped(to: configuration?.maximumSize?.rounded(.down))
                }
                
                updateCollectionCache()
                
                return result
            } else {
                return layoutAttributes
            }
        }
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)

        guard let parentViewController = parentViewController, !parentViewController.configuration._ignorePreferredCellLayoutAttributes else {
            return
        }

        guard let contentHostingController = contentHostingController, let relativeFrame = preferences.relativeFrame else {
            return
        }
        
        if layoutAttributes.size != contentHostingController.view.frame.size {
            self.cache.preferredContentSize = relativeFrame
                .sizeThatFits(in: layoutAttributes.size)
                .rounded(.up)
                .clamped(to: configuration?.maximumSize?.rounded(.down))
            
            contentHostingController.update(
                disableAnimation: true,
                forced: false,
                refresh: false
            )
        }
    }
}

extension UIHostingCollectionViewCell {
    func update(
        disableAnimation: Bool,
        forced: Bool,
        refresh: Bool = false
    ) {
        guard configuration != nil else {
            return
        }
        
        if forced {
            cache.content = nil
        }
        
        if let contentHostingController = contentHostingController {
            contentHostingController.update(
                disableAnimation: disableAnimation,
                forced: forced,
                refresh: refresh
            )
        } else {
            contentHostingController = ContentHostingController(base: self)
        }
    }
    
    func cellWillDisplay(
        inParent parentViewController: ParentViewControllerType?,
        isPrototype: Bool = false
    ) {
        if contentHostingController == nil {
            update(disableAnimation: true, forced: false)
        }
        
        guard let contentHostingController = contentHostingController else {
            assertionFailure()
            
            return
        }
        
        if let parentViewController = parentViewController {
            if contentHostingController.parent == nil {
                contentHostingController.move(toParent: parentViewController, ofCell: self)
                self.parentViewController = parentViewController
                
                updateCollectionCache()
            }
        } else if !isPrototype {
            assertionFailure()
        }
    }
    
    func cellDidEndDisplaying() {
        
    }
    
    func updateCollectionCache() {
        guard let configuration = configuration, let parentViewController = parentViewController else {
            return
        }
        
        parentViewController.cache[preferencesFor: configuration.id] = preferences
        parentViewController.cache.setCellCache(cache, for: configuration.id)
    }
}

// MARK: - Auxiliary Implementation -

extension UIHostingCollectionViewCell {
    private struct RootView: View {
        struct _CellProxyBase: SwiftUIX._CellProxyBase {
            weak var base: UIHostingCollectionViewCell?
            
            var globalFrame: CGRect {
                base?.globalFrame ?? .zero
            }
            
            func invalidateLayout() {
                guard let base = base, let parentViewController = base.parentViewController else {
                    return
                }
                
                base.setNeedsDisplay()
                base.setNeedsLayout()
                
                base.cache.contentSize = nil
                base.cache.preferredContentSize = nil
                
                base.updateCollectionCache()
                
                parentViewController.refresh()
                parentViewController.invalidateLayout()
            }
        }
        
        var _cellProxyBase: _CellProxyBase
        var _collectionViewProxy: CollectionViewProxy
        var content: Content
        var configuration: Configuration?
        var state: State
        var preferences: Binding<Preferences>
        var cache: Cache
        var updateCollectionCache: (() -> Void)
        
        init(base: UIHostingCollectionViewCell) {
            _cellProxyBase = _CellProxyBase(base: base)
            _collectionViewProxy = .init(base.parentViewController)
            content = base.content
            configuration = base.configuration
            state = base.state
            preferences = .init(
                get: { [weak base] in base?.preferences ?? .init() },
                set: { [weak base] in base?.preferences = $0 }
            )
            cache = base.cache
            updateCollectionCache = { [weak base] in base?.updateCollectionCache() }
        }
        
        public var body: some View {
            if let configuration = configuration {
                content
                    .environment(\._cellProxy, .init(base: _cellProxyBase))
                    .environment(\._collectionViewProxy, .init(.constant(_collectionViewProxy)))
                    .transformEnvironment(\._relativeFrameResolvedValues) { value in
                        guard let relativeFrameID = preferences.wrappedValue.relativeFrame?.id else {
                            if let preferredContentSize = cache.preferredContentSize {
                                if value[0] == nil {
                                    value[0] = .init(
                                        width: preferredContentSize.width,
                                        height: preferredContentSize.height
                                    )
                                }
                            }
                            
                            return
                        }
                        
                        guard let preferredContentSize = cache.preferredContentSize else {
                            return
                        }
                        
                        value[relativeFrameID] = .init(
                            width: preferredContentSize.width,
                            height: preferredContentSize.height
                        )
                    }
                    .environment(\.isCellFocused, state.isFocused)
                    .environment(\.isCellHighlighted, state.isHighlighted)
                    .environment(\.isCellSelected, state.isSelected)
                    .onPreferenceChange(_CollectionOrListCellPreferences.PreferenceKey.self) {
                        if preferences._collectionOrListCellPreferences.wrappedValue != $0 {
                            preferences._collectionOrListCellPreferences.wrappedValue = $0
                            
                            updateCollectionCache()
                        }
                    }
                    .onPreferenceChange(_NamedViewDescription.PreferenceKey.self) {
                        if preferences._namedViewDescription.wrappedValue != $0.last {
                            preferences._namedViewDescription.wrappedValue = $0.last
                            
                            updateCollectionCache()
                        }
                    }
                    .onPreferenceChange(DragItem.PreferenceKey.self) {
                        if preferences.dragItems.wrappedValue != $0 {
                            preferences.dragItems.wrappedValue = $0
                            
                            updateCollectionCache()
                        }
                    }
                    .onPreferenceChange(RelativeFrame.PreferenceKey.self) {
                        if preferences.relativeFrame.wrappedValue != $0.last {
                            preferences.relativeFrame.wrappedValue = $0.last
                            
                            updateCollectionCache()
                        }
                    }
                    .edgesIgnoringSafeArea(.all)
                    .id(configuration.id)
            }
        }
    }
    
    private class ContentHostingController: UIHostingController<RootView> {
        weak var base: UIHostingCollectionViewCell?
        
        init(base: UIHostingCollectionViewCell) {
            self.base = base
            
            super.init(rootView: .init(base: base))
            
            view.backgroundColor = nil
            
            update(disableAnimation: true, forced: false, refresh: false)
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
            .rounded(.up)
            .clamped(to: base?.configuration?.maximumSize?.rounded(.down))
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
            .rounded(.up)
            .clamped(to: base?.configuration?.maximumSize?.rounded(.down))
        }
        
        func move(toParent parent: ParentViewControllerType?, ofCell cell: UIHostingCollectionViewCell) {
            if let parent = parent {
                if let existingParent = self.parent, existingParent !== parent {
                    move(toParent: nil, ofCell: cell)
                }
                
                if self.parent == nil {
                    withoutAnimation {
                        let isNavigationBarHidden = parent.navigationController?.isNavigationBarHidden
                        
                        rootView._collectionViewProxy = .init(parent)
                        
                        self.willMove(toParent: parent)
                        parent.addChild(self)
                        cell.contentView.addSubview(view)
                        view.frame = cell.contentView.bounds
                        didMove(toParent: parent)
                        
                        if let isNavigationBarHidden = isNavigationBarHidden, navigationController?.isNavigationBarHidden != isNavigationBarHidden {
                            navigationController?.setNavigationBarHidden(isNavigationBarHidden, animated: false)
                        }
                    }
                } else {
                    assertionFailure()
                }
            } else {
                withoutAnimation {
                    rootView._collectionViewProxy = .init()
                    
                    willMove(toParent: nil)
                    view.removeFromSuperview()
                    removeFromParent()
                }
            }
        }
        
        func update(
            disableAnimation: Bool,
            forced: Bool,
            refresh: Bool
        ) {
            guard let base = base else {
                return
            }
            
            let currentConfiguration = rootView.configuration
            let newConfiguration = base.configuration
            
            if !forced {
                if let currentConfiguration = currentConfiguration, let newConfiguration = newConfiguration {
                    guard currentConfiguration.id != newConfiguration.id || rootView.state != base.state else {
                        if refresh {
                            rootView = .init(base: base)
                        }

                        return
                    }
                }
            }
            
            withoutAnimation(disableAnimation) {
                rootView = .init(base: base)
                
                if forced {
                    view.setNeedsLayout()
                    view.setNeedsDisplay()
                    view.layoutIfNeeded()
                }
            }
        }
    }
}

extension String {
    static let hostingCollectionViewCellIdentifier = "UIHostingCollectionViewCell"
}

#endif
