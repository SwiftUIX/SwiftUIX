//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@available(macOS 11.0, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension Settings where Content == AnyView {
    public static func show() {
        #if os(macOS)
        NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        #endif
    }
}
