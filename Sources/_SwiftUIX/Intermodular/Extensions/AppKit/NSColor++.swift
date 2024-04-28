//
// Copyright (c) Vatsal Manot
//

#if os(macOS)

import AppKit
import Swift
import SwiftUI

extension NSColor {
    @_disfavoredOverload
    public static var label: NSColor {
        NSColor.labelColor
    }
    
    @_disfavoredOverload
    public static var separator: NSColor {
        NSColor.separatorColor
    }

    @_disfavoredOverload
    public static var placeholderText: NSColor {
        return .placeholderTextColor
    }
    
    convenience init?(hexadecimal: String, alpha: CGFloat = 1.0) {
        var hexSanitized = hexadecimal.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }
        
        var rgbValue: UInt64 = 0
        
        Scanner(string: hexSanitized).scanHexInt64(&rgbValue)
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

#endif
