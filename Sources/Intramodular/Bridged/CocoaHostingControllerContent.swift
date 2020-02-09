//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct CocoaHostingControllerContent<Content: View>: View  {
    var content: Content
    
    init(content: Content) {
        self.content = content
    }
    
    public var body: some View {
        content
    }
}

#endif
