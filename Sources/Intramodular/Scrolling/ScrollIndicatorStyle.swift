//
// Copyright (c) Vatsal Manot
//

import SwiftUI

public protocol ScrollIndicatorStyle {
    
}

// MARK: - API -

public struct DefaultScrollViewIndicatorStyle: Hashable, ScrollIndicatorStyle {
    public init() {
        
    }
}

public struct HiddenScrollViewIndicatorStyle: Hashable, ScrollIndicatorStyle {
    public let vertical: Bool
    public let horizontal: Bool
    
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
