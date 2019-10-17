//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension EdgeInsets {
    public init(_ edges: Edge.Set = .all, _ length: CGFloat? = nil) {
        self.init(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        guard let length = length else {
            return
        }
        
        if edges.contains(.all) || edges.contains(.top) || edges.contains(.vertical) {
            top = length
        }
        
        if edges.contains(.all) || edges.contains(.leading) || edges.contains(.horizontal) {
            leading = length
        }
        
        if edges.contains(.all) || edges.contains(.bottom) || edges.contains(.vertical) {
            bottom = length
        }
        
        if edges.contains(.all) || edges.contains(.trailing) || edges.contains(.horizontal) {
            trailing = length
        }
    }
}
