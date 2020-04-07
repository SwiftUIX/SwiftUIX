//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public struct HorizontalSpacer: View {
    public var body: some View {
        HStack {
            Spacer()
        }
    }
    
    public init() {
        
    }
}

public struct VerticalSpacer: View {
    public var body: some View {
        VStack {
            Spacer()
        }
    }
    
    public init() {
        
    }
}

extension View {
    @inlinable
    public func bottomTrailing() -> some View {
        ZStack {
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    self
                }
            }
        }
    }
}
