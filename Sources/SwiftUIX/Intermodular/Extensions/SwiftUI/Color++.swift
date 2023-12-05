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
    #if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
    public static var lightGray: Color {
        Color(.lightGray)
    }

    public static var darkGray: Color {
        Color(.darkGray)
    }

    public static var magenta: Color {
        Color(.magenta)
    }
    #endif
    
    /// A color for placeholder text in controls or text fields or text views.
    public static var placeholderText: Color {
        #if os(iOS) || os(macOS) || os(tvOS)
        Color(.placeholderText)
        #else
        return .gray // FIXME
        #endif
    }
}

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS)
extension Color {
    @_disfavoredOverload
    public static var systemRed: Color {
        Color(.systemRed)
    }
    
    @_disfavoredOverload
    public static var systemGreen: Color {
        Color(.systemGreen)
    }
    
    @_disfavoredOverload
    public static var systemBlue: Color {
        Color(.systemBlue)
    }
    
    @_disfavoredOverload
    public static var systemOrange: Color {
        Color(.systemOrange)
    }
    
    @_disfavoredOverload
    public static var systemYellow: Color {
        Color(.systemYellow)
    }
    
    @_disfavoredOverload
    public static var systemPink: Color {
        Color(.systemPink)
    }
    
    @_disfavoredOverload
    public static var systemPurple: Color {
        Color(.systemPurple)
    }
    
    @_disfavoredOverload
    public static var systemTeal: Color {
        Color(.systemTeal)
    }
    
    @_disfavoredOverload
    public static var systemIndigo: Color {
        Color(.systemIndigo)
    }

    @_disfavoredOverload
    public static var systemBrown: Color {
        Color(.systemBrown)
    }

    @_disfavoredOverload
    @available(iOS 15.0, tvOS 15.0, *)
    public static var systemMint: Color {
        Color(.systemMint)
    }

    @_disfavoredOverload
    @available(iOS 15.0, macOS 12.0, tvOS 15.0, *)
    public static var systemCyan: Color {
        Color(.systemCyan)
    }

    @_disfavoredOverload
    public static var systemGray: Color {
        Color(.systemGray)
    }
}
#endif

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
extension Color {
    @_disfavoredOverload
    public static var brown: Color {
        Color(.brown)
    }
    
    @_disfavoredOverload
    public static var indigo: Color {
        Color(.systemIndigo)
    }
    
    @_disfavoredOverload
    public static var teal: Color {
        Color(.systemTeal)
    }
}
#endif

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
@available(tvOS, unavailable)
extension Color {
    public static let systemGray2: Color = Color(.systemGray2)
    public static let systemGray3: Color = Color(.systemGray3)
    public static let systemGray4: Color = Color(.systemGray4)
    public static let systemGray5: Color = Color(.systemGray5)
    public static let systemGray6: Color = Color(.systemGray6)
}
#elseif os(macOS)
@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension Color {
    public static let systemGray2: Color = .adaptable(
        light: Color(cube256: .sRGB, red: 174, green: 174, blue: 178, opacity: 1),
        dark: Color(cube256: .sRGB, red: 99, green: 99, blue: 102, opacity: 1)
    )
    
    public static let systemGray3: Color = .adaptable(
        light: Color(cube256: .sRGB, red: 199, green: 199, blue: 204, opacity: 1),
        dark: Color(cube256: .sRGB, red: 72, green: 72, blue: 74, opacity: 1)
    )
    
    public static let systemGray4: Color = .adaptable(
        light: Color(cube256: .sRGB, red: 209, green: 209, blue: 214, opacity: 1),
        dark: Color(cube256: .sRGB, red: 58, green: 58, blue: 60, opacity: 1)
    )
    
    public static let systemGray5: Color = .adaptable(
        light: Color(cube256: .sRGB, red: 229, green: 229, blue: 234, opacity: 1),
        dark: Color(cube256: .sRGB, red: 44, green: 44, blue: 46, opacity: 1)
    )
    
    public static let systemGray6: Color = .adaptable(
        light: Color(cube256: .sRGB, red: 242, green: 242, blue: 247, opacity: 1),
        dark: Color(cube256: .sRGB, red: 28, green: 28, blue: 30, opacity: 1)
    )
}
#endif

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
extension Color {
    /// The color for text labels that contain primary content.
    public static var label: Color {
        #if os(macOS)
        Color(.labelColor)
        #else
        Color(.label)
        #endif
    }
    
