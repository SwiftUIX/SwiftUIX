//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// A type that manages view presentation.
public protocol DynamicViewPresenter: DynamicViewPresentable {
    #if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)
    /// The presentation coordinator for this presenter.
    var _cocoaPresentationCoordinator: CocoaPresentationCoordinator { get }
    #endif
    
    /// The presented item.
    var presented: DynamicViewPresentable? { get }
    
    /// Presents a new item.
    func present(_ item: AnyModalPresentation, completion: @escaping () -> Void)
    
    /// Dismisses the currently presented item (if any).
    func dismiss(withAnimation _: Animation?) -> Future<Bool, Never>
    
    @discardableResult
    func dismissSelf(withAnimation _: Animation?) -> Future<Bool, Never>
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
    
    @discardableResult
    public func dismiss() -> Future<Bool, Never> {
        dismiss(withAnimation: .default)
    }
    
    @discardableResult
    public func dismissSelf() -> Future<Bool, Never> {
        dismissSelf(withAnimation: .default)
    }
}

// MARK: - Extensions -

extension DynamicViewPresenter {
    public func present(_ modal: AnyModalPresentation) {
        present(modal, completion: { })
    }
    
    public func present(_ view: AnyPresentationView) {
        present(AnyModalPresentation(content: view), completion: { })
    }
    
    public func presentOnTop(_ modal: AnyModalPresentation) {
        topmostPresenter.present(modal, completion: { })
    }
    
    public func presentOnTop(_ view: AnyPresentationView) {
        topmostPresenter.present(AnyModalPresentation(content: view), completion: { })
    }
    
    public func present<Content: View>(@ViewBuilder content: () -> Content) {
        present(content())
    }
    
    public func present<V: View>(
        _ view: V,
        named name: AnyHashable? = nil,
        onDismiss: @escaping () -> Void = { },
        presentationStyle: ModalPresentationStyle? = nil,
        completion: @escaping () -> Void = { }
    ) {
        present(
            AnyModalPresentation(
                content: AnyPresentationView(view)
                    .name(name)
                    .modalPresentationStyle(presentationStyle ?? .automatic),
                onDismiss: onDismiss,
                reset: { }
            ),
            completion: completion
        )
    }
    
    public func presentOnTop<V: View>(
        _ view: V,
        named name: AnyHashable? = nil,
        onDismiss: @escaping () -> Void = { },
        presentationStyle: ModalPresentationStyle? = nil,
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
        presentationStyle: ModalPresentationStyle? = nil,
        @ViewBuilder content: @escaping () -> V
    ) {
        topmostPresenter.present(
            content(),
            presentationStyle: presentationStyle
        )
    }
}

extension DynamicViewPresenter {
    @discardableResult
    public func dismissTopmost(withAnimation animation: Animation?) -> Future<Bool, Never> {
        (topmostPresenter.presented as? DynamicViewPresenter ?? topmostPresenter).dismissSelf(withAnimation: animation)
    }
    
    @discardableResult
    public func dismissTopmost() -> Future<Bool, Never> {
        dismissTopmost(withAnimation: .default)
    }
    
    @discardableResult
    public func dismissView(named name: AnyHashable) -> Future<Bool, Never> {
        var presenter: DynamicViewPresenter? = self.presenter ?? self
        
        while let presented = presenter {
            if presented.presentationName == name {
                return presented.dismissSelf()
            }
            
            presenter = presented.presented as? DynamicViewPresenter
        }
        
        return .init({ $0(.success(false)) })
    }
    
    @discardableResult
    public func dismissView<H: Hashable>(named name: H) -> Future<Bool, Never> {
        dismissView(named: .init(name))
    }
}

// MARK: - Auxiliary Implementation -

private struct DynamicViewPresenterEnvironmentKey: EnvironmentKey {
    static let defaultValue: DynamicViewPresenter? = nil
}

extension EnvironmentValues {
    public var presenter: DynamicViewPresenter? {
        get {
            #if os(iOS) || os(tvOS) || os(macOS) || targetEnvironment(macCatalyst)
            return self[DynamicViewPresenterEnvironmentKey.self]
            #else
            return self[DynamicViewPresenterEnvironmentKey.self]
            #endif
        } set {
            self[DynamicViewPresenterEnvironmentKey.self] = newValue
        }
    }
}

