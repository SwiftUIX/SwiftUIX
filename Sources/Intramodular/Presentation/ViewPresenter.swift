//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol DynamicViewPresenter: PresentationManager {
    var presenting: DynamicViewPresenter? { get }
    var presented: DynamicViewPresenter? { get }
    var presentedViewName: ViewName? { get }
    
    func present(_ presentation: AnyModalPresentation)
    
    func dismiss(completion: @escaping () -> Void)
    func dismissView(named _: ViewName, completion: @escaping () -> Void)
}

// MARK: - Implementation -

extension DynamicViewPresenter {
    public var topmostPresented: DynamicViewPresenter? {
        var presented = self.presented
        
        while let _presented = presented?.presented {
            presented = _presented
        }
        
        return presented
    }
    
    public var topmostPresenter: DynamicViewPresenter {
        topmostPresented ?? self
    }
    
    public var isPresented: Bool {
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
                content: { view },
                contentName: name,
                completion: completion,
                shouldDismiss: { true },
                onDismiss: onDismiss,
                resetBinding: { },
                presentationStyle: presentationStyle
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
    public func dismiss() {
        dismiss(completion: { })
    }
    
    public func dismissTopmost() {
        topmostPresenter.presenting?.dismiss()
    }
    
    public func dismissView(
        named name: ViewName,
        completion: @escaping () -> Void
    ) {
        var presenter: DynamicViewPresenter? = presenting ?? self
        
        while let presented = presenter {
            if presented.presentedViewName == name {
                presented.dismiss(completion: completion)
                break
            }
            
            presenter = presented.presented
        }
    }
    
    public func dismissView<H: Hashable>(named name: H) {
        dismissView(named: .init(name), completion: { })
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
