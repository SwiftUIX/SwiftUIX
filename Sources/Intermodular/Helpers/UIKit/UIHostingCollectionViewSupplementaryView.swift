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
        
        var content: AnyView? {
            viewProvider.sectionContent(for: kind)?(section)
        }
        
        var id: ID {
            .init(kind: kind, item: itemIdentifier, section: sectionIdentifier)
        }
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
    
    var configuration: Configuration? {
        didSet {
            update()
        }
    }
    
    var cache = Cache()
    
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
            if contentHostingController.view.frame != bounds {
                contentHostingController.view.frame = bounds
                
                if contentHostingController.view.frame.rounded(.up) != bounds.rounded(.up) {
                    contentHostingController.view.setNeedsLayout()
                    contentHostingController.view.layoutIfNeeded()
                }
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
            if !(parentViewController?.configuration._ignorePreferredCellLayoutAttributes ?? false) {
                let result = super.preferredLayoutAttributesFitting(layoutAttributes)
                
                if cache.preferredContentSize == nil || result.size != bounds.size {
                    cache.preferredContentSize = result.size
                        .rounded(.up)
                        .clamped(to: configuration?.maximumSize)
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
    func update(disableAnimation: Bool = true, forced: Bool = false) {
        if let contentHostingController = contentHostingController {
            contentHostingController.update(disableAnimation: disableAnimation, forced: forced)
        } else {
            contentHostingController = ContentHostingController(base: self)
        }
    }
    
    func supplementaryViewWillDisplay(
        inParent parentViewController: ParentViewControllerType?,
        isPrototype: Bool = false
    ) {
        if contentHostingController == nil {
            update()
        }
        
        guard let contentHostingController = contentHostingController else {
            assertionFailure()
            
            return
        }
        
        defer {
            self.parentViewController = parentViewController
        }
        
        if let parentViewController = parentViewController {
            if contentHostingController.parent == nil {
                contentHostingController.move(toParent: parentViewController, ofSupplementaryView: self)
            }
        } else if !isPrototype {
            assertionFailure()
        }
    }
    
    func supplementaryViewDidEndDisplaying() {
        
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
        var configuration: Configuration?
        
        init(base: UIHostingCollectionViewSupplementaryView) {
            _collectionViewProxy = .init(base.parentViewController)
            configuration = base.configuration
        }
        
        var body: some View {
            if let configuration = configuration, let content = configuration.content {
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
            .rounded(.up)
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
            .rounded(.up)
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
                    withoutAnimation {
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
                withoutAnimation {
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
    static let hostingCollectionViewSupplementaryViewIdentifier = "UIHostingCollectionViewSupplementaryView"
}

#endif
