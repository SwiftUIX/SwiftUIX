//
// Copyright (c) Vatsal Manot
//

import _SwiftUIX
import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
extension Color {
    private func toUIColor0() -> UIColor? {
        switch self {
            case .clear:
                return .clear
            case .black:
                return .black
            case .white:
                return .white
            case .gray:
                return .systemGray
            case .red:
                return .systemRed
            case .green:
                return .systemGreen
            case .blue:
                return .systemBlue
            case .orange:
                return .systemOrange
            case .yellow:
                return .systemYellow
            case .pink:
                return .systemPink
            case .primary:
                return .label // FIXME?
            case .secondary:
                return .secondaryLabel // FIXME?
            default:
                return nil
        }
    }
    
    private func toUIColor1() -> UIColor? {
        switch self {
            case .clear:
                return UIColor.clear
            case .black:
                return UIColor.black
            case .white:
                return UIColor.white
            case .gray:
                return UIColor.systemGray
            case .red:
                return UIColor.systemRed
            case .green:
                return UIColor.systemGreen
            case .blue:
                return UIColor.systemBlue
            case .orange:
                return UIColor.systemOrange
            case .yellow:
                return UIColor.systemYellow
            case .pink:
                return UIColor.systemPink
            case .purple:
                return UIColor.systemPurple
            case .primary:
                return UIColor.label
            case .secondary:
                return UIColor.secondaryLabel
            default:
                return nil
        }
    }
    
    private func toUIColor2() -> UIColor? {
        let children = Mirror(reflecting: self).children
        let _provider = children.first { $0.label == "provider" }
        
        guard let provider = _provider?.value else {
            return nil
        }
        
        let providerChildren = Mirror(reflecting: provider).children
        let _base = providerChildren.first { $0.label == "base" }
        
        guard let base = _base?.value else {
            return nil
        }
        
        if String(describing: type(of: base)) == "NamedColor" {
            let baseMirror = Mirror(reflecting: base)
            
            if let name = baseMirror.descendant("name") as? String {
                let bundle = baseMirror.descendant("bundle") as? Bundle
                if let color = UIColor(named: name, in: bundle, compatibleWith: nil) {
                    return color
                }
            }
        }
        
        if String(describing: type(of: base)) == "OpacityColor" {
            let baseOpacity = Mirror(reflecting: base)
            if let opacity = baseOpacity.descendant("opacity") as? Double,
               let colorBase = baseOpacity.descendant("base") as? Color {
                return colorBase.toUIColor()?.withAlphaComponent(CGFloat(opacity))
            }
        }
        
        var baseValue: String = ""
        
        dump(base, to: &baseValue)
        
        guard let firstLine = baseValue.split(separator: "\n").first, let hexString = firstLine.split(separator: " ")[1] as Substring? else {
            return nil
        }
        
        return UIColor(hexadecimal: hexString.trimmingCharacters(in: .newlines))
    }
    
    public func toUIColor3() -> UIColor? {
        switch description {
            case "clear":
                return UIColor.clear
            case "black":
                return UIColor.black
            case "white":
                return UIColor.white
            case "gray":
                return UIColor.systemGray
            case "red":
                return UIColor.systemRed
            case "green":
                return UIColor.systemGreen
            case "blue":
                return UIColor.systemBlue
            case "orange":
                return UIColor.systemOrange
            case "yellow":
                return UIColor.systemYellow
            case "pink":
                return UIColor.systemPink
            case "purple":
                return UIColor.systemPurple
            case "primary":
                return UIColor.label
            case "secondary":
                return UIColor.secondaryLabel
            default:
                return nil
        }
    }

    private static var appKitOrUIKitColorConversionCache: [Color: AppKitOrUIKitColor] = [:]

    public func _toUIColor() -> UIColor? {
        #if os(iOS)
        if #available(iOS 14.0, *) {
            return UIColor(self)
        }
        #elseif os(tvOS)
        if #available(tvOS 14.0, *) {
            return UIColor(self)
        }
        #endif
        
        return nil
            ?? toUIColor0()
            ?? toUIColor1()
            ?? toUIColor2()
            ?? toUIColor3()
    }

    public func toUIColor(colorScheme: ColorScheme? = nil) -> AppKitOrUIKitColor? {
        let result: AppKitOrUIKitColor
        
        if let cachedResult = Self.appKitOrUIKitColorConversionCache[self] {
            result = cachedResult
        } else {
            guard let _result = _toUIColor() else {
                return nil
            }
            
            Self.appKitOrUIKitColorConversionCache[self] = _result

            result = _result
        }
        
        if let colorScheme {
            switch colorScheme {
                case .light:
                    return result.resolvedColor(with: .init(userInterfaceStyle: .light))
                case .dark:
                    return result.resolvedColor(with: .init(userInterfaceStyle: .dark))
                @unknown default:
                    assertionFailure()
                    
                    return result
            }
        } else {
            return result
        }
    }
}
#endif

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
extension Color {
    public func toAppKitOrUIKitColor() -> AppKitOrUIKitColor? {
        #if os(iOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)
        return toUIColor()
        #elseif os(macOS)
        if #available(macOS 11.0, *) {
            return NSColor(self)
        } else {
            assertionFailure("unimplemented")

            return nil
        }
        #endif
    }
}
#endif
