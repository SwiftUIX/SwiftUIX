//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension Color {
    public static var almostClear: Color {
        Color.black.opacity(0.0001)
    }
}

extension Color {
    /// A color for placeholder text in controls or text fields or text views.
    public static var placeholderText: Color {
        #if os(iOS) || os(macOS) || os(tvOS)
        return .init(.placeholderText)
        #else
        return .gray // FIXME
        #endif
    }
}

#if os(iOS) || os(macOS) || os(tvOS)

extension Color {
    public static var systemRed: Color {
        return .init(.systemRed)
    }
    
    public static var systemGreen: Color {
        return .init(.systemGreen)
    }
    
    public static var systemBlue: Color {
        return .init(.systemBlue)
    }
    
    public static var systemOrange: Color {
        return .init(.systemOrange)
    }
    
    public static var systemYellow: Color {
        return .init(.systemYellow)
    }
    
    public static var systemPink: Color {
        return .init(.systemPink)
    }
    
    public static var systemPurple: Color {
        return .init(.systemPurple)
    }
    
    public static var systemTeal: Color {
        return .init(.systemTeal)
    }
    
    public static var systemIndigo: Color {
        return .init(.systemIndigo)
    }
    
    public static var systemGray: Color {
        return .init(.systemGray)
    }
}

#endif

#if os(iOS) || targetEnvironment(macCatalyst)

extension Color {
    public static var systemGray2: Color {
        return .init(.systemGray2)
    }
    
    public static var systemGray3: Color {
        return .init(.systemGray3)
    }
    
    public static var systemGray4: Color {
        return .init(.systemGray4)
    }
    
    public static var systemGray5: Color {
        return .init(.systemGray5)
    }
    
    public static var systemGray6: Color {
        return .init(.systemGray6)
    }
}

#endif

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)

/// Foreground colors for static text and related elements.
extension Color {
    /// The color for text labels that contain primary content.
    public static var label: Color {
        #if os(macOS)
        return .init(.labelColor)
        #else
        return .init(.label)
        #endif
    }
    
    /// The color for text labels that contain secondary content.
    public static var secondaryLabel: Color {
        #if os(macOS)
        return .init(.secondaryLabelColor)
        #else
        return .init(.secondaryLabel)
        #endif
    }
    
    /// The color for text labels that contain tertiary content.
    public static var tertiaryLabel: Color {
        #if os(macOS)
        return .init(.tertiaryLabelColor)
        #else
        return .init(.tertiaryLabel)
        #endif
    }
    
    /// The color for text labels that contain quaternary content.
    public static var quaternaryLabel: Color {
        #if os(macOS)
        return .init(.quaternaryLabelColor)
        #else
        return .init(.quaternaryLabel)
        #endif
    }
}

#endif

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension Color {
    /// A foreground color for standard system links.
    public static var link: Color {
        return .init(.link)
    }
    
    /// A forground color for separators (thin border or divider lines).
    public static var separator: Color {
        return .init(.separator)
    }
    
    /// A forground color intended to look similar to `Color.separated`, but is guaranteed to be opaque, so it will.
    public static var opaqueSeparator: Color {
        return .init(.opaqueSeparator)
    }
}

#endif

#if os(iOS) || targetEnvironment(macCatalyst)

extension Color {
    /// The color for the main background of your interface.
    public static var systemBackground: Color {
        return .init(.systemBackground)
    }
    
    /// The color for content layered on top of the main background.
    public static var secondarySystemBackground: Color {
        return .init(.secondarySystemBackground)
    }
    
    /// The color for content layered on top of secondary backgrounds.
    public static var tertiarySystemBackground: Color {
        return .init(.tertiarySystemBackground)
    }
    
    /// The color for the main background of your grouped interface.
    public static var systemGroupedBackground: Color {
        return .init(.systemGroupedBackground)
    }
    
    /// The color for content layered on top of the main background of your grouped interface.
    public static var secondarySystemGroupedBackground: Color {
        return .init(.secondarySystemGroupedBackground)
    }
    
    /// The color for content layered on top of secondary backgrounds of your grouped interface.
    public static var tertiarySystemGroupedBackground: Color {
        return .init(.tertiarySystemGroupedBackground)
    }
}

/// Fill colors for UI elements.
/// These are meant to be used over the background colors, since their alpha component is less than 1.
extension Color {
    /// A color  appropriate for filling thin and small shapes.
    ///
    /// Example: The track of a slider.
    public static var systemFill: Color {
        return .init(.systemFill)
    }
    
    
    /// A color appropriate for filling medium-size shapes.
    ///
    /// Example: The background of a switch.
    public static var secondarySystemFill: Color {
        return .init(.secondarySystemFill)
    }
    
    
    /// A color appropriate for filling large shapes.
    ///
    /// Examples: Input fields, search bars, buttons.
    public static var tertiarySystemFill: Color {
        return .init(.tertiarySystemFill)
    }
    
    
    /// A color appropriate for filling large areas containing complex content.
    ///
    /// Example: Expanded table cells.
    public static var quaternarySystemFill: Color {
        return .init(.quaternarySystemFill)
    }
}

#endif

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

extension Color {
    /// Creates a color from a hexadecimal color code.
    ///
    /// - Parameter hexadecimal: A hexadecimal representation of the color.
    ///
    /// - Returns: A `Color` from the given color code. Returns `nil` if the code is invalid.
    public init!(hexadecimal string: String) {
        var string: String = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if string.hasPrefix("#") {
            _ = string.removeFirst()
        }
        
        if !string.count.isMultiple(of: 2), let last = string.last {
            string.append(last)
        }
        
        if string.count > 8 {
            string = String(string.prefix(8))
        }
        
        let scanner = Scanner(string: string)
        
        var color: UInt64 = 0
        
        scanner.scanHexInt64(&color)
        
        if string.count == 2 {
            let mask = 0xFF
            
            let g = Int(color) & mask
            
            let gray = Double(g) / 255.0
            
            self.init(.sRGB, red: gray, green: gray, blue: gray, opacity: 1)
        } else if string.count == 4 {
            let mask = 0x00FF
            
            let g = Int(color >> 8) & mask
            let a = Int(color) & mask
            
            let gray = Double(g) / 255.0
            let alpha = Double(a) / 255.0
            
            self.init(.sRGB, red: gray, green: gray, blue: gray, opacity: alpha)
        } else if string.count == 6 {
            let mask = 0x0000FF
            
            let r = Int(color >> 16) & mask
            let g = Int(color >> 8) & mask
            let b = Int(color) & mask
            
            let red = Double(r) / 255.0
            let green = Double(g) / 255.0
            let blue = Double(b) / 255.0
            
            self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)
        } else if string.count == 8 {
            let mask = 0x000000FF
            
            let r = Int(color >> 24) & mask
            let g = Int(color >> 16) & mask
            let b = Int(color >> 8) & mask
            let a = Int(color) & mask
            
            let red = Double(r) / 255.0
            let green = Double(g) / 255.0
            let blue = Double(b) / 255.0
            let alpha = Double(a) / 255.0
            
            self.init(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
        } else {
            return nil
        }
    }
    
    /// Creates a color from a 6-digit hexadecimal color code.
    public init(hexadecimal6: Int) {
        let red = Double((hexadecimal6 & 0xFF0000) >> 16) / 255.0
        let green = Double((hexadecimal6 & 0x00FF00) >> 8) / 255.0
        let blue = Double(hexadecimal6 & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}

#endif
