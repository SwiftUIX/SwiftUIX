//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension Font.TextStyle {
    #if canImport(UIKit)
    public var defaultMetrics: (weight: Font.Weight, size: CGFloat, leading: CGFloat) {
        switch self {
            case .largeTitle:
                return (.regular, 34, 41)
            case .title:
                return (.regular, 28, 34)
            case .headline:
                return (.semibold, 17, 22)
            case .subheadline:
                return (.regular, 15, 20)
            case .body:
                return (.regular, 17, 22)
            case .callout:
                return (.regular, 16, 21)
            case .footnote:
                return (.regular, 13, 18)
            case .caption:
                return (.regular, 12, 16)
                
            default: do {
                if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                    switch self {
                        case .title2:
                            return (.regular, 22, 28)
                        case .title3:
                            return (.regular, 20, 25)
                        case .caption2:
                            return (.regular, 11, 13)
                        default: do {
                            assertionFailure()
                            
                            return Self.body.defaultMetrics
                        }
                    }
                } else {
                    assertionFailure()
                    
                    return Self.body.defaultMetrics
                }
            }
        }
    }
    #endif
}

extension Font.TextStyle {
    #if canImport(UIKit)
    public func toUIFontTextStyle() -> UIFont.TextStyle? {
        switch self {
            #if !os(tvOS)
            case .largeTitle:
                return .largeTitle
            #endif
            case .title:
                return .title1
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
                return .caption1
                
            default: do {
                if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
                    switch self {
                        case .title2:
                            return .title2
                        case .title3:
                            return .title3
                        case .caption2:
                            return .caption2
                        default: do {
                            assertionFailure()
                            
                            return .body
                        }
                    }
                } else {
                    assertionFailure()
                    
                    return .body
                }
            }
        }
    }
    #endif
}
