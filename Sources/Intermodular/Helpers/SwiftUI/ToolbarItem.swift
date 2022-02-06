//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

@available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
extension View {
    /// Converts this view into a toolbar item with a given placement.
    ///
    /// Use `toolbarItem(_:)` to configure a view as a toolbar item in a toolbar.
    public func toolbarItem(
        placement: ToolbarItemPlacement
    ) -> ToolbarItem<Void, Self> {
        ToolbarItem(placement: placement) {
            self
        }
    }
}
