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
        presentationCoordinator: CocoaPresentationCoordinator
    ) {
        self.presentation = presentation
        
        super.init(
            mainView: presentation.content,
            presentationCoordinator: presentationCoordinator
        )
        
        presentationDidChange(presentingViewController: presentingViewController)
    }
    
    private func presentationDidChange(presentingViewController: UIViewController?) {
        mainView = presentation.content
        
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        #if os(iOS) || targetEnvironment(macCatalyst)
        hidesBottomBarWhenPushed = mainView.hidesBottomBarWhenPushed
        #endif
        if (presentingViewController?.presentedViewController !== self) {
            modalPresentationStyle = .init(mainView.modalPresentationStyle)
            presentationController?.delegate = presentationCoordinator
            _transitioningDelegate = mainView.modalPresentationStyle.toTransitioningDelegate()
        }
        #elseif os(macOS)
        fatalError("unimplemented")
        #endif
        
        #if !os(tvOS)
        if case let .popover(permittedArrowDirections, attachmentAnchor) = mainView.modalPresentationStyle {
            popoverPresentationController?.delegate = presentationCoordinator
            popoverPresentationController?.permittedArrowDirections = .init(permittedArrowDirections)
            
            let sourceViewDescription = mainView.preferredSourceViewName.flatMap {
                (presentingViewController as? _opaque_CocoaController)?._namedViewDescription(for: $0)
            }
            
            popoverPresentationController?.sourceView = presentingViewController?.view
            
            switch attachmentAnchor {
                case .rect: do {
                    if let sourceRect = mainView.popoverAttachmentAnchorBounds ?? sourceViewDescription?.globalBounds {
                        guard let presentingViewController = presentingViewController, let coordinateSpace = presentingViewController.view.window?.coordinateSpace else {
                            return
                        }
                        
                        popoverPresentationController?.sourceRect = presentingViewController.view.convert(sourceRect, from: coordinateSpace)
                    }
                }
                case .point(let point):
                    popoverPresentationController?.sourceRect = .init(origin: .init(x: point.x, y: point.y), size: .init(width: 1, height: 1))
                default:
                    break
            }
        }
        #endif
        
        if mainView.modalPresentationStyle != .automatic {
            assignIfNotEqual(.clear, to: &view.backgroundColor)
        }
    }
    
    @objc required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        #if os(iOS) || targetEnvironment(macCatalyst)
        if preferredContentSize == .zero {
            invalidatePreferredContentSize()
        }
        #endif
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        view.frame.size = size
    }
    
    open func invalidatePreferredContentSize() {
        #if os(iOS) || targetEnvironment(macCatalyst)
        if modalPresentationStyle == .popover {
            preferredContentSize = sizeThatFits(.init(targetSize: nil))
        }
        #endif
    }
}

#endif
