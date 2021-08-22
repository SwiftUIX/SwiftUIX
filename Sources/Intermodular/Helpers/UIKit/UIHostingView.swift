//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

/// A `UIView` subclass capable of hosting a SwiftUI view.
open class UIHostingView<Content: View>: UIView {
    class _UIHostingController: UIHostingController<Content> {
        weak var _navigationController: UINavigationController?
        
        override var navigationController: UINavigationController? {
            super.navigationController ?? _navigationController
        }
    }
    
    private let rootViewHostingController: _UIHostingController
    
    public var rootView: Content {
        get {
            return rootViewHostingController.rootView
        } set {
            rootViewHostingController.rootView = newValue
        }
    }
    
    public required init(rootView: Content) {
        self.rootViewHostingController = .init(rootView: rootView)
        
        super.init(frame: .zero)
        
        rootViewHostingController.view.backgroundColor = .clear
        
        addSubview(rootViewHostingController.view)
        
        rootViewHostingController.view.constrainEdges(to: self)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: superview)
        
        rootViewHostingController._navigationController = superview?.nearestViewController?.nearestNavigationController ?? (superview?.nearestViewController as? UINavigationController)
    }
    
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        rootViewHostingController._navigationController = superview?.nearestViewController?.nearestNavigationController ?? (superview?.nearestViewController as? UINavigationController)
    }
    
    override open func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        rootViewHostingController.sizeThatFits(.init(targetSize: .init(targetSize)))
    }
    
    override open func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        rootViewHostingController.sizeThatFits(
            .init(
                targetSize: .init(targetSize),
                horizontalFittingPriority: horizontalFittingPriority,
                verticalFittingPriority: verticalFittingPriority
            )
        )
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        systemLayoutSizeFitting(size)
    }
    
    override open func sizeToFit() {
        if let superview = superview {
            frame.size = rootViewHostingController.sizeThatFits(in: superview.frame.size)
        } else {
            frame.size = rootViewHostingController.sizeThatFits(AppKitOrUIKitLayoutSizeProposal())
        }
    }
}

extension UIHostingView {
    public func _fixSafeAreaInsets() {
        rootViewHostingController._fixSafeAreaInsets()
    }
}

#endif
