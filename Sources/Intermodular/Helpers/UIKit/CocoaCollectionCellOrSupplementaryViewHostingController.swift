//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

class CocoaCollectionCellOrSupplementaryViewHostingController<
    ItemType,
    ItemIdentifierType: Hashable,
    SectionType,
    SectionIdentifierType: Hashable
>: UIHostingController<_CollectionViewCellOrSupplementaryViewContainer<ItemType, ItemIdentifierType, SectionType, SectionIdentifierType>> {
    typealias Configuration = _CollectionViewCellOrSupplementaryViewContainer<ItemType, ItemIdentifierType, SectionType, SectionIdentifierType>.Configuration
    
    var isLive: Bool {
        view.superview != nil
    }

    init(configuration: Configuration) {
        super.init(rootView: .init(configuration: configuration))
        
        view.backgroundColor = nil
        
        _fixSafeAreaInsets()
    }
    
    @objc required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    struct ConfigurationContext {
        var disableAnimation: Bool
    }
    
    func configure(with newConfiguration: Configuration, context: ConfigurationContext) {
        let currentConfiguration = rootView.configuration
        
        if newConfiguration.contentCache.content != nil {
            guard currentConfiguration.contentConfiguration.id != newConfiguration.contentConfiguration.id || currentConfiguration.contentState != newConfiguration.contentState || currentConfiguration.contentCache.contentSize != newConfiguration.contentCache.contentSize else {
                return
            }
        }
        
        if view.superview != nil {
            _withoutAnimation(context.disableAnimation) {
                rootView = .init(configuration: newConfiguration)
            }
        } else {
            rootView = .init(configuration: newConfiguration)
        }
    }
    
    public func systemLayoutSizeFitting(
        _ targetSize: CGSize
    ) -> CGSize {
        var newTargetSize = targetSize
        
        if let maximumSize = rootView.configuration.contentConfiguration.maximumSize, let dimensions = rootView.configuration.content._precomputedDimensionsThatFit(in: maximumSize)
        {
            if let size = CGSize(dimensions), !size.isAreaZero {
                if size.fits(targetSize) {
                    return size
                } else {
                    return size.clamped(to: maximumSize)
                }
            } else {
                newTargetSize = CGSize(dimensions, default: targetSize)
            }
        }

        return sizeThatFits(
            AppKitOrUIKitLayoutSizeProposal(
                targetSize: newTargetSize,
                maximumSize: rootView.configuration.contentConfiguration.maximumSize ?? nil,
                horizontalFittingPriority: nil,
                verticalFittingPriority: nil
            )
        )
    }
    
    public func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        systemLayoutSizeFitting(targetSize)
    }
}

#endif
