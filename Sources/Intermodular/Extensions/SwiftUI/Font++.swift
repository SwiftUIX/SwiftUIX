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
    
    @available(macOS 11.0, *)
    public func toAppKitOrUIKitFont() throws -> AppKitOrUIKitFont {
        var font: AppKitOrUIKitFont?
        
        inspect(self) { label, value in
            guard label == "provider" else { return }
            
            inspect(value) { label, value in
                guard label == "base" else { return }
                
                guard let provider = _SwiftUIFontProvider(from: value) else {
                    return assertionFailure("Could not create font provider")
                }
                
                font = provider.toAppKitOrUIKitFont()
            }
        }
        
        font = font ?? getTextStyle()
            .flatMap({ $0.toAppKitOrUIKitFontTextStyle() })
            .map(AppKitOrUIKitFont.preferredFont(forTextStyle:))
        
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

// MARK: - Auxiliary

private enum _SwiftUIFontProvider {
    case system(size: CGFloat, weight: Font.Weight?, design: Font.Design?)
    case textStyle(Font.TextStyle, weight: Font.Weight?, design: Font.Design?)
    case platform(CTFont)
    
    @available(macOS 11.0, *)
    func toAppKitOrUIKitFont() -> AppKitOrUIKitFont? {
        switch self {
            case let .system(size, weight, _):
                guard let resolvedWeight = weight?.toAppKitOrUIKitFontWeight() else {
                    return nil
                }
                
                return AppKitOrUIKitFont.systemFont(ofSize: size, weight: resolvedWeight)
            case let .textStyle(textStyle, _, _):
                return textStyle
                    .toAppKitOrUIKitFontTextStyle()
                    .map(AppKitOrUIKitFont.preferredFont(forTextStyle:))
            case let .platform(font):
                return font as AppKitOrUIKitFont
        }
    }
    
    init?(from reflection: Any) {
        switch String(describing: type(of: reflection)) {
            case "SystemProvider":
                var props: (
                    size: CGFloat?,
                    weight: Font.Weight?,
                    design: Font.Design?
                ) = (nil, nil, nil)
                
                inspect(reflection) { label, value in
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
                
                inspect(reflection) { label, value in
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
                
                inspect(reflection) { label, value in
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
        
        inspect(self) { label, value in
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

private func inspect(_ object: Any, with action: (Mirror.Child) -> Void) {
    Mirror(reflecting: object).children.forEach(action)
}
