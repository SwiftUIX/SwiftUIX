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
            .modifier(_ResolveAppKitOrUIKitViewController(_appKitOrUIKitViewControllerBox: .init(parent)))
            .onPreferenceChange(_FixSafeAreaInsetsPreferenceKey.self) {
                if ($0 ?? false) {
                    parent?._fixSafeAreaInsetsIfNecessary()
                }
            }
            .preference(key: _FixSafeAreaInsetsPreferenceKey.self, value: nil)
    }
}

#endif
