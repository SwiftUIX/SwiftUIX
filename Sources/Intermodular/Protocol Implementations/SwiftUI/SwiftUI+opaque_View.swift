//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension AnyView: _opaque_View {
    public func eraseToAnyView() -> AnyView {
        return self
    }
}

extension HStack: _opaque_View {
    
}

extension Text: _opaque_View {
    
}

extension VStack: _opaque_View {
    
}
