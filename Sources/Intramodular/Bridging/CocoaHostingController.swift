//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

open class CocoaHostingController<Content: View>: UIHostingController<CocoaHostingControllerContent<Content>> {
    let presentation: CocoaPresentation?
    let presentationCoordinator: CocoaPresentationCoordinator
    let environment: EnvironmentValues?
    
    var _transitioningDelegate: UIViewControllerTransitioningDelegate?
    
    public override var description: String {
        if let name = rootViewContentName {
            return String(describing: name)
        } else {
            return super.description
        }
    }
    
    public var rootViewContent: Content {
        get {
            rootView.content
        } set {
            rootView.content = newValue
        }
    }
    
    public var rootViewContentName: ViewName? {
        (rootViewContent as? opaque_NamedView)?.name ?? (rootViewContent as? OpaqueView)?.name
    }
    
    init(
        rootView: Content,
        presentation: CocoaPresentation?,
        presentationCoordinator: CocoaPresentationCoordinator,
        environment: EnvironmentValues?
    ) {
        self.presentation = presentation
        self.presentationCoordinator = presentationCoordinator
        self.environment = environment
        
        super.init(
            rootView: CocoaHostingControllerContent(
                content: rootView,
                presentation: presentation,
                presentationCoordinator: presentationCoordinator,
                environment: environment
            )
        )
        
        presentationCoordinator.viewController = self
    }
    
    public convenience init(rootView: Content) {
        self.init(rootView: rootView, presentation: nil, presentationCoordinator: .init(), environment: nil)
    }
    
    public convenience init(@ViewBuilder rootView: () -> Content) {
        self.init(rootView: rootView())
    }
    
    @objc required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CocoaHostingController where Content == OpaqueView {
    convenience init(
        presentation: CocoaPresentation,
        presentationCoordinator: CocoaPresentationCoordinator
    ) {
        self.init(
            rootView: presentation.content(),
            presentation: presentation,
            presentationCoordinator: presentationCoordinator,
            environment: presentation.environment
        )
        
        _transitioningDelegate = presentation.style.transitioningDelegate
        modalPresentationStyle = .init(presentation.style)
        transitioningDelegate = _transitioningDelegate
        
        if presentation.style != .automatic {
            view.backgroundColor = .clear
        }
    }
}

// MARK: - Protocol Implementations -

extension CocoaHostingController: CocoaController {
    open func present(
        _ presentation: CocoaPresentation,
        animated: Bool,
        completion: @escaping () -> () = { }
    ) {
        presentationCoordinator.present(
            presentation,
            animated: animated,
            completion: completion
        )
    }
}

#endif
