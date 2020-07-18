//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A type that manages view presentation.
public protocol DynamicViewPresenter: DynamicViewPresentable, EnvironmentProvider {
    /// The presented item.
    var presented: DynamicViewPresentable? { get }
    
    /// Presents a new item.
    func present(_ item: AnyModalPresentation)
    
    /// Dismisses the currently presented item (if any).
    func dismiss(animated: Bool, completion: (() -> Void)?)
}

// MARK: - Implementation -

extension DynamicViewPresenter {
    /// A reference to the top-most presented item.
    public var topmostPresented: DynamicViewPresentable? {
        var presented = self.presented
        
        while let _presented = (presented as? DynamicViewPresenter)?.presented {
            presented = _presented
        }
        
        return presented
    }
    
    /// The top-most available presenter.
    public var topmostPresenter: DynamicViewPresenter {
        (topmostPresented as? DynamicViewPresenter) ?? self
    }
    
    /// Indicates whether a presenter is currently presenting.
    public var isPresenting: Bool {
        return presented != nil
    }
}

extension DynamicViewPresenter {
    public func present<V: View>(
        _ view: V,
        named name: ViewName? = nil,
        onDismiss: (() -> Void)? = nil,
        presentationStyle: ModalViewPresentationStyle? = nil,
        completion: @escaping () -> Void = { }
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
        onDismiss: (() -> Void)? = nil,
        presentationStyle: ModalViewPresentationStyle? = nil,
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
    
    public func presentOnTop<V: View>(
        presentationStyle: ModalViewPresentationStyle? = nil,
        @ViewBuilder content: @escaping () -> V
    ) {
        topmostPresenter.present(
            content(),
            presentationStyle: presentationStyle
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
            if presented.presentationName == name {
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

#elseif os(macOS)

extension NSViewController: DynamicViewPresenter {
    public func dismiss(animated: Bool, completion: (() -> Void)?) {
        guard let presentedViewControllers = presentedViewControllers, !presentedViewControllers.isEmpty else {
            return
        }
        
        for controller in presentedViewControllers {
            dismiss(controller)
        }
        
        completion?()
    }
    
    private static var presentationCoordinatorKey: Void = ()
    
    @objc open var presentationCoordinator: CocoaPresentationCoordinator {
        if let coordinator = objc_getAssociatedObject(self, &NSViewController.presentationCoordinatorKey) {
            return coordinator as! CocoaPresentationCoordinator
        } else {
            let coordinator = CocoaPresentationCoordinator(viewController: self)
            
            objc_setAssociatedObject(self, &NSViewController.presentationCoordinatorKey, coordinator, .OBJC_ASSOCIATION_RETAIN)
            
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

extension NSWindow: DynamicViewPresenter {
    public var presented: DynamicViewPresentable? {
        contentViewController?.presented
    }
    
    public func present(_ presentation: AnyModalPresentation) {
        contentViewController?.present(presentation)
    }
    
    public func dismiss(animated: Bool, completion: (() -> Void)?) {
        contentViewController?.dismiss(animated: animated, completion: completion)
    }
}

#endif
