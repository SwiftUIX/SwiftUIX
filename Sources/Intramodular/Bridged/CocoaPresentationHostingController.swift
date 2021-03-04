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
        mainView = presentation.content
        
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        #if os(iOS) || targetEnvironment(macCatalyst)
        hidesBottomBarWhenPushed = mainView.hidesBottomBarWhenPushed
        #endif
        modalPresentationStyle = .init(mainView.presentationStyle)
        presentationController?.delegate = presentationCoordinator
        _transitioningDelegate = mainView.presentationStyle.toTransitioningDelegate()
        #elseif os(macOS)
        fatalError("unimplemented")
        #endif
        
        #if !os(tvOS)
        if case let .popover(permittedArrowDirections) = mainView.presentationStyle {
            popoverPresentationController?.delegate = presentationCoordinator
            popoverPresentationController?.permittedArrowDirections = permittedArrowDirections
            
            let sourceViewDescription = mainView.preferredSourceViewName.flatMap {
                (presentingViewController as? _opaque_CocoaController)?._namedViewDescription(for: $0)
            }
            
            popoverPresentationController?.sourceView = presentingViewController?.view
            
            if let sourceRect = sourceViewDescription?.globalBounds {
                popoverPresentationController?.sourceRect = sourceRect
            }
        }
        #endif
        
        if mainView.presentationStyle != .automatic {
            view.backgroundColor = .clear
        }
    }
    
    @objc required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if preferredContentSize != UIView.layoutFittingExpandedSize {
            preferredContentSize = sizeThatFits(in: UIView.layoutFittingExpandedSize)
        }
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        view.frame.size = size
    }
}

#endif
