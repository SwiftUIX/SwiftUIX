//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

/// An interface that exposes navigation functionality.
public protocol Navigator {
    /// Pushes a view onto the navigation stack.
    func push<V: View>(_ view: V, withAnimation animation: Animation?)

    /// Pops the top view from the navigation stack.
    func pop(withAnimation animation: Animation?)

    /// Pops the whole navigation stack.
    func popToRoot(withAnimation animation: Animation?)
}

// MARK: - Extensions -

extension Navigator {
    public func push<V: View>(_ view: V) {
        push(view, withAnimation: .default)
    }

    public func pop() {
        pop(withAnimation: .default)
    }

    public func popToRoot() {
        popToRoot(withAnimation: .default)
    }
}

// MARK: - Helpers -

extension EnvironmentValues {
    private struct NavigatorEnvironmentKey: EnvironmentKey {
        static var defaultValue: Navigator? {
            return nil
        }
    }

    public var navigator: Navigator? {
        get {
            self[NavigatorEnvironmentKey.self]
        } set {
            self[NavigatorEnvironmentKey.self] = newValue
        }
    }
}

// MARK: - Conformances -

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

/// A box for `UINavigationController` that adapts it to a `Navigator`.
///
/// This box is required to prevent a retain-cycle when accessing the navigator via `EnvironmentValues`.
struct _UINavigationControllerNavigatorAdaptorBox: Navigator {
    weak var navigationController: UINavigationController?

    public func push<V: View>(_ view: V, withAnimation animation: Animation?) {
        guard let navigationController = navigationController else {
            return assertionFailure()
        }

        if !(animation == nil || animation == .default) {
            assertionFailure("The animation passed to popToRoot(withAnimation:) must either be `.default` or `nil`")
        }

        navigationController.pushViewController(CocoaHostingController(mainView: view), animated: animation == .default)
    }

    public func pop(withAnimation animation: Animation?) {
        guard let navigationController = navigationController else {
            return assertionFailure()
        }

        if !(animation == nil || animation == .default) {
            assertionFailure("The animation passed to popToRoot(withAnimation:) must either be `.default` or `nil`")
        }

        navigationController.popViewController(animated: animation == .default)
    }

    public func popToRoot(withAnimation animation: Animation?) {
        guard let navigationController = navigationController else {
            return assertionFailure()
        }

        if !(animation == nil || animation == .default) {
            assertionFailure("The animation passed to popToRoot(withAnimation:) must either be `.default` or `nil`")
        }

        navigationController.popToRootViewController(animated: animation == .default)
    }
}

#endif
