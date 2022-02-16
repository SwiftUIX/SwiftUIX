//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

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
    typealias ContentConfiguration = _CollectionViewCellOrSupplementaryViewConfiguration<ItemType, ItemIdentifierType, SectionType, SectionIdentifierType>
    typealias ContentState = _CollectionViewCellOrSupplementaryViewState<ItemType, ItemIdentifierType, SectionType, SectionIdentifierType>
    typealias ContentPreferences = _CollectionViewCellOrSupplementaryViewPreferences<ItemType, ItemIdentifierType, SectionType, SectionIdentifierType>
    typealias ContentCache = _CollectionViewCellOrSupplementaryViewCache<ItemType, ItemIdentifierType, SectionType, SectionIdentifierType>
    typealias ContentHostingController = CocoaCollectionCellOrSupplementaryViewHostingController<ItemType, ItemIdentifierType, SectionType, SectionIdentifierType>

    var latestRepresentableUpdate: _AppKitOrUIKitViewRepresentableUpdate?
    
    var cellContentConfiguration: ContentConfiguration? {
        didSet {
            let newValue = cellContentConfiguration

            if oldValue?.id != newValue?.id {
                contentPreferences = .init()
            }

            if oldValue?.maximumSize != newValue?.maximumSize {
                contentCache.preferredContentSize = nil
                contentCache.contentSize = nil
            }
        }
    }
    
    var contentState: ContentState {
        .init(
            isFocused: isFocused,
            isHighlighted: isHighlighted,
            isSelected: isSelected
        )
    }
    
    var contentPreferences = ContentPreferences() {
        didSet {
            updateCollectionCache()
        }
    }
    
    var contentCache = ContentCache()
    
    var content: _CollectionViewCellOrSupplementaryViewContent {
        if let content = contentCache.content {
            return content
        } else if let configuration = cellContentConfiguration {
            let content = configuration.makeContent()
            
            self.contentCache.content = content
            
            updateCollectionCache()
            
            return content
        } else {
            fatalError()
        }
    }
    
    var configuration: ContentHostingController.Configuration {
        guard let contentConfiguration = cellContentConfiguration else {
            fatalError()
        }
        
        return .init(
            _reuseCellRender: parentViewController?.configuration.unsafeFlags.contains(.reuseCellRender) ?? false,
            _collectionViewProxy: .init(parentViewController),
            _cellProxyBase: _CellProxyBase(base: self),
            contentConfiguration: contentConfiguration,
            contentState: contentState,
            contentPreferences: .init(
                get: { [weak self] in self?.contentPreferences ?? .init() },
                set: { [weak self] in self?.contentPreferences = $0 }
            ),
            contentCache: contentCache,
            content: content
        )
    }
        
    weak var parentViewController: ParentViewControllerType?

    private var contentHostingController: ContentHostingController?
    private var _isFocused: Bool? = nil
        
    private var lastInvalidationContext: CellProxy.InvalidationContext?
    
    var shouldUseCachedContentHostingController: Bool {
        (parentViewController?.configuration.unsafeFlags.contains(.cacheCellContentHostingControllers) ?? false)
    }
    
    var shouldEmbedContentHostingController: Bool {
        !(parentViewController?.configuration.unsafeFlags.contains(.disableCellHostingControllerEmbed) ?? false)
    }

    override var isFocused: Bool {
        get {
            _isFocused ?? super.isFocused
        } set {
            guard newValue != _isFocused else {
                return
            }
            
            _isFocused = newValue
            
            update(disableAnimation: true)
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            guard oldValue != isHighlighted else {
                return
            }
            
            update(disableAnimation: true)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            guard oldValue != isSelected else {
                return
            }
            
            update(disableAnimation: true)
        }
    }
    
    var isFocusable: Bool {
        contentPreferences._collectionOrListCellPreferences.isFocusable
    }
    
    var isHighlightable: Bool {
        contentPreferences._collectionOrListCellPreferences.isHighlightable
    }
    
    var isReorderable: Bool {
        contentPreferences._collectionOrListCellPreferences.isReorderable
    }
    
    var isSelectable: Bool {
        contentPreferences._collectionOrListCellPreferences.isSelectable
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = nil
        backgroundView = nil
        contentView.backgroundColor = nil
        contentView.bounds.origin = .zero
        layoutMargins = .zero
        selectedBackgroundView = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if let contentHostingController = contentHostingController {
            if contentHostingController.view.frame.size != bounds.size {
                contentHostingController.view.frame.size = bounds.size
                contentHostingController.view.layoutIfNeeded()
            }
        }
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        contentHostingController?.systemLayoutSizeFitting(targetSize) ??  CGSize(width: 1, height: 1)
    }
    
    override func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        systemLayoutSizeFitting(targetSize)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        systemLayoutSizeFitting(size)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        assignIfNotEqual(false, to: &_isFocused)
        assignIfNotEqual(false, to: &super.isHighlighted)
        assignIfNotEqual(false, to: &super.isSelected)
    }
        
    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        guard let parentViewController = parentViewController,
              let contentConfiguration = cellContentConfiguration
        else {
            return layoutAttributes
        }
        
        if let size = contentCache.preferredContentSize, lastInvalidationContext == nil {
            layoutAttributes.size = size.clamped(to: contentConfiguration.maximumSize)
            
            return layoutAttributes
        } else {
            guard !parentViewController.configuration.ignorePreferredCellLayoutAttributes else {
                return layoutAttributes
            }
            
            if let relativeFrame = contentPreferences.relativeFrame {
                let size = relativeFrame
                    .sizeThatFits(in: layoutAttributes.size)
                    .clamped(to: contentConfiguration.maximumSize)
                
                layoutAttributes.size = size
                
                contentCache.content = nil
                contentCache.preferredContentSize = size
                
                updateCollectionCache()
                
                update(disableAnimation: true)
                
                return layoutAttributes
            } else {
                let preferredLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
                
                if let invalidationContext = lastInvalidationContext {
                    contentCache = .init()
                    
                    if let newPreferredContentSize = invalidationContext.newPreferredContentSize {
                        preferredLayoutAttributes.size = CGSize(
                            newPreferredContentSize.clamped(to: contentConfiguration.maximumSize),
                            default: preferredLayoutAttributes.size
                        )
                    }
                    
                    updateCollectionCache()
                    
                    lastInvalidationContext = nil
                }
                
                if preferredLayoutAttributes.size != contentCache.preferredContentSize {
                    contentCache.preferredContentSize = preferredLayoutAttributes
                        .size
                        .clamped(to: contentConfiguration.maximumSize)
                }
                
                return preferredLayoutAttributes
            }
        }
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        guard let parentViewController = parentViewController,
              let contentHostingController = contentHostingController,
              let contentConfiguration = cellContentConfiguration,
              !parentViewController.configuration.ignorePreferredCellLayoutAttributes
        else {
            return
        }
        
        if let relativeFrame = contentPreferences.relativeFrame {
            if layoutAttributes.size != contentHostingController.view.frame.size {
                self.contentCache.preferredContentSize = relativeFrame.sizeThatFits(in: layoutAttributes.size.clamped(to: contentConfiguration.maximumSize))
                
                contentHostingController.configure(with: configuration, context: .init(disableAnimation: true))
            }
        }
    }
}

