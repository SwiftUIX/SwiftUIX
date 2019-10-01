//
// Copyright (c) Vatsal Manot
//

#if canImport(UIKit)

import Swift
import SwiftUI
import UIKit

public final class UIParentViewController<Child: UIViewController>: UIViewController {
    public let child: Child
    
    public init(child: Child) {
        self.child = child
        
        super.init(nibName: nil, bundle: nil)
        
        view.addSubview(child.view)
        view.constrain(to: child.view)
        
        addChild(child)
        
        child.didMove(toParent: self)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#endif
