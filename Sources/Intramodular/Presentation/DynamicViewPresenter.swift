//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A type that manages view presentation.
public protocol DynamicViewPresenter: DynamicViewPresentable, EnvironmentProvider, PresentationManager {
    var presented: DynamicViewPresentable? { get }
    
    func present(_ presentation: AnyModalPresentation)
    
    func dismiss(animated: Bool, completion: (() -> Void)?)
}

// MARK: - Implementation -

extension DynamicViewPresenter {
    public var topmostPresented: DynamicViewPresentable? {
        var presented = self.presented
        
        while let _presented = (presented as? DynamicViewPresenter)?.presented {
            presented = _presented
        }
        
        return presented
    }
    
    public var topmostPresenter: DynamicViewPresenter {
        (topmostPresented as? DynamicViewPresenter) ?? self
    }
    
    public var isPresenting: Bool {
        return presented != nil
    }
}

extension DynamicViewPresenter {
    public func present<V: View>(
        _ view: V,
        named name: ViewName? = nil,
        onDismiss: @escaping () -> Void = { },
        presentationStyle: ModalViewPresentationStyle = .automatic,
        completion: @escaping () -> () = { }
    ) {
        present(
            .init(
                content: view,
                contentName: name,
                presentationStyle: presentationStyle,
                onPresent: completion,
                onDismiss: onDismiss,
                resetBinding: { }
            )
        )
    }
    
    public func presentOnTop<V: View>(
        _ view: V,
        named name: ViewName? = nil,
        onDismiss: @escaping () -> Void = { },
        presentationStyle: ModalViewPresentationStyle = .automatic,
        completion: @escaping () -> () = { }
    ) {
        topmostPresenter.present(
            view,
            named: name,
            onDismiss: onDismiss,
            presentationStyle: presentationStyle,
            completion: completion
        )
    }
}

extension DynamicViewPresenter {
    public func dismiss(completion: (() -> Void)?) {
        dismiss(animated: true, completion: completion)
    }
    
    public func dismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    public func dismissSelf() {
        presenter?.dismiss()
    }
    
    public func dismissTopmost() {
        topmostPresenter.presenter?.dismiss()
    }
    
    public func dismissTopmost(
        animated: Bool = true,
        completion: @escaping () -> Void
    ) {
        topmostPresenter.presenter?.dismiss(animated: animated, completion: completion)
    }
    
    public func dismissView(
        named name: ViewName,
        completion: (() -> Void)?
    ) {
        var presenter: DynamicViewPresenter? = self.presenter ?? self
        
        while let presented = presenter {
            if presented.name == name {
                presented.presenter?.dismiss(completion: completion)
                
                return
            }
            
            presenter = presented.presented as? DynamicViewPresenter
        }
        
        completion?()
    }
    
    public func dismissView<H: Hashable>(named name: H) {
        dismissView(named: .init(name), completion: nil)
    }
}

// MARK: - Auxiliary Implementation -

private struct DynamicViewPresenterEnvironmentKey: EnvironmentKey {
    static let defaultValue: DynamicViewPresenter? = nil
}

extension EnvironmentValues {
    public var dynamicViewPresenter: DynamicViewPresenter? {
        get {
            self[DynamicViewPresenterEnvironmentKey.self]
        } set {
            self[DynamicViewPresenterEnvironmentKey.self] = newValue
        }
    }
}

// MARK: - Concrete Implementations -

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension UIViewController: DynamicViewPresenter {
    private static var presentationCoordinatorKey: Void = ()
        
    @objc open var presentationCoordinator: CocoaPresentationCoordinator {
        if let coordinator = objc_getAssociatedObject(self, &UIViewController.presentationCoordinatorKey) {
            return coordinator as! CocoaPresentationCoordinator
        } else {
            let coordinator = CocoaPresentationCoordinator(viewController: self)
            
            objc_setAssociatedObject(self, &UIViewController.presentationCoordinatorKey, coordinator, .OBJC_ASSOCIATION_RETAIN)
            
            return coordinator
        }
    }
    
    public var presented: DynamicViewPresentable? {
        presentationCoordinator.presented
    }
    
    public func present(_ presentation: AnyModalPresentation) {
        presentationCoordinator.present(presentation)
    }
}

extension UIWindow: DynamicViewPresenter {
    public var presented: DynamicViewPresentable? {
        rootViewController?.presented
    }
        
    public func present(_ presentation: AnyModalPresentation) {
        rootViewController?.present(presentation)
    }
    
    public func dismiss(animated: Bool, completion: (() -> Void)?) {
        rootViewController?.dismiss(animated: animated, completion: completion)
    }
}

#endif
