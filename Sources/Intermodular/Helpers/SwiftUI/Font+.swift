//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension Text {
    /// Sets the default font for text in this view.
    ///
    /// - Parameters:
    ///   - font: The default font to use in this view.
    ///   - weight: The default font weight to use in this view.
    /// - Returns: A view with the default font set to the value you supply.
    @inlinable
    public func font(_ font: Font, weight: Font.Weight?) -> Text {
        if let weight {
            return self.font(font.weight(weight))
        } else {
            return self.font(font)
        }
    }
}

extension View {
    /// Sets the default font for text in this view.
    ///
    /// - Parameters:
    ///   - font: The default font to use in this view.
    ///   - weight: The default font weight to use in this view.
    /// - Returns: A view with the default font set to the value you supply.
    @inlinable
    @ViewBuilder
    public func font(_ font: Font, weight: Font.Weight?) -> some View {
        if let weight {
            self.font(font.weight(weight))
        } else {
            self.font(font)
        }
    }
}
