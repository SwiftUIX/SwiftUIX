//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

open class CocoaPresentationHostingController: CocoaHostingController<CocoaPresentationHostingControllerContent> {
    init(
        presentation: AnyModalPresentation,
        coordinator: CocoaPresentationCoordinator
    ) {
        super.init(
            rootView: .init(presentation: presentation),
            presentationCoordinator: coordinator
        )
        
        modalPresentationStyle = .init(presentation.content.presentationStyle)
        presentationController?.delegate = coordinator
        transitioningDelegate = presentation.content.presentationStyle.transitioningDelegate
        
        if presentation.content.presentationStyle != .automatic {
            view.backgroundColor = .clear
        }
    }
    
    @objc required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#endif
