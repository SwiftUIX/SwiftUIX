//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

/// A `UIView` subclass capable of hosting a SwiftUI view.
open class UIHostingView<Content: View>: UIView {
    struct _ContentContainer: View {
        weak var parent: _ContentHostingController?
        
        var content: Content
        
        var body: some View {
            content.onChangeOfFrame { [weak parent] _ in
                guard let parent = parent else {
                    return
                }
                
                if parent.shouldResizeToFitContent {
                    parent.view.invalidateIntrinsicContentSize()
                }
            }
        }
    }
    
    class _ContentHostingController: UIHostingController<_ContentContainer> {
        weak var _navigationController: UINavigationController?
        
        var shouldResizeToFitContent: Bool = false
        
        override var navigationController: UINavigationController? {
            super.navigationController ?? _navigationController
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            view.backgroundColor = .clear
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            view.backgroundColor = .clear
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            
            if shouldResizeToFitContent {
                view.invalidateIntrinsicContentSize()
            }
        }
    }
    
    private let rootViewHostingController: _ContentHostingController
    
    public var shouldResizeToFitContent: Bool {
        get {
            rootViewHostingController.shouldResizeToFitContent
        } set {
            rootViewHostingController.shouldResizeToFitContent = newValue
        }
    }
    
    public var rootView: Content {
        get {
            rootViewHostingController.rootView.content
        } set {
            rootViewHostingController.rootView.content = newValue
            
            if shouldResizeToFitContent {
                invalidateIntrinsicContentSize()
            }
        }
    }
    
    override open var intrinsicContentSize: CGSize {
        rootViewHostingController.view.intrinsicContentSize
    }
    
    public required init(rootView: Content) {
        self.rootViewHostingController = .init(rootView: .init(parent: nil, content: rootView))
        self.rootViewHostingController.rootView.parent = rootViewHostingController
        
        super.init(frame: .zero)
                
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
    
    open override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        
        if shouldResizeToFitContent {
            rootViewHostingController.view.invalidateIntrinsicContentSize()
        }
    }
}

extension UIHostingView {
    public func _fixSafeAreaInsets() {
        rootViewHostingController._fixSafeAreaInsets()
    }
}

#endif
