//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI

public struct ZeroSizeView: AppKitOrUIKitViewRepresentable {
    public typealias AppKitOrUIKitViewType = AppKitOrUIKitView
    
    public init() {
        
    }
    
    public func makeAppKitOrUIKitView(context: Context) -> AppKitOrUIKitViewType {
        .init()
    }
    
    public func updateAppKitOrUIKitView(_ view: AppKitOrUIKitViewType, context: Context) {
        
    }
}

#endif
