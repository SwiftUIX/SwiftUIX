//
// Copyright (c) Vatsal Manot
//

#if canImport(UIKit)

import Swift
import SwiftUI
import UIKit

/// A `UIView` subclass capable of hosting a SwiftUI view.
open class UIHostingView<Content: View>: UIView {
    private let rootView: Content
    private let rootViewHostingController: UIHostingController<Content>
    
    public init(rootView: Content) {
        self.rootView = rootView
        self.rootViewHostingController = UIHostingController(rootView: rootView)
        
        super.init(frame: .zero)
        
        addSubview(rootViewHostingController.view)
    }
    
    override public func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        frame.size = rootViewHostingController.view.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize)
        
        rootViewHostingController.view.frame.size = frame.size
        rootViewHostingController.view.backgroundColor = .red
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#endif
