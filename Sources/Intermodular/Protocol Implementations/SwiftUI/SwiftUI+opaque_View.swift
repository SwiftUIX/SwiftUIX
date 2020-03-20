//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension AnyView: opaque_View {
    public func eraseToAnyView() -> AnyView {
        return self
    }
}

extension HStack: opaque_View {
    
}

extension Text: opaque_View {
    
}

extension VStack: opaque_View {
    
}
