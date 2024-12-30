//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

extension Font {
    public func getTextStyle() -> TextStyle? {
        switch self {
            case .largeTitle:
                return .largeTitle
            case .title:
                return .title
            case .headline:
                return .headline
            case .subheadline:
                return .subheadline
            case .body:
                return .body
            case .callout:
                return .callout
            case .footnote:
                return .footnote
            case .caption:
                return .caption
            default:
                return nil
        }
    }
    
    private static var _appKitOrUIKitConversionCache: [Font: AppKitOrUIKitFont] = [:]
    
    @available(macOS 11.0, *)
    public func toAppKitOrUIKitFont() throws -> AppKitOrUIKitFont {
        if let result = Self._appKitOrUIKitConversionCache[self] {
            return result
        }
        
        var font: AppKitOrUIKitFont?
        
        Mirror.inspect(self) { label, value in
            guard label == "provider" else {
                return
            }
            
            Mirror.inspect(value) { label, value in
                guard label == "base" else {
                    return
                }
                
                guard let provider = _SwiftUIFontProvider(from: value) else {
                    return assertionFailure("Could not create font provider")
                }
                
                font = provider.toAppKitOrUIKitFont()
            }
        }
        
        font = font ?? getTextStyle()
            .flatMap({ $0.toAppKitOrUIKitFontTextStyle() })
            .map(AppKitOrUIKitFont.preferredFont(forTextStyle:))
        
        Self._appKitOrUIKitConversionCache[self] = font
        
        return try font.unwrap()
    }
    
    @available(*, deprecated, renamed: "toAppKitOrUIKitFont()")
    @available(macOS 11.0, *)
    public func toUIFont() -> AppKitOrUIKitFont? {
        try? toAppKitOrUIKitFont()
    }
}

#if canImport(UIKit)
extension Font {
    public static func custom(
        _ name: String,
        relativeTo textStyle: Font.TextStyle
    ) -> Font {
        func _default() -> Font {
            guard let font = UIFont(name: name, size: textStyle.defaultMetrics.size) else {
                return .body
            }
            
            let fontMetrics = UIFontMetrics(forTextStyle: textStyle.toAppKitOrUIKitFontTextStyle() ?? .body)
            
            return Font(fontMetrics.scaledFont(for: font))
        }
        
        if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
            return Font.custom(name, size: textStyle.defaultMetrics.size, relativeTo: textStyle)
        } else {
            return _default()
        }
    }
}
#endif

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS)
extension Font {
    public func scaled(by ratio: CGFloat) -> Self {
        (try? toAppKitOrUIKitFont().scaled(by: ratio)).map({ Font($0) }) ?? self
    }
}
#endif

// MARK: - Auxiliary

private enum _SwiftUIFontProvider {
    case named(name: String, size: CGFloat, textStyle: Font.TextStyle?)
    case system(size: CGFloat, weight: Font.Weight?, design: Font.Design?)
    case textStyle(Font.TextStyle, weight: Font.Weight?, design: Font.Design?)
    case platform(CTFont)
    
    mutating func setWeight(_ weight: Font.Weight?) {
        switch self {
            case .named:
                assertionFailure()
            case let .system(size, _, design):
                self = .system(size: size, weight: weight, design: design)
            case let .textStyle(style, _, design):
                self = .textStyle(style, weight: weight, design: design)
            case .platform:
                break // FIXME!
        }
    }
    
    @available(macOS 11.0, *)
    func toAppKitOrUIKitFont() -> AppKitOrUIKitFont? {
        switch self {
            case let .named(name, size, textStyle):
                if textStyle != .body {
                    assert(textStyle == nil, "unimplemented")
                }
                
                return AppKitOrUIKitFont(name: name, size: size)
            case let .system(size, weight, _):
                let weight: AppKitOrUIKitFont.Weight = weight?.toAppKitOrUIKitFontWeight() ?? .regular
                
                return AppKitOrUIKitFont.systemFont(
                    ofSize: size,
                    weight: weight
                )
            case let .textStyle(textStyle, _, _):
                return textStyle
                    .toAppKitOrUIKitFontTextStyle()
                    .map(AppKitOrUIKitFont.preferredFont(forTextStyle:))
            case let .platform(font):
                return font as AppKitOrUIKitFont
        }
    }
    
    init?(from subject: Any) {
        let mirror = Mirror(reflecting: subject)
        
        switch String(describing: type(of: subject)) {
            case "StaticModifierProvider<BoldModifier>":
                guard let base = mirror[_SwiftUIX_keyPath: "base.provider.base"] else {
                    return nil
                }
                
                self.init(from: base)
                
                self.setWeight(.bold)
            case "ModifierProvider<WeightModifier>":
                guard let base = mirror[_SwiftUIX_keyPath: "base.provider.base"] else {
                    return nil
                }
                
                guard let weight = mirror[_SwiftUIX_keyPath: "modifier.weight"] as? Font.Weight else {
                    return nil
                }
                
                self.init(from: base)

                self.setWeight(weight)
            case "NamedProvider":
                guard let name = mirror.descendant("name") as? String, let size = mirror.descendant("size") as? CGFloat else {
                    return nil
                }
                
                let textStyle = mirror.descendant("textStyle") as? Font.TextStyle
                
                self = .named(name: name, size: size, textStyle: textStyle)
            case "SystemProvider":
                var props: (
                    size: CGFloat?,
                    weight: Font.Weight?,
                    design: Font.Design?
                ) = (nil, nil, nil)
                
                Mirror.inspect(subject) { label, value in
                    switch label {
                        case "size":
                            props.size = value as? CGFloat
                        case "weight":
                            props.weight = value as? Font.Weight
                        case "design":
                            props.design = value as? Font.Design
                        default:
                            return
                    }
                }
                
                guard let size = props.size else {
                    return nil
                }
                
                self = .system(
                    size: size,
                    weight: props.weight,
                    design: props.design
                )
                
            case "TextStyleProvider":
                var props: (
                    style: Font.TextStyle?,
                    weight: Font.Weight?,
                    design: Font.Design?
                ) = (nil, nil, nil)
                
                Mirror.inspect(subject) { label, value in
                    switch label {
                        case "style":
                            props.style = value as? Font.TextStyle
                        case "weight":
                            props.weight = value as? Font.Weight
                        case "design":
                            props.design = value as? Font.Design
                        default:
                            return
                    }
                }
                
                guard let style = props.style else {
                    return nil
                }
                
                self = .textStyle(
                    style,
                    weight: props.weight,
                    design: props.design
                )
                
            case "PlatformFontProvider":
                var font: CTFont?
                
                Mirror.inspect(subject) { label, value in
                    guard label == "font" else {
                        return
                    }
                    
                    font = (value as? CTFont?)?.flatMap({ $0 })
                }
                
                guard let font else {
                    return nil
                }
                
                self = .platform(font)
            default:
                return nil
        }
    }
}

extension SwiftUI.Font.Weight {
    fileprivate func toAppKitOrUIKitFontWeight() -> AppKitOrUIKitFont.Weight? {
        var rawValue: CGFloat? = nil
        
        Mirror.inspect(self) { label, value in
            guard label == "value" else {
                return
            }
            
            rawValue = value as? CGFloat
        }
        
        guard let rawValue else {
            return nil
        }
        
        return .init(rawValue)
    }
}
