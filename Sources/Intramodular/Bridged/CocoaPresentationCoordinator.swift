//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

@objc public class CocoaPresentationCoordinator: NSObject, ObservableObject {
    public var environmentBuilder = EnvironmentBuilder()
    
    private let presentation: AnyModalPresentation?
    
    public var presentingCoordinator: CocoaPresentationCoordinator? {
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        if let presentingViewController = viewController.presentingViewController {
            return presentingViewController.presentationCoordinator
        } else if let navigationController = viewController.navigationController {
            return navigationController.viewController(before: viewController)?.presentationCoordinator
        } else {
            return nil
        }
        #elseif os(macOS)
        if let presentingViewController = viewController.presentingViewController {
            return presentingViewController.presentationCoordinator
        } else {
            return nil
        }
        #endif
    }
    
    public var presentedCoordinator: CocoaPresentationCoordinator? {
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        if let presentedViewController = viewController.presentedViewController {
            return presentedViewController.presentationCoordinator
        } else if let navigationController = viewController.navigationController {
            return navigationController.viewController(after: viewController)?.presentationCoordinator
        } else {
            return nil
        }
        #elseif os(macOS)
        if let presentedViewControllers = viewController.presentedViewControllers, presentedViewControllers.count == 1 {
            return presentedViewControllers.first?.presentationCoordinator
        } else {
            return nil
        }
        #endif
    }
    
    fileprivate weak var viewController: AppKitOrUIKitViewController!
    
    public init(
        presentation: AnyModalPresentation? = nil,
        viewController: AppKitOrUIKitViewController? = nil
    ) {
        self.presentation = presentation
        self.viewController = viewController
    }
    
    func setViewController(_ viewController: AppKitOrUIKitViewController) {
        guard self.viewController == nil else {
            return assertionFailure()
        }
        
        self.viewController = viewController
    }
    
    func setIsModalInPresentation(_ isActive: Bool) {
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        viewController.isModalInPresentation = isActive
        #elseif os(macOS)
        viewController.view.window?.standardWindowButton(NSWindow.ButtonType.closeButton)!.isHidden = isActive
        viewController.view.window?.standardWindowButton(NSWindow.ButtonType.miniaturizeButton)!.isHidden = isActive
        #endif
    }
}

extension CocoaPresentationCoordinator {
    public override var description: String {
        if let name = presentationName {
            return "Bridged Presentation Coordinator (" + name.description + ")"
        } else {
            return "Bridged Presentation Coordinator"
        }
    }
}

// MARK: - Conformances -

extension CocoaPresentationCoordinator: DynamicViewPresenter {
    public var presenter: DynamicViewPresenter? {
        presentingCoordinator
    }
    
    public var presented: DynamicViewPresentable? {
        presentedCoordinator
    }
    
    public var presentationName: ViewName? {
        presentation?.content._opaque_getViewName()
    }
    
    public func setPresentation(_ presentation: AnyModalPresentation?) {
        if let presentation = presentation {
            present(presentation)
        } else {
            dismiss()
        }
    }
    
    public func present(_ modal: AnyModalPresentation) {
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        if let viewController = viewController.presentedViewController as? CocoaPresentationHostingController, viewController.modalViewPresentationStyle == modal.content.modalPresentationStyle {
            viewController.presentation = modal
            return
        }
        
        let viewControllerToBePresented = CocoaPresentationHostingController(
            presentingViewController: viewController,
            presentation: modal,
            coordinator: .init(presentation: modal)
        )
        
        viewController.present(
            viewControllerToBePresented,
            animated: true
        ) {
            viewControllerToBePresented.presentationController?.delegate = self
            
            self.objectWillChange.send()
        }
        #elseif os(macOS)
        fatalError("unimplemented")
        #endif
    }
    
    @discardableResult
    public func dismiss(withAnimation animation: Animation?) -> Future<Bool, Never> {
        guard isPresenting else {
            return .init({ $0(.success(false)) })
        }
        
        guard let viewController = viewController else {
            return .init({ $0(.success(false)) })
        }
        
        let presentation = presentedCoordinator?.presentation
        
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        return .init { attemptToFulfill in
            if viewController.presentedViewController != nil {
                self.objectWillChange.send()
                
                viewController.dismiss(animated: animation != nil) {
                    presentation?.reset()
                    
                    attemptToFulfill(.success(true))
                }
            } else if let navigationController = viewController.navigationController {
                self.objectWillChange.send()
                
                navigationController.popToViewController(viewController, animated: animation != nil) {
                    presentation?.reset()
                    
                    attemptToFulfill(.success(true))
                }
            }
        }
        #elseif os(macOS)
        fatalError("unimplemented")
        #endif
    }
    
    @discardableResult
    public func dismissSelf(withAnimation animation: Animation?) -> Future<Bool, Never> {
        viewController.dismissSelf(withAnimation: animation)
    }
}

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension CocoaPresentationCoordinator: UIAdaptivePresentationControllerDelegate {
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        #if !os(tvOS)
        if controller is UIPopoverPresentationController {
            return .none
        }
        #endif
        
        if let presentation = presentation {
            return .init(presentation.content.modalPresentationStyle)
        } else {
            return .automatic
        }
    }
    
    public func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
        (viewController?.isModalInPresentation).map({ !$0 }) ?? true
    }
    
    public func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        objectWillChange.send()
    }
    
    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        (presentationController.presentedViewController as? CocoaPresentationHostingController)?.presentation.reset()
        
        presentationController.presentingViewController.presentationCoordinator.objectWillChange.send()
    }
    
    public func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        
    }
}

#endif

#if os(iOS) && !os(tvOS)

extension CocoaPresentationCoordinator: UIPopoverPresentationControllerDelegate {
    public func popoverPresentationController(
        _ popoverPresentationController: UIPopoverPresentationController,
        willRepositionPopoverTo rect: UnsafeMutablePointer<CGRect>,
        in view: AutoreleasingUnsafeMutablePointer<UIView>
    ) {
        guard let presentedViewController = popoverPresentationController.presentedViewController as? CocoaPresentationHostingController else {
            return
        }
        
        guard let bounds = presentedViewController.presentation.content.popoverAttachmentAnchorBounds else {
            return
        }
        
        guard let presentingViewController = popoverPresentationController.presentedViewController.presentingViewController else {
            return
        }
        
        guard let coordinateSpace = presentingViewController.view.window?.coordinateSpace else {
            return
        }
        
        rect.pointee = presentingViewController.view.convert(bounds, from: coordinateSpace)
    }
}

#endif

struct _UseCocoaPresentationCoordinator: ViewModifier {
    let coordinator: CocoaPresentationCoordinator?
    
    func body(content: Content) -> some View {
        content
            .environment(\.presenter, coordinator)
            .environment(\.presentationManager, CocoaPresentationMode(coordinator: coordinator))
            .onPreferenceChange(_NamedViewDescription.PreferenceKey.self, perform: {
                if let parent = self.coordinator?.viewController as? _opaque_CocoaController {
                    for description in $0 {
                        parent._setNamedViewDescription(description, for: description.name)
                    }
                }
            })
            .onPreferenceChange(AnyModalPresentation.PreferenceKey.self) { presentation in
                self.coordinator?.setPresentation(presentation)
            }
            .onPreferenceChange(IsModalInPresentation.self) {
                self.coordinator?.setIsModalInPresentation($0)
            }
            .preference(key: AnyModalPresentation.PreferenceKey.self, value: nil)
            .preference(key: IsModalInPresentation.self, value: false)
    }
}

#endif
