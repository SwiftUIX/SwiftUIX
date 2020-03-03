//
// Copyright (c) Vatsal Manot
//

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
