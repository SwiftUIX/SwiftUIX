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
    @MainActor
    public static func show() {
#if os(macOS)
        NSApplication.shared.activate(ignoringOtherApps: true)
        
        if #available(macOS 14.0, *) {
            NSApp.findAndClickSettingsMenuItem()
        } else if #available(macOS 13.0, *) {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        } else {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
#endif
    }
}

#if os(macOS)
extension NSApplication {
    @discardableResult
    fileprivate func findAndClickSettingsMenuItem() -> Bool {
        guard let mainMenu = mainMenu else {
            return false
        }
        
        for menuItem in mainMenu.items {
            guard menuItem.title.lowercased() == ProcessInfo.processInfo.processName.lowercased() else {
                continue
            }
            
            if let appMenu = menuItem.submenu {
                for (index, item) in appMenu.items.enumerated() {
                    if item.title.lowercased().contains("Settings".lowercased()) {
                        appMenu.performActionForItem(at: index)
                       
                        return true
                    }
                }
            }
        }
        
        return false
    }
}
#endif
