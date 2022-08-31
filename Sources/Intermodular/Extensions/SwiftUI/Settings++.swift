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
        if #available(macOS 13.0, *) {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        } else {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
        #endif
    }
}
