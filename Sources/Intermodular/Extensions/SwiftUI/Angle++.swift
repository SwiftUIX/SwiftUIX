//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension Angle {
    @inlinable
    public static var pi: Angle {
        return .init(radians: Double.pi)
    }
    
    @inlinable
    public func remainder(dividingBy other: Angle) -> Angle   {
        .init(radians: radians.remainder(dividingBy: other.radians))
    }
    
    @inlinable
    public init(degrees: CGFloat) {
        self.init(degrees: Double(degrees))
    }
    
    @inlinable
    public init(degrees: Int) {
        self.init(degrees: Double(degrees))
    }
    
    @inlinable
    public init(radians: CGFloat) {
        self.init(radians: Double(radians))
    }
    
    @inlinable
    public init(radians: Int) {
        self.init(radians: Double(radians))
    }
}
