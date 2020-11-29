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
            GeometryReader { geometry in
                self.content.offset(geometry.centerOffsetInGlobalframe)
            }
            .frame(screen.bounds.size)
            .edgesIgnoringSafeArea(.all)
        }
    }
}

// MARK: - Helpers -

private extension GeometryProxy {
    var centerOffsetInGlobalframe: CGSize {
        let frame = self.frame(in: .global)
        let screenSize = Screen.main.bounds.size
        
        return .init(
            width: ((screenSize.width - frame.width) / 2) - frame.origin.x,
            height: ((screenSize.height - frame.height) / 2) - frame.origin.y
        )
    }
}
