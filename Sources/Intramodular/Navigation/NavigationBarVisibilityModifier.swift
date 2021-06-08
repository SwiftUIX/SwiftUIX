//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

private struct HideNavigationBar: ViewModifier {
    @State var isNavigationBarHidden = false
    
    func body(content: Content) -> some View {
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        return content
            .background {
                if isNavigationBarHidden {
                    #if os(iOS)
                    ZeroSizeView()
                        .navigationBarHidden(isNavigationBarHidden)
                        .navigationBarTitle(Text(String()), displayMode: .inline)
                    #elseif os(tvOS)
                    ZeroSizeView()
                        .navigationBarHidden(isNavigationBarHidden)
                    #endif
                }
            }
            ._configureUINavigationController {
                $0.setNavigationBarHidden(true, animated: false)
            }
            .onAppear {
                isNavigationBarHidden = true
            }
            .onDisappear {
                isNavigationBarHidden = false
            }
        #else
        return content
        #endif
    }
}

// MARK: - API -

extension View {
    @available(macOS, unavailable)
    @inline(never)
    public func hideNavigationBar() -> some View {
        modifier(HideNavigationBar())
    }
    
    @inline(never)
    public func hideNavigationBarIfAvailable() -> some View {
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        return hideNavigationBar()
        #else
        return self
        #endif
    }
}
