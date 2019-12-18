//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

class CocoaPresentationCoordinator: NSObject, UIAdaptivePresentationControllerDelegate {
    private var sheet: CocoaPresentation?
    private weak var presentingCoordinator: CocoaPresentationCoordinator?
    
    var onDidAttemptToDismiss: [CocoaPresentationDidAttemptToDismissCallback] = []
    
    weak var viewController: UIViewController? {
        didSet {
            viewController?.presentationController?.delegate = self
        }
    }
    
    var presentedCoordinator: CocoaPresentationCoordinator?
    
    override init() {
        self.sheet = nil
        self.presentingCoordinator = nil
    }
    
    init(sheet: CocoaPresentation? = nil, presentingCoordinator: CocoaPresentationCoordinator? = nil) {
        self.sheet = sheet
        self.presentingCoordinator = presentingCoordinator
    }
    
    func present(sheet: CocoaPresentation) {
        if let presentedSheet = presentedCoordinator?.sheet {
            if presentedSheet.shouldDismiss() {
                presentedCoordinator?.dismiss()
            } else {
                return
            }
        }
        
        let coordinator = CocoaPresentationCoordinator(sheet: sheet, presentingCoordinator: self)
        
        let rootView =
            _CocoaPresentationView(coordinator: coordinator) {
                sheet.content()
        }
        
        let viewController = UIHostingController(rootView: rootView)
        
        viewController.modalPresentationStyle = .init(sheet.presentationStyle)
        viewController.view.backgroundColor = .clear
        
        coordinator.viewController = viewController
        
        presentedCoordinator = coordinator
        
        self.viewController?.present(viewController, animated: true)
    }
    
    func dismissPresentedSheet() {
        guard let presentedCoordinator = presentedCoordinator, let sheet = presentedCoordinator.sheet else {
            return
        }
        
        if let viewController = presentedCoordinator.viewController {
            presentedCoordinator.viewController = nil
            viewController.dismiss(animated: true)
        }
        
        self.presentedCoordinator = nil
        
        if !sheet.shouldDismiss() {
            sheet.resetBinding()
        }
        
        sheet.onDismiss?()
    }
    
    func dismiss() {
        guard let presentingCoordinator = presentingCoordinator, presentingCoordinator.presentedCoordinator === self else { return }
        presentingCoordinator.dismissPresentedSheet()
    }
    
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        for callback in onDidAttemptToDismiss {
            callback.action()
        }
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        viewController = nil
        dismiss()
    }
}

#endif
