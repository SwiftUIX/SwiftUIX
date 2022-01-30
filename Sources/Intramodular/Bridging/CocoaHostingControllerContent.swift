//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || os(macOS) || targetEnvironment(macCatalyst)

public struct CocoaHostingControllerContent<Content: View>: View  {
    weak var parent: CocoaController?
    
    public var content: Content
    
    init(parent: CocoaController?, content: Content) {
        self.content = content
    }
    
    public var body: some View {
        content
            ._resolveAppKitOrUIKitViewController(with: parent)
            .onPreferenceChange(_FixSafeAreaInsetsPreferenceKey.self) { [weak parent] in
                if ($0 ?? false) {
                    parent?._fixSafeAreaInsetsIfNecessary()
                }
            }
            .preference(key: _FixSafeAreaInsetsPreferenceKey.self, value: nil)
    }
}

extension CocoaHostingControllerContent: _opaque_FrameModifiedContent where Content: _opaque_FrameModifiedContent {
    @usableFromInline
    var _opaque_frameModifier: _opaque_FrameModifier {
        content._opaque_frameModifier
    }
}

#endif
