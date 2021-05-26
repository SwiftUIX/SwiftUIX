//
// Copyright (c) Vatsal Manot
//

import SwiftUI

/// A type that specifies the appearance and interaction of all scroll indicators within a view hierarchy.
public protocol ScrollIndicatorStyle {
    
}

// MARK: - API -

public struct DefaultScrollViewIndicatorStyle: Hashable, ScrollIndicatorStyle {
    public init() {
        
    }
}

/// A scroll indicator style that hides all scroll view indicators within a view hierarchy.
///
/// `HiddenScrollViewIndicatorStyle/init(vertical:horizontal:)` allows you to specify
public struct HiddenScrollViewIndicatorStyle: Hashable, ScrollIndicatorStyle {
    public let vertical: Bool
    public let horizontal: Bool
    
    /// - Parameters:
    ///   - vertical: A Boolean value that indicates whether the vertical scroll indicator should be hidden.
    ///   - horizontal: A Boolean value that indicates whether the horizontal scroll indicator should be hidden.
    public init(vertical: Bool = true, horizontal: Bool = true) {
        self.vertical = vertical
        self.horizontal = horizontal
    }
}

extension View {
    public func scrollIndicatorStyle<Style: ScrollIndicatorStyle>(_ scrollIndicatorStyle: Style) -> some View {
        environment(\.scrollIndicatorStyle, scrollIndicatorStyle)
    }
}
// MARK: - Auxiliary Implementation -

extension EnvironmentValues {
    private struct ScrollIndicatorStyleKey: EnvironmentKey {
        static let defaultValue: ScrollIndicatorStyle = DefaultScrollViewIndicatorStyle()
    }
    
    var scrollIndicatorStyle: ScrollIndicatorStyle {
        get {
            self[ScrollIndicatorStyleKey]
        } set {
            self[ScrollIndicatorStyleKey] = newValue
        }
    }
}
