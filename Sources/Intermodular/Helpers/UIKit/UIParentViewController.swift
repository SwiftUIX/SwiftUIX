//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

public final class UIParentViewController<Child: UIViewController>: UIViewController {
    public let child: Child
    
    public init(child: Child) {
        self.child = child
        
        super.init(nibName: nil, bundle: nil)
        
        view.constrainSubview(child.view)
        
        addChild(child)
        
        child.didMove(toParent: self)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#endif
