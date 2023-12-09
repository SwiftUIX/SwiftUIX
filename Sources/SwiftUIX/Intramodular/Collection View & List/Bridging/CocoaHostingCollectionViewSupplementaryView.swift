//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if (os(iOS) && canImport(CoreTelephony)) || os(tvOS) || targetEnvironment(macCatalyst)

class CocoaHostingCollectionViewSupplementaryView<
    SectionType,
    SectionIdentifierType: Hashable,
    ItemType,
    ItemIdentifierType: Hashable,
    SectionHeaderContent: View,
    SectionFooterContent: View,
    Content: View
>: UICollectionReusableView {
    typealias ParentViewControllerType = CocoaHostingCollectionViewController<
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

    var latestRepresentableUpdate: _AppKitOrUIKitViewRepresentableUpdate?
    var configuration: ContentConfiguration?
    var cache = ContentCache()
    
    var content: _CollectionViewItemContent.ResolvedView {
        if let content = cache.content {
            return content
        } else if let configuration = configuration {
            let content = configuration.makeContent()
            
            self.cache.content = content
            
            updateCollectionCache()
            
            return content
        } else {
            fatalError()
        }
    }
    
    private var contentHostingController: ContentHostingController?
    
    weak var parentViewController: ParentViewControllerType?
    
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
                targetSize = CGSize(dimensions, default: targetSize).clamped(to: configuration?.maximumSize ?? nil)
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
                    cache.preferredContentSize = result.size.clamped(to: configuration?.maximumSize ?? nil)
                }
                
                updateCollectionCache()
                
                return result
            } else {
                return layoutAttributes
            }
        }
    }
}

extension CocoaHostingCollectionViewSupplementaryView {
    func update(disableAnimation: Bool = true) {
        guard configuration != nil else {
            return
        }

        defer {
            latestRepresentableUpdate = parentViewController?.latestRepresentableUpdate
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
        updateCollectionCache()
    }
    
    func updateCollectionCache() {
        guard let configuration = configuration, let parentViewController = parentViewController else {
            return
        }
        
        parentViewController.cache.setContentCache(cache, for: configuration.id)
    }
}

// MARK: - Auxiliary

extension CocoaHostingCollectionViewSupplementaryView {
    private class ContentHostingController: UIHostingController<_CollectionViewElementContent<ItemType, ItemIdentifierType, SectionType, SectionIdentifierType>> {
        weak var base: CocoaHostingCollectionViewSupplementaryView?
        
        init(base: CocoaHostingCollectionViewSupplementaryView) {
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
                AppKitOrUIKitLayoutSizeProposal(
                    targetSize: targetSize,
                    maximumSize: base?.configuration?.maximumSize ?? nil,
                    horizontalFittingPriority: nil,
                    verticalFittingPriority: nil
                )
            )
        }
        
        func systemLayoutSizeFitting(
            _ targetSize: CGSize,
            withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
            verticalFittingPriority: UILayoutPriority
        ) -> CGSize {
            sizeThatFits(
                AppKitOrUIKitLayoutSizeProposal(
                    targetSize: targetSize,
                    maximumSize: base?.configuration?.maximumSize ?? nil,
                    horizontalFittingPriority: horizontalFittingPriority,
                    verticalFittingPriority: verticalFittingPriority
                )
            )
        }
        
        func move(
            toParent parent: ParentViewControllerType?,
            ofSupplementaryView supplementaryView: CocoaHostingCollectionViewSupplementaryView
        ) {
            if let parent = parent {
                let hostAsChildViewController = !parent.configuration.unsafeFlags.contains(.disableCellHostingControllerEmbed)

                if let existingParent = self.parent, existingParent !== parent {
                    move(toParent: nil, ofSupplementaryView: supplementaryView)
                }
                
                if self.parent == nil {
                    if hostAsChildViewController {
                        UIView.performWithoutAnimation {
                            self.willMove(toParent: parent)
                            parent.addChild(self)
                            supplementaryView.addSubview(view)
                            view.frame = supplementaryView.bounds
                            didMove(toParent: parent)
                        }
                    } else {
                        if view.superview !== supplementaryView {
                            UIView.performWithoutAnimation {
                                supplementaryView.addSubview(view)
                                view.frame = supplementaryView.bounds
                            }
                        }
                    }
                } else {
                    assertionFailure()
                }
            } else {
                if self.parent != nil {
                    UIView.performWithoutAnimation {
                        willMove(toParent: nil)
                        view.removeFromSuperview()
                        removeFromParent()
                    }
                }
            }
        }
        
        func update(
            disableAnimation: Bool = true,
            forced: Bool = false
        ) {
            guard let base = base else {
                return
            }
            
            let currentContentConfiguration = rootView.configuration.contentConfiguration
            let newContentConfiguration = base.configuration
            
            if !forced {
                if let newContentConfiguration = newContentConfiguration {
                    guard currentContentConfiguration.id != newContentConfiguration.id else {
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
    static let hostingCollectionViewHeaderSupplementaryViewIdentifier = "UIHostingCollectionViewHeaderSupplementaryView"
    static let hostingCollectionViewFooterSupplementaryViewIdentifier = "UIHostingCollectionViewFooterSupplementaryView"
}

#endif
