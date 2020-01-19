//
// Copyright (c) Vatsal Manot
//

import Combine
import Swift
import SwiftUI

public struct ClearFillView: View {
    public init() {
        
    }
    
    public var body: some View {
        GeometryReader {
            _ in Color.clear
        }
        .contentShape(Rectangle())
    }
}
