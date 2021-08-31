//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension UIHostingCollectionViewSupplementaryView {
    struct Configuration: Identifiable {
        struct ID: Hashable {
            let kind: String
            let item: ItemIdentifierType?
            let section: SectionIdentifierType
        }
        
        var kind: String
        var item: ItemType?
        var section: SectionType
        var itemIdentifier: ItemIdentifierType?
        var sectionIdentifier: SectionIdentifierType
        var indexPath: IndexPath
        var viewProvider: ParentViewControllerType._SwiftUIType.ViewProvider
        var maximumSize: OptionalDimensions?
        
        var id: ID {
            .init(kind: kind, item: itemIdentifier, section: sectionIdentifier)
        }
    }
    
    struct Cache {
        var content: AnyView?
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

class UIHostingCollectionViewSupplementaryView<
    SectionType,
    SectionIdentifierType: Hashable,
    ItemType,
    ItemIdentifierType: Hashable,
    SectionHeaderContent: View,
    SectionFooterContent: View,
    Content: View
>: UICollectionReusableView {
    typealias ParentViewControllerType = UIHostingCollectionViewController<
        SectionType,
        SectionIdentifierType,
        ItemType,
        ItemIdentifierType,
        SectionHeaderContent,
        SectionFooterContent,
        Content
    >
    
    var configuration: Configuration?
    var cache = Cache()
    
    var content: AnyView? {
        if let content = cache.content {
            return content
        } else if let configuration = configuration {
            let content = configuration.viewProvider.sectionContent(for: configuration.kind)?(configuration.section)
            
            self.cache.content = content
            
            updateCollectionCache()
            
            return content
        } else {
            fatalError()
        }
    }
    
    private var contentHostingController: ContentHostingController?
    
    private weak var parentViewController: ParentViewControllerType?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        layoutMargins = .zero
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let contentHostingController = contentHostingController {
            if contentHostingController.view.frame.size != bounds.size {
                contentHostingController.view.frame.size = bounds.size
                contentHostingController.view.layoutIfNeeded()
            }
        }
    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        return contentHostingController?.systemLayoutSizeFitting(targetSize) ?? .init(width: 1, height: 1)
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
                    .clamped(to: configuration?.maximumSize)
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
    }
    
    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        if let size = cache.preferredContentSize {
            layoutAttributes.size = size
            
            return layoutAttributes
        } else {
            if !(parentViewController?.configuration.ignorePreferredCellLayoutAttributes ?? false) {
                let result = super.preferredLayoutAttributesFitting(layoutAttributes)
                
                if cache.preferredContentSize == nil || result.size != bounds.size {
                    cache.preferredContentSize = result.size.clamped(to: configuration?.maximumSize)
                }
                
                updateCollectionCache()
                
                return result
            } else {
                return layoutAttributes
            }
        }
    }
}

extension UIHostingCollectionViewSupplementaryView {
    func update(disableAnimation: Bool = true) {
        guard configuration != nil else {
            return
        }
        
        if let contentHostingController = contentHostingController {
            contentHostingController.update(disableAnimation: disableAnimation)
        } else {
            contentHostingController = ContentHostingController(base: self)
        }
    }
    
    func supplementaryViewWillDisplay(
        inParent parentViewController: ParentViewControllerType?,
        isPrototype: Bool = false
    ) {
        UIView.performWithoutAnimation {
            contentHostingController?.view.isHidden = false
        }
        
        guard configuration != nil else {
            return
        }
        
        if contentHostingController == nil {
            update(disableAnimation: true)
        }
        
        guard let contentHostingController = contentHostingController else {
            assertionFailure()
            
            return
        }
        
        if let parentViewController = parentViewController {
            if contentHostingController.parent == nil {
                contentHostingController.move(toParent: parentViewController, ofSupplementaryView: self)
                self.parentViewController = parentViewController
                
                updateCollectionCache()
            }
        } else if !isPrototype {
            assertionFailure()
        }
    }
    
    func supplementaryViewDidEndDisplaying() {
        UIView.performWithoutAnimation {
            contentHostingController?.view.isHidden = true
        }
    }
    
    func updateCollectionCache() {
        guard let configuration = configuration, let parentViewController = parentViewController else {
            return
        }
        
        parentViewController.cache.setSupplementaryViewCache(cache, for: configuration.id)
    }
}

// MARK: - Auxiliary Implementation -

extension UIHostingCollectionViewSupplementaryView {
    private struct RootView: View {
        var _collectionViewProxy: CollectionViewProxy
        var content: AnyView?
        var configuration: Configuration?
        
        init(base: UIHostingCollectionViewSupplementaryView) {
            _collectionViewProxy = .init(base.parentViewController)
            content = base.content
            configuration = base.configuration
        }
        
        var body: some View {
            if let content = content, let configuration = configuration {
                content
                    .environment(\._collectionViewProxy, .init(.constant(_collectionViewProxy)))
                    .edgesIgnoringSafeArea(.all)
                    .id(configuration.id)
            }
        }
    }
    
    private class ContentHostingController: UIHostingController<RootView> {
        weak var base: UIHostingCollectionViewSupplementaryView?
        
        init(base: UIHostingCollectionViewSupplementaryView) {
            self.base = base
            
            super.init(rootView: .init(base: base))
            
            view.backgroundColor = nil
            
            update(disableAnimation: true)
        }
        
        @objc required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func systemLayoutSizeFitting(
            _ targetSize: CGSize
        ) -> CGSize {
            sizeThatFits(
                in: targetSize,
                withHorizontalFittingPriority: nil,
                verticalFittingPriority: nil
            )
            .clamped(to: base?.configuration?.maximumSize)
        }
        
        func systemLayoutSizeFitting(
            _ targetSize: CGSize,
            withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
            verticalFittingPriority: UILayoutPriority
        ) -> CGSize {
            sizeThatFits(
                in: targetSize,
                withHorizontalFittingPriority: horizontalFittingPriority,
                verticalFittingPriority: verticalFittingPriority
            )
            .clamped(to: base?.configuration?.maximumSize)
        }
        
        func move(
            toParent parent: ParentViewControllerType?,
            ofSupplementaryView supplementaryView: UIHostingCollectionViewSupplementaryView
        ) {
            if let parent = parent {
                if let existingParent = self.parent, existingParent !== parent {
                    move(toParent: nil, ofSupplementaryView: supplementaryView)
                }
                
                if self.parent == nil {
                    UIView.performWithoutAnimation {
                        self.willMove(toParent: parent)
                        parent.addChild(self)
                        supplementaryView.addSubview(view)
                        view.frame = supplementaryView.bounds
                        didMove(toParent: parent)
                    }
                } else {
                    assertionFailure()
                }
            } else {
                UIView.performWithoutAnimation {
                    willMove(toParent: nil)
                    view.removeFromSuperview()
                    removeFromParent()
                }
            }
        }
        
        func update(disableAnimation: Bool = true, forced: Bool = false) {
            guard let base = base else {
                return
            }
            
            let currentConfiguration = rootView.configuration
            let newConfiguration = base.configuration
            
            if !forced {
                if let currentConfiguration = currentConfiguration, let newConfiguration = newConfiguration {
                    guard currentConfiguration.id != newConfiguration.id else {
                        return
                    }
                }
            }
            
            _withoutAnimation(disableAnimation) {
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
    static let hostingCollectionViewSupplementaryViewIdentifier = "UIHostingCollectionViewSupplementaryView"
}

#endif