    /// The color for text labels that contain secondary content.
    public static var secondaryLabel: Color {
        #if os(macOS)
        Color(.secondaryLabelColor)
        #else
        Color(.secondaryLabel)
        #endif
    }
    
    /// The color for text labels that contain tertiary content.
    public static var tertiaryLabel: Color {
        #if os(macOS)
        Color(.tertiaryLabelColor)
        #else
        Color(.tertiaryLabel)
        #endif
    }
    
    /// The color for text labels that contain quaternary content.
    public static var quaternaryLabel: Color {
        #if os(macOS)
        Color(.quaternaryLabelColor)
        #else
        Color(.quaternaryLabel)
        #endif
    }
}
#endif

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
extension Color {
    /// A foreground color for standard system links.
    public static var link: Color {
        Color(.link)
    }
    
    /// A foreground color for separators (thin border or divider lines).
    public static var separator: Color {
        Color(.separator)
    }
    
    /// A foreground color intended to look similar to `Color.separated`, but is guaranteed to be opaque, so it will.
    public static var opaqueSeparator: Color {
        Color(.opaqueSeparator)
    }
}
#endif

#if os(iOS) || os(macOS) || os(tvOS) || targetEnvironment(macCatalyst)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension Color {
    /// The color for the main background of your interface.
    public static var systemBackground: Color {
        #if os(macOS)
        return Color(AppKitOrUIKitColor.windowBackgroundColor)
        #else
        return Color(AppKitOrUIKitColor.systemBackground)
        #endif
    }
    
    /// The color for content layered on top of the main background.
    public static var secondarySystemBackground: Color {
        #if os(macOS)
        return Color(AppKitOrUIKitColor.controlBackgroundColor)
        #else
        return Color(AppKitOrUIKitColor.secondarySystemBackground)
        #endif
    }
    
    /// The color for content layered on top of secondary backgrounds.
    public static var tertiarySystemBackground: Color {
        #if os(macOS)
        return Color(AppKitOrUIKitColor.textBackgroundColor)
        #else 
        return Color(AppKitOrUIKitColor.tertiarySystemBackground)
        #endif
    }
}
#endif

#if os(iOS) || targetEnvironment(macCatalyst)
extension Color {
    /// The color for the main background of your grouped interface.
    public static var systemGroupedBackground: Color {
        Color(AppKitOrUIKitColor.systemGroupedBackground)
    }
    
    /// The color for content layered on top of the main background of your grouped interface.
    public static var secondarySystemGroupedBackground: Color {
        Color(AppKitOrUIKitColor.secondarySystemGroupedBackground)
    }
    
    /// The color for content layered on top of secondary backgrounds of your grouped interface.
    public static var tertiarySystemGroupedBackground: Color {
        Color(AppKitOrUIKitColor.tertiarySystemGroupedBackground)
    }
}
#endif

#if os(iOS) || os(macOS) || os(visionOS) || targetEnvironment(macCatalyst)
extension Color {
    /// A color  appropriate for filling thin and small shapes.
    ///
    /// Example: The track of a slider.
    public static var systemFill: Color {
        #if os(macOS)
        return Color(AppKitOrUIKitColor.textBackgroundColor)
        #else
        return Color(AppKitOrUIKitColor.systemFill)
        #endif
    }
    
    /// A color appropriate for filling medium-size shapes.
    ///
    /// Example: The background of a switch.
    public static var secondarySystemFill: Color {
        #if os(macOS)
        return Color(AppKitOrUIKitColor.windowBackgroundColor)
        #else
        return Color(AppKitOrUIKitColor.secondarySystemFill)
        #endif
    }
        
    /// A color appropriate for filling large shapes.
    ///
    /// Examples: Input fields, search bars, buttons.
    public static var tertiarySystemFill: Color {
        #if os(macOS)
        return Color(AppKitOrUIKitColor.underPageBackgroundColor)
        #else
        return Color(AppKitOrUIKitColor.tertiarySystemFill)
        #endif
    }
    
