//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public struct HorizontalSpacer: View {
    @inlinable
    public var body: some View {
        HStack {
            Spacer()
        }
    }
    
    @inlinable
    public init() {
        
    }
}

public struct VerticalSpacer: View {
    @inlinable
    public var body: some View {
        VStack {
            Spacer()
        }
    }
    
    @inlinable
    public init() {
        
    }
}
