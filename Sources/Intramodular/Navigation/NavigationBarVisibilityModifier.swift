//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

private struct HideNavigationBar: ViewModifier {
    @State var dummy: Bool = false
    
    func body(content: Content) -> some View {
        #if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)
        return content
            .background {
                #if os(iOS)
                ZeroSizeView()
                    .navigationBarTitle(Text(String()), displayMode: .inline)
                    .navigationBarBackButtonHidden(true)
                    .navigationBarHidden(true)
                    .accessibility(hidden: true)
                    .allowsHitTesting(false)
                #elseif os(tvOS)
                ZeroSizeView()
                    .navigationBarHidden(true)
                    .accessibility(hidden: true)
                    .allowsHitTesting(false)
                #endif
            }
            .onAppKitOrUIKitViewControllerResolution(
                perform: {
                    $0.navigationController?.setNavigationBarHidden(true, animated: false)
                    $0.navigationController?.navigationBar.isHidden = true
                },
                onAppear: {
                    $0.navigationController?.setNavigationBarHidden(true, animated: false)
                    $0.navigationController?.navigationBar.isHidden = true
                },
                onDisappear: {
                    $0.navigationController?.setNavigationBarHidden(true, animated: false)
                    $0.navigationController?.navigationBar.isHidden = true
                },
                onDeresolution: {
                    $0.navigationController?.setNavigationBarHidden(true, animated: false)
                    $0.navigationController?.navigationBar.isHidden = true
                }
            )
            .onAppear {
                dummy.toggle()
            }
            .onDisappear {
                dummy.toggle()
            }
            .background {
                ZeroSizeView()
                    .id(dummy)
                    .accessibility(hidden: true)
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
