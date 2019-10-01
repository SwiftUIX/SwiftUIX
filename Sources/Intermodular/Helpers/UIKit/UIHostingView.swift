//
// Copyright (c) Vatsal Manot
//

#if canImport(UIKit)

import Swift
import SwiftUI
import UIKit

public final class UIHostingView<Content: View>: UIView {
    private let rootView: Content
    private let rootViewHostingController: UIHostingController<Content>
    private let rootViewContainer = UIView()
    
    public init(content: Content) {
        self.rootView = content
        self.rootViewHostingController = UIHostingController(rootView: content)
        
        super.init(frame: .zero)
        
        rootViewContainer.frame.origin = .init(x: 100, y: 100)
        addSubview(rootViewContainer)
        
        rootViewContainer.addSubview(rootViewHostingController.view)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        rootViewContainer.frame.size = rootViewHostingController.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#endif
