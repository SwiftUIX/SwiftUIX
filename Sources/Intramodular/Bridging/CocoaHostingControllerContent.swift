//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || os(macOS) || targetEnvironment(macCatalyst)

public struct CocoaHostingControllerContent<Content: View>: View  {
    weak var parent: CocoaViewController?
    
    public var content: Content
    
    init(parent: CocoaViewController?, content: Content) {
        self.content = content
    }
    
    public var body: some View {
        content._resolveAppKitOrUIKitViewController(with: parent)
    }
}

extension CocoaHostingControllerContent: _opaque_FrameModifiedContent where Content: _opaque_FrameModifiedContent {
    @usableFromInline
    var _opaque_frameModifier: _opaque_FrameModifier {
        content._opaque_frameModifier
    }
}

#endif