extension UIHostingCollectionViewCell {
    func cellWillDisplay(inParent parentViewController: ParentViewControllerType?) {
        update(disableAnimation: true)
        
        contentHostingController?.mount(onto: self)
    }
    
    func cellDidEndDisplaying() {
        updateCollectionCache()
        
        contentHostingController?.unmount(from: self)
        
        if shouldUseCachedContentHostingController {
            contentHostingController = nil
        }
    }
    
    func update(disableAnimation: Bool) {
        guard let parentViewController = parentViewController, let contentConfiguration = cellContentConfiguration else {
            assertionFailure()

            return
        }
        
        defer {
            latestRepresentableUpdate = parentViewController.latestRepresentableUpdate
        }
        
        if !shouldUseCachedContentHostingController {
            if let contentHostingController = contentHostingController {
                contentHostingController.configure(with: configuration, context: .init(disableAnimation: disableAnimation))
            } else {
                contentHostingController = ContentHostingController(configuration: configuration)
            }
        } else {
            if let newContentHostingController = parentViewController.cache.contentHostingControllerCache[contentConfiguration.id], !newContentHostingController.isLive {
                newContentHostingController.configure(with: configuration, context: .init(disableAnimation: disableAnimation))
                
                newContentHostingController.view.setNeedsDisplay()
                newContentHostingController.view.setNeedsLayout()

                contentHostingController = newContentHostingController
            } else if let contentHostingController = contentHostingController {
                contentHostingController.configure(with: configuration, context: .init(disableAnimation: disableAnimation))
            } else {
                let newContentHostingController = ContentHostingController(configuration: configuration)
                
                contentHostingController = newContentHostingController

                parentViewController.cache.contentHostingControllerCache[contentConfiguration.id] = newContentHostingController
            }
        }
    }

