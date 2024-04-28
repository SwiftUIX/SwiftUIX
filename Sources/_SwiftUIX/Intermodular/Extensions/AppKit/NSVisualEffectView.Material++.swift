//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import SwiftUI

extension NSVisualEffectView.Material: CaseIterable {
    public static var allCases: [Self] {
        [.titlebar, .selection, .menu, .popover, .sidebar, .headerView, .sheet, .windowBackground, .hudWindow, .fullScreenUI, .toolTip, .contentBackground, .underWindowBackground, .underPageBackground]
    }
    
    public var name: String {
        switch self {
            case .titlebar:
                return "titlebar"
            case .selection:
                return "selection"
            case .menu:
                return "menu"
            case .popover:
                return "popover"
            case .sidebar:
                return "sidebar"
            case .headerView:
                return "headerView"
            case .sheet:
                return "sheet"
            case .windowBackground:
                return "windowBackground"
            case .hudWindow:
                return "hudWindow"
            case .fullScreenUI:
                return "fullScreenUI"
            case .toolTip:
                return "toolTip"
            case .contentBackground:
                return "contentBackground"
            case .underWindowBackground:
                return "underWindowBackground"
            case .underPageBackground:
                return "underPageBackground"
            default:
                return "unknown"
        }
    }
}

#endif
