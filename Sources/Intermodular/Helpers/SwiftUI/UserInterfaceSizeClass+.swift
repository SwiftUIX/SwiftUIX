//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension View {
    /// Pads this view for a given size class using the edge insets you specify.
    ///
    /// - Parameters:
    ///     - edges: The set of edges along which to inset this view.
    ///     - length: The amount to inset this view on each edge. If `nil`,
    ///       the amount is the system default amount.
    ///     - sizeClass: The size class for which to inset this view.
    /// - Returns: A view that pads this view using edge the insets you specify.
    @available(iOS 13.0, *)
    @available(OSX, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    @inlinable
    public func padding(
        _ edges: Edge.Set,
        _ length: CGFloat? = nil,
        forSizeClass sizeClass: UserInterfaceSizeClass
    ) -> some View {
        EnvironmentValueAccessView(\.horizontalSizeClass) { horizontalSizeClass in
            EnvironmentValueAccessView(\.verticalSizeClass) { verticalSizeClass in
                self.padding(
                    sizeClass == horizontalSizeClass
                        ? edges.intersection(.horizontal)
                        : [], length
                ).padding(
                    sizeClass == verticalSizeClass
                        ? edges.intersection(.vertical)
                        : [], length
                )
            }
        }
    }
}
