//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public struct EmptyFillView: View {
    public init() {
        
    }
    
    public var body: some View {
        GeometryReader { _ in
            EmptyView()
        }
        .contentShape(Rectangle())
    }
}
