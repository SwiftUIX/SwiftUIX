//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

open class CocoaPresentationHostingController: CocoaHostingController<AnyPresentationView> {
    var presentation: AnyModalPresentation {
        didSet {
            presentationDidChange(presentingViewController: presentingViewController)
        }
    }
    
    init(
        presentingViewController: UIViewController,
        presentation: AnyModalPresentation,
        coordinator: CocoaPresentationCoordinator
    ) {
        self.presentation = presentation
        
        super.init(
            mainView: presentation.content,
            presentationCoordinator: coordinator
        )
        
        presentationDidChange(presentingViewController: presentingViewController)
    }
    
    private func presentationDidChange(presentingViewController: UIViewController?) {
        modalPresentationStyle = .init(presentation.content.presentationStyle)
        presentationController?.delegate = presentationCoordinator
        transitioningDelegate = presentation.content.presentationStyle.transitioningDelegate
        
        #if !os(tvOS)
        if case let .popover(permittedArrowDirections) = presentation.content.presentationStyle {
            popoverPresentationController?.delegate = presentationCoordinator
            popoverPresentationController?.permittedArrowDirections = permittedArrowDirections
            
            let sourceViewDescription = presentation.content.preferredSourceViewName.flatMap {
                (presentingViewController as? _opaque_CocoaController)?._namedViewDescription(for: $0)
            }
            
            popoverPresentationController?.sourceView = presentingViewController?.view
            
            if let sourceRect = sourceViewDescription?.globalBounds {
                popoverPresentationController?.sourceRect = sourceRect
            }
        }
        #endif
        
        if presentation.content.presentationStyle != .automatic {
            view.backgroundColor = .clear
        }
        
        rootView.content = presentation.content
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
