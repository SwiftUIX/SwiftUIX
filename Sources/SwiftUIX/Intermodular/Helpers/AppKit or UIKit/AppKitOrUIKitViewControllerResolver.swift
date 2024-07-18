//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

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
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
        }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            
            #if targetEnvironment(macCatalyst)
            if resolvedParent == nil {
                resolveIfNecessary(withParent: view.superview?._nearestResponder(ofKind: UIViewController.self))
            }
            #endif

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
        #if os(iOS) || os(tvOS) || os(visionOS)
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

// MARK: - API

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
        perform resolutionAction: @escaping (AppKitOrUIKitViewController) -> () = { _ in },
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

#if os(iOS) ||  os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
@MainActor
@ViewBuilder
public func withAppKitOrUIKitViewController<Content: View>(
    @ViewBuilder _ content: @escaping (AppKitOrUIKitViewController?) -> Content
) -> some View {
    if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
        _WithAppKitOrUIKitViewController(content: content)
    } else {
        withInlineState(initialValue: _SwiftUIX_ObservableWeakReferenceBox<AppKitOrUIKitViewController>(nil)) { viewControllerBox in
            withInlineObservedObject(viewControllerBox.wrappedValue) { box in
                content(box.value)
            }
            .onAppKitOrUIKitViewControllerResolution { viewController in
                if viewController !== viewControllerBox.wrappedValue.value {
                    viewControllerBox.wrappedValue.value = viewController
                }
            }
        }
    }
}
#endif

// MARK: - Auxiliary

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

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
private struct _WithAppKitOrUIKitViewController<Content: View>: View {
    let content: (AppKitOrUIKitViewController?) -> Content

    @StateObject private var appKitOrUIKitViewControllerBox = _SwiftUIX_ObservableWeakReferenceBox<AppKitOrUIKitViewController>(nil)

    var body: some View {
        content(appKitOrUIKitViewControllerBox.value)
            .onAppKitOrUIKitViewControllerResolution { viewController in
                if viewController !== appKitOrUIKitViewControllerBox.value {
                    DispatchQueue.main.async {
                        appKitOrUIKitViewControllerBox.value = viewController
                    }
                }
            }
    }
}

private struct _ResolveAppKitOrUIKitViewController: ViewModifier {
    @State var _appKitOrUIKitViewControllerBox = _SwiftUIX_ObservableWeakReferenceBox<AppKitOrUIKitViewController>(nil)
    @State var presentationCoordinatorBox = _SwiftUIX_ObservableWeakReferenceBox<CocoaPresentationCoordinator>(nil)

    init(_ appKitOrUIKitViewController: AppKitOrUIKitViewController?) {
        self._appKitOrUIKitViewControllerBox = .init(appKitOrUIKitViewController)
    }

    init() {

    }

    func body(content: Content) -> some View {
        PassthroughView {
            #if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
            content
                .modifier(ProvideNavigator(_appKitOrUIKitViewControllerBox: _appKitOrUIKitViewControllerBox))
            #elseif os(macOS)
            content
            #endif
        }
        .modifier(_UseCocoaPresentationCoordinator(coordinator: presentationCoordinatorBox))
        .environment(\._appKitOrUIKitViewControllerBox, _appKitOrUIKitViewControllerBox)
        .onAppKitOrUIKitViewControllerResolution { [weak _appKitOrUIKitViewControllerBox, weak presentationCoordinatorBox] viewController in
            guard let _appKitOrUIKitViewControllerBox = _appKitOrUIKitViewControllerBox, let presentationCoordinatorBox = presentationCoordinatorBox else {
                return
            }

            DispatchQueue.main.async {
                if !(_appKitOrUIKitViewControllerBox.value === viewController) {
                    _appKitOrUIKitViewControllerBox.value = viewController
                }

                if !(presentationCoordinatorBox.value === viewController._cocoaPresentationCoordinator) {
                    presentationCoordinatorBox.value =
                    viewController.presentationCoordinator
                }
            }
        }
        .background {
            ZeroSizeView()
                .id(_appKitOrUIKitViewControllerBox.value.map(ObjectIdentifier.init))
        }
    }

    #if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
    private struct ProvideNavigator: ViewModifier {
        struct Navigator: SwiftUIX.Navigator {
            weak var base: AppKitOrUIKitViewController?

            private var nearestNavigator: _UINavigationControllerNavigatorAdaptorBox? {
                base?.nearestNavigationController.map(_UINavigationControllerNavigatorAdaptorBox.init(navigationController:))
            }

            func push<V: View>(_ view: V, withAnimation animation: Animation?) {
                nearestNavigator?.push(view, withAnimation: animation)
            }

            func pop(withAnimation animation: Animation?) {
                nearestNavigator?.pop(withAnimation: animation)
            }

            func popToRoot(withAnimation animation: Animation?) {
                nearestNavigator?.popToRoot(withAnimation: animation)
            }
        }

        @ObservedObject var _appKitOrUIKitViewControllerBox: _SwiftUIX_ObservableWeakReferenceBox<AppKitOrUIKitViewController>

        func body(content: Content) -> some View {
            content.environment(\.navigator, Navigator(base: _appKitOrUIKitViewControllerBox.value))
        }
    }
    #endif
}

#endif

extension View {
    #if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
    public func _resolveAppKitOrUIKitViewController(
        with viewController: AppKitOrUIKitViewController?
    ) -> some View {
        modifier(_ResolveAppKitOrUIKitViewController(viewController))
    }
    #endif

    public func _resolveAppKitOrUIKitViewControllerIfAvailable() -> some View {
        #if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)
        modifier(_ResolveAppKitOrUIKitViewController())
        #else
        self
        #endif
    }
}
