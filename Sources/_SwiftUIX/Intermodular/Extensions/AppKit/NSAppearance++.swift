//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import SwiftUI

extension NSAppearance {
    public func _SwiftUIX_toColorScheme() -> ColorScheme {
        let darkAppearances: [NSAppearance.Name] = [
            .vibrantDark,
            .darkAqua,
            .accessibilityHighContrastVibrantDark,
            .accessibilityHighContrastDarkAqua,
        ]
        
        return darkAppearances.contains(self.name) ? .dark : .light
    }
    
    public convenience init?(_SwiftUIX_from colorScheme: ColorScheme) {
        switch colorScheme {
            case .light:
                self.init(named: .aqua)
            case .dark:
                self.init(named: .darkAqua)
            default:
                return nil
        }
    }
}

#endif
