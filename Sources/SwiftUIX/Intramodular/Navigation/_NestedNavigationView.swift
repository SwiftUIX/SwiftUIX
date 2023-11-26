//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@available(iOS 13.0, tvOS 13.0, watchOS 7.0, *)
@available(macOS, unavailable)
public struct _NestedNavigationView<Content: View>: View {
    public let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        #if !os(watchOS)
        withAppKitOrUIKitViewController { controller in
            if let controller = controller {
                #if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
                if controller.navigationController == nil {
                    NavigationView {
                        PresentationView {
                            content
                        }
                    }
                } else {
                    PresentationView {
                        content
                    }
                }
                #else
                PresentationView {
                    content
                }
                #endif
            } else {
                ZeroSizeView()
            }
        }
        #else
        NavigationView {
            content
        }
        #endif
    }
}
