//
// Copyright (c) Vatsal Manot
//

import SwiftUI

/// A replacement for the buggy (as of Xcode 11 b3) `PresentationLink`.
public struct PresentationLink2<Label: View, Destination: View>: View {
    public let destination: Destination

    let _label: () -> Label

    public var label: Label {
        return _label()
    }

    public init(destination: Destination, label: @escaping () -> Label) {
        self.destination = destination
        self._label = label
    }

    public var body: some View {
        _label().tapAction {
            UIApplication
                .topMostViewController?
                .present(UIHostingController(rootView: self.destination), animated: true)
        }
    }
}

// MARK: - Helpers -

extension UIApplication {
    static var topMostViewController: UIViewController? {
        return UIApplication
            .shared
            .windows
            .last?
            .rootViewController?
            .visibleViewController
    }
}

extension UIViewController {
    /// https://stackoverflow.com/a/45473125/2747515
    fileprivate var visibleViewController: UIViewController? {
        if let navigationController = self as? UINavigationController {
            return navigationController.topViewController?.visibleViewController
        } else if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.visibleViewController
        } else if let presentedViewController = presentedViewController {
            return presentedViewController.visibleViewController
        } else {
            return self
        }
    }
}

