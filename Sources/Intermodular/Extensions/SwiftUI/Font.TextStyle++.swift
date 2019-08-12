//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if canImport(UIKit)

extension Font.TextStyle {
    public func toUIFontTextStyle() -> UIFont.TextStyle? {
        switch self {
        #if os(iOS) || os(macOS)
        case .largeTitle:
            return .largeTitle
        #endif
        case .title:
            return .title1
        case .headline:
            return .headline
        case .subheadline:
            return .subheadline
        case .callout:
            return .callout
        case .footnote:
            return .footnote
        case .caption:
            return .caption1
        default:
            return nil
        }
    }
}

#endif
