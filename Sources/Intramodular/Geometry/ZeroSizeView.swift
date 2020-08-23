//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI

/// A zero-size view for when `EmptyView` just doesn't work.
public struct ZeroSizeView: AppKitOrUIKitViewRepresentable {
    public typealias AppKitOrUIKitViewType = AppKitOrUIKitView
    
    @inlinable
    public init() {
        
    }
    
    @inlinable
    public func makeAppKitOrUIKitView(context: Context) -> AppKitOrUIKitViewType {
        .init()
    }
    
    @inlinable
    public func updateAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, context: Context) {
        
    }
}

#else

/// A zero-size view for when `EmptyView` just doesn't work.
public struct ZeroSizeView: View {
    @inlinable
    public var body: some View {
        Color.almostClear.frameZeroClipped()
    }
    
    @inlinable
    public init() {
        
    }
}

#endif