// MARK: - Conformances -

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension UIViewController: DynamicViewPresenter {
    private static var presentationCoordinatorKey: UInt = 0
    
    public var _cocoaPresentationCoordinator: CocoaPresentationCoordinator {
        presentationCoordinator
    }
    
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
    
    public func present(_ presentation: AnyModalPresentation, completion: @escaping () -> Void) {
        presentationCoordinator.present(presentation, completion: completion)
    }
    
    @discardableResult
    public func dismiss(withAnimation animation: Animation?) -> Future<Bool, Never> {
        guard animation == nil || animation == .default else {
            assertionFailure()
            
            return .init({ $0(.success(false)) })
        }
        
        if presentingViewController != nil {
            return .init { attemptToFulfill in
                self.dismiss(animated: animation != nil) {
                    attemptToFulfill(.success(true))
                }
            }
        } else {
            return .init({ $0(.success(false)) })
        }
    }
    
    public func dismissSelf(withAnimation animation: Animation?) -> Future<Bool, Never> {
        guard animation == nil || animation == .default else {
            assertionFailure()
            
            return .init({ $0(.success(false)) })
        }
        
        return Future { attemptToFulfill in
            if let navigationController = self.navigationController, navigationController.viewControllers.count > 1, navigationController.topViewController == self {
                navigationController.popViewController(animated: animation != nil)
                attemptToFulfill(.success(true))
            } else if let presentingViewController = self.presentingViewController {
                presentingViewController.dismiss(animated: animation != nil) {
                    (self as? CocoaPresentationHostingController)?.presentation.reset()
                    
                    attemptToFulfill(.success(true))
                }
            } else {
                self.dismiss(animated: animation != nil, completion: nil)
                
                attemptToFulfill(.success(true))
            }
        }
    }
}

extension UIWindow: DynamicViewPresenter {
    public var _cocoaPresentationCoordinator: CocoaPresentationCoordinator {
        rootViewController?.presentationCoordinator ?? .init()
    }
    
    public var presented: DynamicViewPresentable? {
        rootViewController?.presented
    }
    
    public func present(_ presentation: AnyModalPresentation, completion: @escaping () -> Void) {
        rootViewController?.present(presentation, completion: completion)
    }
    
    @discardableResult
    public func dismiss(withAnimation animation: Animation?) -> Future<Bool, Never> {
        rootViewController?.dismiss(withAnimation: animation) ?? .init({ $0(.success(false)) })
    }
    
    public func dismissSelf(withAnimation animation: Animation?) -> Future<Bool, Never> {
        guard animation == nil || animation == .default else {
            assertionFailure()
            
            return .init({ $0(.success(false)) })
        }
        
        return Future { attemptToFulfill in
            self.isHidden = true
            self.isUserInteractionEnabled = false
            
            attemptToFulfill(.success((true)))
        }
    }
}

#elseif os(macOS)

extension NSViewController: DynamicViewPresenter {
    private static var presentationCoordinatorKey: UInt = 0
    
    public var _cocoaPresentationCoordinator: CocoaPresentationCoordinator {
        presentationCoordinator
    }
    
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
    
    public func present(_ presentation: AnyModalPresentation, completion: @escaping () -> Void) {
        presentationCoordinator.present(presentation, completion: completion)
    }
    
    @discardableResult
    public func dismiss(withAnimation animation: Animation?) -> Future<Bool, Never> {
        guard let presentedViewControllers = presentedViewControllers, !presentedViewControllers.isEmpty else {
            return .init({ $0(.success(false)) })
        }
        
        guard animation == nil || animation == .default else {
            assertionFailure()
            
            return .init({ $0(.success(false)) })
        }
        
        for controller in presentedViewControllers {
            dismiss(controller)
        }
        
        return .init({ $0(.success(true)) })
    }
    
    @discardableResult
    public func dismissSelf(withAnimation animation: Animation?) -> Future<Bool, Never> {
        guard animation == nil || animation == .default else {
            assertionFailure()
            
            return .init({ $0(.success(false)) })
        }
        
        return Future { attemptToFulfill in
            if let presentingViewController = self.presentingViewController {
                presentingViewController.dismiss(self)
                
                attemptToFulfill(.success(true))
            } else {
                attemptToFulfill(.success(false))
            }
        }
    }
}

extension NSWindow: DynamicViewPresenter {
    public var _cocoaPresentationCoordinator: CocoaPresentationCoordinator {
        contentViewController?.presentationCoordinator ?? .init()
    }
    
    public var presented: DynamicViewPresentable? {
        contentViewController?.presented
    }
    
    public func present(_ presentation: AnyModalPresentation, completion: @escaping () -> Void) {
        contentViewController?.present(presentation, completion: completion)
    }
    
    @discardableResult
    public func dismiss(withAnimation animation: Animation?) -> Future<Bool, Never> {
        contentViewController?.dismiss(withAnimation: animation) ?? .init({ $0(.success(false)) })
    }
    
    @discardableResult
    public func dismissSelf(withAnimation animation: Animation?) -> Future<Bool, Never> {
        guard animation == nil || animation == .default else {
            assertionFailure()
            
            return .init({ $0(.success(false)) })
        }
        
        return Future { attemptToFulfill in
            self.orderOut(self)
            self.setIsVisible(false)
            
            attemptToFulfill(.success((true)))
        }
    }
}

#endif
