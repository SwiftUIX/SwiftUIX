//
// Copyright (c) Vatsal Manot
//

import SwiftUI

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
}

extension Font {
    public func toUIFont() -> UIFont {
        .preferredFont(forTextStyle: (getTextStyle() ?? .body).toUIFontTextStyle())
    }
}
