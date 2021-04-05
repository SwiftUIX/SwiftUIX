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
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if let contentHostingController = contentHostingController {
            if contentHostingController.view.frame != bounds {
                contentHostingController.view.frame = bounds
                contentHostingController.view.setNeedsLayout()
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
        return layoutAttributes
    }
}

extension UIHostingCollectionViewSupplementaryView {
    func supplementaryViewWillDisplay(
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
                contentHostingController.move(toParent: parentViewController, ofSupplementaryView: self)
            }
        } else if !isPrototype {
            assertionFailure()
        }
    }
    
    func supplementaryViewDidEndDisplaying() {
        
    }
    
    func update(disableAnimation: Bool = true, forced: Bool = false) {
        if let contentHostingController = contentHostingController {
            contentHostingController.update(disableAnimation: disableAnimation, forced: forced)
        } else {
            contentHostingController = ContentHostingController(base: self)
        }
    }
}

// MARK: - Auxiliary Implementation -

extension UIHostingCollectionViewSupplementaryView {
    private struct RootView: ExpressibleByNilLiteral, View {
        var configuration: Configuration?
        var content: AnyView?
        
        init(base: UIHostingCollectionViewSupplementaryView?) {
            configuration = base?.configuration
            content = configuration?.content
        }
        
        public init(nilLiteral: ()) {
            
        }
        
        public var body: some View {
            content?
                .edgesIgnoringSafeArea(.all)
        }
    }
    
    private class ContentHostingController: CocoaHostingController<RootView> {
        weak var base: UIHostingCollectionViewSupplementaryView?
        
        init(base: UIHostingCollectionViewSupplementaryView?) {
            self.base = base
            
            super.init(mainView: nil)
            
            view.backgroundColor = nil

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
        
        func move(
            toParent parent: _opaque_UIHostingCollectionViewController?,
            ofSupplementaryView supplementaryView: UIHostingCollectionViewSupplementaryView
        ) {
            if let parent = parent {
                if let existingParent = self.parent, existingParent !== parent {
                    move(toParent: nil, ofSupplementaryView: supplementaryView)
                }
                
                if self.parent == nil {
                    self.willMove(toParent: parent)
                    parent.addChild(self)
                    supplementaryView.addSubview(view)
                    view.frame = supplementaryView.bounds
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
        
        func update(disableAnimation: Bool = true, forced: Bool = false) {
            guard let base = base else {
                return
            }
            
            if !forced {
                if let currentConfiguration = mainView.configuration, let newConfiguration = base.configuration {
                    guard currentConfiguration.id != newConfiguration.id else {
                        return
                    }
                }
            }
            
            if disableAnimation {
                withAnimation(nil) {
                    mainView = .init(base: base)
                }
            } else {
                mainView = .init(base: base)
            }
        }
    }
}

extension String {
    static let hostingCollectionViewSupplementaryViewIdentifier = "UIHostingCollectionViewSupplementaryView"
}

#endif
