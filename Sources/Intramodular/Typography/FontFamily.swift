//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A font family.
public protocol FontFamily: CaseIterable, RawRepresentable {
    var rawValue: String { get }
    
    /// The font weight that corresponds to this font.
    var weight: Font.Weight? { get }
}

// MARK: - API -

extension FontFamily {
    public func callAsFunction(size: CGFloat) -> Font {
        Font.custom(rawValue, size: size)
    }
}

extension Font {
    public static func custom<F: FontFamily>(_ family: F.Type, size: CGFloat, weight: Weight) -> Font {
        guard let font = family.allCases.first(where: { $0.weight == weight }) else {
            assertionFailure("The font family \(family) does not support \(weight) as a valid weight")
            
            return Font.system(size: size, weight: weight)
        }
        
        return custom(font.rawValue, size: size)
    }
    
    #if canImport(UIKit)
    public static func custom<F: FontFamily>(_ family: F.Type, style: Font.TextStyle) -> Font {
        let metrics = style.defaultMetrics
        
        return .custom(family, size: metrics.size, weight: metrics.weight)
    }
    #endif
}
