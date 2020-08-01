//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

open class CocoaPresentationHostingController: CocoaHostingController<CocoaPresentationHostingControllerContent> {
    init(
        presentingViewController: UIViewController,
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
        
        #if !os(tvOS)
        if case let .popover(permittedArrowDirections) = presentation.content.presentationStyle {
            popoverPresentationController?.delegate = coordinator
            popoverPresentationController?.permittedArrowDirections = permittedArrowDirections
            
            let sourceViewDescription = presentation.content.preferredSourceViewName.flatMap {
                (presentingViewController as? CocoaController)?.description(for: $0)
            }
            
            popoverPresentationController?.sourceView = presentingViewController.view
            
            if let sourceRect = sourceViewDescription?.globalBounds {
                popoverPresentationController?.sourceRect = sourceRect
            }
        }
        #endif
        
        if presentation.content.presentationStyle != .automatic {
            view.backgroundColor = .clear
        }
    }
    
    @objc required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        preferredContentSize = sizeThatFits(in: UIView.layoutFittingExpandedSize)
    }
}

#endif
