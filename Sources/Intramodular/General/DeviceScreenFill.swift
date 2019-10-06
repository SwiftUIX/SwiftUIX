//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if canImport(UIKit)

/// A view that fills the device's screen.
public struct DeviceScreenFill: View {
    public init() {
        
    }
    
    public var body: some View {
        GeometryReader { proxy in
            EmptyView()
                .inset(by: proxy.frame(in: .global).origin)
        }
        .edgesIgnoringSafeArea(.all)
        .frame(
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.height
        )
    }
}

#endif
