//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension EdgeInsets {
    public static var zero: Self {
        .init()
    }
    
    public init(_ edges: Edge.Set = .all, _ length: CGFloat? = nil) {
        self.init(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        guard let length = length else {
            return
        }
        
        if edges.contains(.top) {
            top = length
        }
        
        if edges.contains(.leading) {
            leading = length
        }
        
        if edges.contains(.bottom) {
            bottom = length
        }
        
        if edges.contains(.trailing) {
            trailing = length
        }
    }
}

extension EdgeInsets {
    #if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
    public init(_ insets: UIEdgeInsets) {
        self.init(
            top: insets.top,
            leading: insets.left, // FIXME
            bottom: insets.bottom,
            trailing: insets.right // FIXME
        )
    }
    #endif
}
