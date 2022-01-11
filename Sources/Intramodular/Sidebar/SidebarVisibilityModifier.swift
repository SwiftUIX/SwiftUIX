//
// Copyright (c) Vatsal Manot
//

import SwiftUI

#if os(iOS)

@available(iOS 14.0, *)
struct SidebarVisibilityModifier: ViewModifier {
    var isSidebarInitiallyVisible: Bool

    func body(content: Content) -> some View {
        content.background {
            AppKitOrUIKitSidebarIntrospector(isSidebarInitiallyVisible: isSidebarInitiallyVisible)
        }
    }
}

// MARK: - API -

public enum _SidebarVisibility {
    case automatic
    case visible
    case hidden
}

extension View {
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    public func initialSidebarVisibility(_ visibility: Visibility) -> some View {
        modifier(SidebarVisibilityModifier(isSidebarInitiallyVisible: visibility == .visible))
    }
    
    @_disfavoredOverload
    @available(iOS 14.0, macOS 12.0, tvOS 14.0, *)
    public func initialSidebarVisibility(_ visibility: _SidebarVisibility) -> some View {
        modifier(SidebarVisibilityModifier(isSidebarInitiallyVisible: visibility == .visible))
    }
}

// MARK: - Underlying Implementation -

@available(iOS 14.0, *)
extension SidebarVisibilityModifier {
    struct AppKitOrUIKitSidebarIntrospector: UIViewControllerRepresentable {
        var isSidebarInitiallyVisible: Bool

        func makeUIViewController(context: Context) -> AppKitOrUIKitViewControllerType {
            .init(isSidebarInitiallyVisible: isSidebarInitiallyVisible)
        }

        func updateUIViewController(_ uiViewController: AppKitOrUIKitViewControllerType, context: Context) {
            uiViewController.isSidebarInitiallyVisible = isSidebarInitiallyVisible
        }
    }
}

@available(iOS 14.0, *)
extension SidebarVisibilityModifier.AppKitOrUIKitSidebarIntrospector {
    class AppKitOrUIKitViewControllerType: UIViewController {
        var isSidebarInitiallyVisible: Bool

        var didApplyInitialSidebarConfiguration: Bool = false

        init(isSidebarInitiallyVisible: Bool) {
            self.isSidebarInitiallyVisible = isSidebarInitiallyVisible

            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func didMove(toParent parent: UIViewController?) {
            super.didMove(toParent: parent)

            applyInitialSidebarConfigurationIfNecessary()
        }

        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)

            applyInitialSidebarConfigurationIfNecessary()
        }

        private func applyInitialSidebarConfigurationIfNecessary() {
            guard !didApplyInitialSidebarConfiguration else {
                return
            }

            if let splitViewController = nearestSplitViewController {
                if isSidebarInitiallyVisible && splitViewController.displayMode == .secondaryOnly {
                    UIView.performWithoutAnimation {
                        splitViewController.show(.primary)
                    }
                }

                didApplyInitialSidebarConfiguration = true
            }
        }
    }
}

#endif
