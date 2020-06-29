//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || os(macOS) || targetEnvironment(macCatalyst)

open class CocoaHostingController<Content: View>: AppKitOrUIKitHostingController<CocoaHostingControllerContent<Content>>, CocoaController {
    public let _presentationCoordinator: CocoaPresentationCoordinator
    
    override public var presentationCoordinator: CocoaPresentationCoordinator {
        return _presentationCoordinator
    }
    
    public var rootViewContent: Content {
        get {
            rootView.content
        } set {
            rootView.content = newValue
        }
    }
    
    public var subviewDescriptions: [ViewDescription] = []
    
    init(
        rootView: Content,
        presentationCoordinator: CocoaPresentationCoordinator
    ) {
        self._presentationCoordinator = presentationCoordinator
        
        super.init(rootView: .init(
                    parent: nil,
                    content: rootView,
                    presentationCoordinator: presentationCoordinator)
        )
        
        presentationCoordinator.setViewController(self)
        
        self.rootView.parent = self
        
        if let rootView = rootView as? EnvironmentalAnyView {
            environmentBuilder.merge(rootView.presentationEnvironmentBuilder)
            
            #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
            #if os(iOS) || targetEnvironment(macCatalyst)
            hidesBottomBarWhenPushed = rootView.hidesBottomBarWhenPushed
            #endif
            isModalInPresentation = !rootView.isModalDismissable
            modalPresentationStyle = .init(rootView.presentationStyle)
            transitioningDelegate = rootView.presentationStyle.transitioningDelegate
            #elseif os(macOS)
            fatalError("unimplemented")
            #endif
        }
    }
    
    public convenience init(rootView: Content) {
        self.init(rootView: rootView, presentationCoordinator: .init())
    }
    
    public convenience init(@ViewBuilder rootView: () -> Content) {
        self.init(rootView: rootView())
    }
    
    @objc required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let window = view.window, window.canResizeToFitContent {
            window.frame.size = sizeThatFits(in: Screen.main.bounds.size)
        }
    }
    #elseif os(macOS)
    override open func viewDidLayout() {
        super.viewDidLayout()
        
        preferredContentSize = sizeThatFits(in: Screen.main.bounds.size)
    }
    #endif
    
    public func description(for name: ViewName) -> ViewDescription? {
        subviewDescriptions.first(where: { $0.name ~= name })
    }
}

#endif
