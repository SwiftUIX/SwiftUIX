//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A view that fills the device's screen.
public struct DeviceScreenFill<Content: View>: View {
    @ObservedObject private var screen = Screen.main
    
    private let content: Content
    
    public init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }
    
    public var body: some View {
        ZStack {
            GeometryReader { proxy in
                self.content
                    .inset(by: proxy.frame(in: .global).origin)
            }
            .frame(
                width: screen.bounds.width,
                height: screen.bounds.height
            )
            .edgesIgnoringSafeArea(.all)
        }
    }
}
