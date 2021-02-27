//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

fileprivate struct HideTitleBar: ViewModifier {
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    @Environment(\._appKitOrUIKitWindowScene) var _appKitOrUIKitWindowScene
    #endif
    
    let isHidden: Bool
    
    func body(content: Content) -> some View {
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        return content
            .onAppear(perform: { updateTitlebar(windowScene: _appKitOrUIKitWindowScene) })
            .onChange(of: _appKitOrUIKitWindowScene, perform: { updateTitlebar(windowScene: $0) })
            .onChange(of: isHidden, perform: { _ in updateTitlebar(windowScene: _appKitOrUIKitWindowScene) })
        #else
        return content
        #endif
    }
    
    #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
    private func updateTitlebar(windowScene: UIWindowScene?) {
        #if targetEnvironment(macCatalyst)
        guard let windowScene = windowScene else {
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
        #if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)
        return modifier(HideTitleBar(isHidden: hidden)).modifier(_ResolveAppKitOrUIKitViewController())
        #else
        return self
        #endif
    }
}