    func updateCollectionCache() {
        guard let configuration = cellContentConfiguration, let parentViewController = parentViewController else {
            return
        }
        
        parentViewController.cache.preferences(forID: configuration.id).wrappedValue = contentPreferences
        parentViewController.cache.setContentCache(contentCache, for: configuration.id)
    }
    
    func invalidateContent(with context: CellProxy.InvalidationContext) {
        guard let parentViewController = parentViewController, let contentConfiguration = cellContentConfiguration else {
            return
        }

        parentViewController.cache.invalidateContent(at: contentConfiguration.indexPath, withID: contentConfiguration.id)
                
        if let invalidationContextType = (type(of: parentViewController.collectionView.collectionViewLayout).invalidationContextClass as? UICollectionViewLayoutInvalidationContext.Type) {
            let context = invalidationContextType.init()

            context.invalidateItems(at: [contentConfiguration.indexPath])
            
            parentViewController.collectionView.collectionViewLayout.invalidateLayout(with: context)
        } else {
            parentViewController.collectionView.collectionViewLayout.invalidateLayout()
        }

        contentHostingController?.view.setNeedsDisplay()
        contentHostingController?.view.setNeedsLayout()
        
        lastInvalidationContext = context
    }
}

// MARK: - Auxiliary Implementation -

extension UIHostingCollectionViewCell {
    struct InvalidationContext {
        var newPreferredContentSize: CGSize?
    }

    struct _CellProxyBase: SwiftUIX._CellProxyBase {
        weak var base: UIHostingCollectionViewCell?
        
        var globalFrame: CGRect {
            base?.globalFrame ?? .zero
        }
        
        func invalidateLayout(with context: CellProxy.InvalidationContext) {
            base?.invalidateContent(with: context)
        }
    }
}

extension String {
    static let hostingCollectionViewCellIdentifier = "UIHostingCollectionViewCell"
}

extension CocoaCollectionCellOrSupplementaryViewHostingController {
    fileprivate func mount<SectionHeaderContent: View, SectionFooterContent: View, Content: View>(onto cell: UIHostingCollectionViewCell<SectionType, SectionIdentifierType, ItemType, ItemIdentifierType, SectionHeaderContent, SectionFooterContent, Content>) {
        guard let parent = cell.parentViewController else {
            assertionFailure()
            
            return
        }
        
        if cell.shouldEmbedContentHostingController {
            if parent === self.parent && view.superview === cell.contentView {
                return
            }
            
            if self.parent == nil {
                let isNavigationBarHidden = parent.navigationController?.isNavigationBarHidden
                
                UIView.performWithoutAnimation {
                    self.willMove(toParent: parent)
                    parent.addChild(self)
                    view.removeFromSuperview()
                    cell.contentView.addSubview(view)
                    view.frame = cell.contentView.bounds
                    didMove(toParent: parent)
                }
                
                if let isNavigationBarHidden = isNavigationBarHidden, navigationController?.isNavigationBarHidden != isNavigationBarHidden {
                    navigationController?.setNavigationBarHidden(isNavigationBarHidden, animated: false)
                }
            } else {
                assertionFailure()
            }
        } else {
            if view.superview !== cell.contentView {
                UIView.performWithoutAnimation {
                    cell.contentView.addSubview(view)
                    view.frame = cell.contentView.bounds
                }
            }
        }
    }
    
    fileprivate func unmount<SectionHeaderContent: View, SectionFooterContent: View, Content: View>(from cell: UIHostingCollectionViewCell<SectionType, SectionIdentifierType, ItemType, ItemIdentifierType, SectionHeaderContent, SectionFooterContent, Content>) {
        if cell.shouldUseCachedContentHostingController {
            if parent != nil {
                UIView.performWithoutAnimation {
                    willMove(toParent: nil)
                    view.removeFromSuperview()
                    removeFromParent()
                }
            } else {
                UIView.performWithoutAnimation {
                    view.removeFromSuperview()
                }
            }
        }
    }
}

#endif
