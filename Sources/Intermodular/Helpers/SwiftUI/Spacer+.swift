//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public struct HSpacer: View {
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

public struct VSpacer: View {
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

public struct XSpacer: View {
    @inlinable
    public var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            HStack {
                Spacer()
            }
        }
    }
    
    @inlinable
    public init() {
        
    }
}
