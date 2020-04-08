//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

public protocol opaque_View {
    func opaque_getViewName() -> ViewName?
    
    func eraseToAnyView() -> AnyView
}

// MARK: - Implementation -

extension opaque_View where Self: View {
    @inlinable
    public func opaque_getViewName() -> ViewName? {
        nil
    }
    
    @inlinable
    public func eraseToAnyView() -> AnyView {
        .init(self)
    }
}
