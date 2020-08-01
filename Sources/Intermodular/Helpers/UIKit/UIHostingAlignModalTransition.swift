//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

class UIHostingAlignModalTransition: UIPercentDrivenInteractiveTransition {
    override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        super.wantsInteractiveStart = false
        
        super.startInteractiveTransition(transitionContext)
    }
}

#endif
