//
// Copyright (c) Vatsal Manot
//

import SwiftUI

#if canImport(UIKit)

extension Font.TextStyle {
    public func toUIFontTextStyle() -> UIFont.TextStyle? {
        switch self {
        case .largeTitle:
            return .largeTitle
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
