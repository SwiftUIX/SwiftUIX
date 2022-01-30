//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

fileprivate struct HideTitleBar: ViewModifier {
    let isHidden: Bool
    
    func body(content: Content) -> some View {
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        withAppKitOrUIKitViewController { viewController in
            content
                .onAppear(perform: { updateTitlebar(for: viewController) })
                .onChange(of: viewController, perform: { updateTitlebar(for: $0) })
                .onChange(of: isHidden, perform: { _ in updateTitlebar(for: viewController) })
        }
        #else
        return content
        #endif
    }
    
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    private func updateTitlebar(for viewController: AppKitOrUIKitViewController?) {
        #if targetEnvironment(macCatalyst)
        guard let windowScene = viewController?.view.window?.windowScene else {
            return
        }
        
        if let titlebar = windowScene.titlebar {
            if isHidden {
                titlebar.titleVisibility = .hidden
            } else {
                titlebar.titleVisibility = .visible
            }
        }
        #endif
    }
    #endif
}

extension View {
    /// Hides the title bar (if any) for this view.
    ///
    /// See https://developer.apple.com/documentation/uikit/mac_catalyst/removing_the_title_bar_in_your_mac_app_built_with_mac_catalyst for more details.
    @available(watchOS, unavailable)
    public func titleBarHidden(_ hidden: Bool) -> some View {
        modifier(HideTitleBar(isHidden: hidden))._resolveAppKitOrUIKitViewControllerIfAvailable()
    }
}
