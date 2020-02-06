//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

open class CocoaHostingController<Content: View>: UIHostingController<CocoaHostingControllerContent<Content>> {
    public let presentationCoordinator: CocoaPresentationCoordinator
    
    public override var description: String {
        rootViewName.map(String.init(describing:)) ?? super.description
    }
    
    public var rootViewContent: Content {
        get {
            rootView.content
        } set {
            rootView.content = newValue
        }
    }
    
    public var rootViewName: ViewName? {
        nil
            ?? rootView.presentation?.contentName
            ?? (rootViewContent as? opaque_NamedView)?.name
    }
    
    init(
        rootView: Content,
        presentation: AnyModalPresentation?,
        presentationCoordinator: CocoaPresentationCoordinator
    ) {
        self.presentationCoordinator = presentationCoordinator
        
        super.init(
            rootView: CocoaHostingControllerContent(
                content: rootView,
                presentation: presentation,
                presentationCoordinator: presentationCoordinator
            )
        )
        
        presentationCoordinator.viewController = self
        
        if let presentation = presentation {
            modalPresentationStyle = .init(presentation.presentationStyle)
            transitioningDelegate = presentation.presentationStyle.transitioningDelegate
            
            if presentation.presentationStyle != .automatic {
                view.backgroundColor = .clear
            }
        }
    }
    
    public convenience init(rootView: Content) {
        self.init(
            rootView: rootView,
            presentation: nil,
            presentationCoordinator: .init()
        )
    }
    
    public convenience init(@ViewBuilder rootView: () -> Content) {
        self.init(rootView: rootView())
    }
    
    @objc required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CocoaHostingController where Content == EnvironmentalAnyView {
    convenience init(
        presentation: AnyModalPresentation,
        presentationCoordinator: CocoaPresentationCoordinator
    ) {
        self.init(
            rootView: presentation.content(),
            presentation: presentation,
            presentationCoordinator: presentationCoordinator
        )
    }
}

#endif
