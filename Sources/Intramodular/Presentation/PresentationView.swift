//
// Copyright (c) Vatsal Manot
//

import SwiftUI

/// A view for presenting a stack of views.
///
/// Like `NavigationView`, but for modal presentation.
public struct PresentationView<Content: View>: View {
    @State var presenter: DynamicViewPresenter?
    
    private let content: Content
    
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        #if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)
        content
            .environment(\.presenter, presenter)
            .modifier(_ResolveAppKitOrUIKitViewController())
            .onAppKitOrUIKitViewControllerResolution {
                self.presenter = $0
            }
        #else
        content
        #endif
    }
}
