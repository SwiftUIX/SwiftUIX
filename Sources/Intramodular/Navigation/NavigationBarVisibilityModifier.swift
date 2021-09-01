//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

private struct HideNavigationBar: ViewModifier {
    @State private var isVisible: Bool = false
    
    func body(content: Content) -> some View {
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        return content
            .background {
                PassthroughView {
                    #if os(iOS)
                    ZeroSizeView()
                        .navigationBarTitle(Text(String()), displayMode: .inline)
                        .navigationBarBackButtonHidden(true)
                        .navigationBarHidden(true)
                    #elseif os(tvOS)
                    ZeroSizeView()
                        .navigationBarHidden(true)
                    #endif
                }
            }
            .onAppKitOrUIKitViewControllerResolution {
                guard isVisible else {
                    return
                }
                
                $0.navigationController?.setNavigationBarHidden(true, animated: false)
                $0.navigationController?.navigationBar.isHidden = true
            } onAppear: {
                isVisible = true
                
                $0.navigationController?.setNavigationBarHidden(true, animated: false)
                $0.navigationController?.navigationBar.isHidden = true
            } onDisappear: { _ in
                isVisible = false
            }
        #else
        return content
        #endif
    }
}

// MARK: - API -

extension View {
    /// Hides the navigation bar for this view. Really.
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
