//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

import SwiftUI

fileprivate struct AppKitOrUIKitViewControllerResolver: AppKitOrUIKitViewControllerRepresentable {
    class AppKitOrUIKitViewControllerType: AppKitOrUIKitViewController {
        var onInsertion: (AppKitOrUIKitViewController) -> Void = { _ in }
        var onAppear: (AppKitOrUIKitViewController) -> Void = { _ in }
        var onDisappear: (AppKitOrUIKitViewController) -> Void = { _ in }
        var onRemoval: (AppKitOrUIKitViewController) -> Void = { _ in }
        
        private weak var resolvedParent: AppKitOrUIKitViewController?
        
        private func resolveIfNecessary(withParent parent: AppKitOrUIKitViewController?) {
            guard let parent = parent, resolvedParent == nil else {
                return
            }
            
            resolvedParent = parent
            
            onInsertion(parent)
        }
        
        private func deresolveIfNecessary() {
            guard let parent = resolvedParent else {
                return
            }
            
            onRemoval(parent)
        }
        
        #if os(iOS) || os(tvOS)
        override func didMove(toParent parent: AppKitOrUIKitViewController?) {
            super.didMove(toParent: parent)
            
            if let parent = parent {
                resolveIfNecessary(withParent: parent)
            } else {
                deresolveIfNecessary()
            }
        }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            
            resolvedParent.map(onAppear)
        }
        
        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            
            resolvedParent.map(onDisappear)
        }
        #elseif os(macOS)
        override func loadView() {
            self.view = NSView()
            
            resolveIfNecessary(withParent: parent)
        }
        
        override func viewWillAppear() {
            super.viewWillAppear()
            
            resolveIfNecessary(withParent: view.nearestResponder(ofKind: NSViewController.self)?.root)
        }
        
        override func viewDidAppear() {
            super.viewDidAppear()
            
            resolvedParent.map(onAppear)
        }
        
        override func viewWillDisappear() {
            super.viewWillDisappear()
            
            resolvedParent.map(onDisappear)
            
            deresolveIfNecessary()
        }
        #endif
        
        override func removeFromParent() {
            super.removeFromParent()
            
            deresolveIfNecessary()
        }
    }
    
    var onInsertion: (AppKitOrUIKitViewController) -> Void
    var onAppear: (AppKitOrUIKitViewController) -> Void
    var onDisappear: (AppKitOrUIKitViewController) -> Void
    var onRemoval: (AppKitOrUIKitViewController) -> Void
    
    func makeAppKitOrUIKitViewController(context: Context) -> AppKitOrUIKitViewControllerType {
        #if os(iOS) || os(tvOS)
        AppKitOrUIKitViewControllerType()
        #elseif os(macOS)
        AppKitOrUIKitViewControllerType(nibName: nil, bundle: nil)
        #endif
    }
    
    func updateAppKitOrUIKitViewController(_ viewController: AppKitOrUIKitViewControllerType, context: Context) {
        viewController.onInsertion = onInsertion
        viewController.onAppear = onAppear
        viewController.onDisappear = onDisappear
        viewController.onRemoval = onRemoval
    }
}

// MARK: - API -

extension View {
    /// Resolve the nearest `UIViewController` or `NSViewController` in the view hierarchy.
    ///
    /// This usually tends to be SwiftUI's platform-specific adaptor.
    public func onAppKitOrUIKitViewControllerResolution(
        perform action: @escaping (AppKitOrUIKitViewController) -> ()
    ) -> some View {
        background(
            AppKitOrUIKitViewControllerResolver(
                onInsertion: action,
                onAppear: { _ in },
                onDisappear: { _ in },
                onRemoval: { _ in }
            )
            .allowsHitTesting(false)
            .accessibility(hidden: true)
        )
    }
    
    @_disfavoredOverload
    public func onAppKitOrUIKitViewControllerResolution(
        perform resolutionAction: @escaping (AppKitOrUIKitViewController) -> (),
        onAppear: @escaping (AppKitOrUIKitViewController) -> () = { _ in },
        onDisappear: @escaping (AppKitOrUIKitViewController) -> () = { _ in },
        onRemoval deresolutionAction: @escaping (AppKitOrUIKitViewController) -> () = { _ in }
    ) -> some View {
        background(
            AppKitOrUIKitViewControllerResolver(
                onInsertion: resolutionAction,
                onAppear: onAppear,
                onDisappear: onDisappear,
                onRemoval: deresolutionAction
            )
            .allowsHitTesting(false)
            .accessibility(hidden: true)
        )
    }
}

#if os(iOS) ||  os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)
public func withAppKitOrUIKitViewController<Content: View>(
    @ViewBuilder _ content: @escaping (AppKitOrUIKitViewController?) -> Content
) -> some View {
    withInlineState(initialValue: Optional<AppKitOrUIKitViewController>.none) { viewController in
        content(viewController.wrappedValue)
            .onAppKitOrUIKitViewControllerResolution { _viewController in
                if _viewController !== viewController.wrappedValue {
                    viewController.wrappedValue = _viewController
                }
            }
    }
}
#endif

// MARK: - Auxiliary Implementation -

#if os(macOS)
extension NSResponder {
    fileprivate func nearestResponder<Responder: NSResponder>(ofKind kind: Responder.Type) -> Responder? {
        guard !isKind(of: kind) else {
            return (self as! Responder)
        }
        
        return nextResponder?.nearestResponder(ofKind: kind)
    }
}

extension NSViewController {
    fileprivate var root: NSViewController {
        parent?.root ?? self
    }
}
#endif

#endif

struct _ResolveAppKitOrUIKitViewController: ViewModifier {
    #if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)
    @State var _appKitOrUIKitViewControllerBox = ObservableWeakReferenceBox<AppKitOrUIKitViewController>(nil)
    @State var presentationCoordinatorBox =
        ObservableWeakReferenceBox<CocoaPresentationCoordinator>(nil)
    #endif
    
    func body(content: Content) -> some View {
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        return content
            .modifier(_UseCocoaPresentationCoordinator(coordinator: presentationCoordinatorBox))
            .environment(\._appKitOrUIKitViewControllerBox, _appKitOrUIKitViewControllerBox)
            .environment(\.navigator, _appKitOrUIKitViewControllerBox.value?.navigationController)
            .onAppKitOrUIKitViewControllerResolution { viewController in
                if !(_appKitOrUIKitViewControllerBox.value === viewController) {
                    _appKitOrUIKitViewControllerBox.value = viewController
                }
                
                if !(presentationCoordinatorBox.value === viewController._cocoaPresentationCoordinator) {
                    presentationCoordinatorBox.value =
                        viewController.presentationCoordinator
                }
            }
        #else
        return content
        #endif
    }
}
