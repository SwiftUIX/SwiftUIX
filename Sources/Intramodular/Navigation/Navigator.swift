//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public protocol Navigator: DynamicViewPresenter {
    func push<V: View>(_: V)
    func pop()
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

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension UINavigationController: Navigator {
    public func push<V: View>(_ view: V) {
        pushViewController(CocoaHostingController(rootView: view), animated: true)
    }
    
    public func pop() {
        popViewController(animated: true)
    }
}

#endif