    /// A color appropriate for filling large areas containing complex content.
    ///
    /// Example: Expanded table cells.
    @available(macOS, unavailable)
    public static var quaternarySystemFill: Color {
        #if os(macOS)
        return Color(AppKitOrUIKitColor.scrubberTexturedBackground) // FIXME: This crashes for some reason.
        #else
        return Color(AppKitOrUIKitColor.quaternarySystemFill)
        #endif
    }
}
#endif

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
extension Color {
    /// A color that adapts to the preferred color scheme.
    ///
    /// - Parameters:
    ///   - light: The preferred color for a light color scheme.
    ///   - dark: The preferred color for a dark color scheme.
    @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
    public static func adaptable(
        light: @escaping @autoclosure () -> Color,
        dark: @escaping @autoclosure () -> Color
    ) -> Color {
        Color(
            AppKitOrUIKitColor.adaptable(
                light: AppKitOrUIKitColor(light()),
                dark: AppKitOrUIKitColor(dark())
            )
        )
    }
}
#endif

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
extension Color {
    /// Inverts the color.
    @available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    public func colorInvert() -> Color {
        Color(
            AppKitOrUIKitColor { _ in
                AppKitOrUIKitColor(self).invertedColor()
            }
        )
    }
}
#endif

extension Color {
    public init(
        cube256 colorSpace: RGBColorSpace,
        red: Int,
        green: Int,
        blue: Int,
        opacity: Double = 1.0
    ) {
        self.init(
            colorSpace,
            red: Double(red) / 255.0,
            green: Double(green) / 255.0,
            blue: Double(blue) / 255.0,
            opacity: opacity
        )
    }
}

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

// MARK: - Auxiliary

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
fileprivate extension AppKitOrUIKitColor {
    class func adaptable(
        light: @escaping @autoclosure () -> AppKitOrUIKitColor,
        dark: @escaping @autoclosure () -> AppKitOrUIKitColor
    ) -> AppKitOrUIKitColor {
        AppKitOrUIKitColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
                case .light:
                    return light()
                case .dark:
                    return dark()
                default:
                    return light()
            }
        }
    }
    
    func resolvedColor(
        for colorScheme: ColorScheme
    ) -> UIColor {
        switch colorScheme {
            case .light:
                return self.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light))
            case .dark:
                return self.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
            @unknown default:
                fatalError()
        }
    }
}
#elseif os(macOS)
fileprivate extension AppKitOrUIKitColor {
    class func adaptable(
        light: @escaping @autoclosure () -> AppKitOrUIKitColor,
        dark: @escaping @autoclosure () -> AppKitOrUIKitColor
    ) -> AppKitOrUIKitColor {
        AppKitOrUIKitColor(name: nil) { appearance in
            if appearance.isDarkMode {
                return dark()
            } else {
                return light()
            }
        }
    }
    
    func resolvedColor(
        for colorScheme: ColorScheme
    ) -> NSColor {
        fatalError("unimplemented")
    }
}
#endif

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
extension AppKitOrUIKitColor {
    func invertedColor() -> AppKitOrUIKitColor {
        var alpha: CGFloat = 1.0
        
        var red: CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0
        
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return AppKitOrUIKitColor(red: 1.0 - red, green: 1.0 - green, blue: 1.0 - blue, alpha: alpha)
        }
        
        var hue: CGFloat = 0.0, saturation: CGFloat = 0.0, brightness: CGFloat = 0.0
        
        if self.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return AppKitOrUIKitColor(hue: 1.0 - hue, saturation: 1.0 - saturation, brightness: 1.0 - brightness, alpha: alpha)
        }
        
        var white: CGFloat = 0.0
        
        if self.getWhite(&white, alpha: &alpha) {
            return AppKitOrUIKitColor(white: 1.0 - white, alpha: alpha)
        }
        
        return self
    }
}
#endif

#if os(macOS)
extension Color {
    /// The color to use for the window background.
    public static let windowBackground = Color(NSColor.windowBackgroundColor)
}
#endif

// MARK: - Helpers

#if os(macOS)
extension NSAppearance {
    public enum _SwiftUIX_UserInterfaceStyle {
        case light
        case dark
    }
    
    var _SwiftUIX_userInterfaceStyle: _SwiftUIX_UserInterfaceStyle {
        if name == Name.darkAqua ||
            name == Name.vibrantDark ||
            name == Name.accessibilityHighContrastDarkAqua ||
            name == Name.accessibilityHighContrastVibrantDark {
            return .dark
        }
        return .light
    }
    
    fileprivate var isDarkMode: Bool {
        switch name {
            case .darkAqua, .vibrantDark, .accessibilityHighContrastDarkAqua, .accessibilityHighContrastVibrantDark:
                return true
            default:
                return false
        }
    }
}
#endif
