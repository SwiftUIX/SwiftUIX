//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

open class UIHostingScrollView<Content: View>: UIScrollView {
    public let hostingContentView: UIHostingView<Content>
    
    public var rootView: Content {
        get {
            hostingContentView.rootView
        } set {
            hostingContentView.rootView = newValue
        }
    }
    
    public init(rootView: Content) {
        hostingContentView = UIHostingView(rootView: rootView)
        hostingContentView.rootView = rootView
        
        super.init(frame: .zero)
        
        addSubview(hostingContentView)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
