//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public struct DeviceScreenFill: View {
    public init() {
        
    }
    
    public var body: some View {
        GeometryReader { proxy in
            Rectangle()
                .fill(Color.clear)
                .inset(by: proxy.frame(in: .global).origin)
        }
        .edgesIgnoringSafeArea(.all)
        .frame(
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.height
        )
    }
}
