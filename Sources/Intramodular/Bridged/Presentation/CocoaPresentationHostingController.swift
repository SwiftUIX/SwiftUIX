//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

open class CocoaPresentationHostingController: CocoaHostingController<CocoaPresentationHostingControllerContent> {
    public override var rootViewName: ViewName? {
        nil
            ?? rootViewContent.presentation.contentName
            ?? (rootViewContent.presentation.content() as? opaque_NamedView)?.name
    }
    
    init(
        presentation: AnyModalPresentation,
        coordinator: CocoaPresentationCoordinator
    ) {
        super.init(
            rootView: .init(presentation: presentation),
            presentationCoordinator: coordinator
        )
                
        modalPresentationStyle = .init(presentation.presentationStyle)
        presentationController?.delegate = coordinator
        transitioningDelegate = presentation.presentationStyle.transitioningDelegate
        
        if presentation.presentationStyle != .automatic {
            view.backgroundColor = .clear
        }
    }
    
    @objc required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#endif
