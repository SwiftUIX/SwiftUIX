//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

/// A `UIView` subclass capable of hosting a SwiftUI view.
open class UIHostingView<Content: View>: UIView {
    private let rootViewHostingController: UIHostingController<Content>
    
    public var rootView: Content {
        get {
            return rootViewHostingController.rootView
        } set {
            rootViewHostingController.rootView = newValue
        }
    }
    
    public required init(rootView: Content) {
        self.rootViewHostingController = UIHostingController(rootView: rootView)
        
        super.init(frame: .zero)
        
        rootViewHostingController.view.backgroundColor = .clear
        
        addSubview(rootViewHostingController.view)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func sizeThatFits(_ size: CGSize) -> CGSize {
        rootViewHostingController.sizeThatFits(in: size)
    }
    
    override open func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        rootViewHostingController.sizeThatFits(in: targetSize)
    }
    
    override open func systemLayoutSizeFitting(
        _ targetSize: CGSize,
        withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority,
        verticalFittingPriority: UILayoutPriority
    ) -> CGSize {
        rootViewHostingController.sizeThatFits(in: targetSize)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        rootViewHostingController.view.frame = bounds
    }
    
    override open func sizeToFit() {
        if let superview = superview {
            frame.size = rootViewHostingController.sizeThatFits(in: superview.frame.size)
        } else {
            super.sizeToFit()
        }
    }
}

#endif
