//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

private struct HideNavigationBar: ViewModifier {
    @Environment(\._appKitOrUIKitViewController) var _appKitOrUIKitViewController
    
    @State var isNavigationBarHidden = false
    
    func body(content: Content) -> some View {
        PassthroughView {
            if isNavigationBarHidden {
                ZeroSizeView()
                    .navigationBarTitle("")
            }
            
            content
                .navigationBarHidden(isNavigationBarHidden)
                .onAppear(perform: {
                    self.isNavigationBarHidden = true
                })
                .onDisappear(perform: {
                    self.isNavigationBarHidden = false
                })
        }
        .onAppear {
            _appKitOrUIKitViewController?.navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }
}

// MARK: - API -

extension View {
    @inline(never)
    public func hideNavigationBar() -> some View {
        modifier(_ResolveAppKitOrUIKitViewController().concat( HideNavigationBar()))
    }
}

#endif

extension View {
    @inline(never)
    public func hideNavigationBarIfAvailable() -> some View {
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        return hideNavigationBar()
        #else
        return self
        #endif
    }
}
