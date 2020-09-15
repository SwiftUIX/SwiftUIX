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
    
    #if canImport(UIKit)
    public func toUIFont() -> UIFont? {
        #if (os(iOS) || os(watchOS) || os(tvOS)) && !targetEnvironment(macCatalyst)
        guard let textStyle = getTextStyle()?.toUIFontTextStyle() else {
            return nil
        }
        
        return .preferredFont(forTextStyle: textStyle)
        #else
        return nil
        #endif
    }
    #endif
}

#if (os(iOS) || os(watchOS) || os(tvOS)) && !targetEnvironment(macCatalyst)
extension Font {
    #if canImport(UIKit)
    public static func custom(
        _ name: String,
        relativeTo textStyle: Font.TextStyle
    ) -> Font {
        func _default() -> Font {
            guard let font = UIFont(name: name, size: textStyle.defaultMetrics.size) else {
                return .body
            }
            
            let fontMetrics = UIFontMetrics(forTextStyle: textStyle.toUIFontTextStyle() ?? .body)
            
            return Font(fontMetrics.scaledFont(for: font))
        }
        
        #if swift(>=5.3)
        if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
            return Font.custom(name, size: textStyle.defaultMetrics.size, relativeTo: textStyle)
        } else {
            return _default()
        }
        #else
        return _default()
        #endif
    }
    #endif
}
#endif
