//
// Copyright (c) Vatsal Manot
//

#if swift(>=5.2)

import SwiftUI

/// A type to mirror `SwiftUI.HoverEffect`, added for compatibility.
@available(iOS 13, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(OSX, unavailable)
public enum HoverEffect {
    /// An effect  that attempts to determine the effect automatically.
    /// This is the default effect.
    case automatic
    
    /// An effect  that morphs the pointer into a platter behind the view
    /// and shows a light source indicating position.
    case highlight
    
    /// An effect that slides the pointer under the view and disappears as the
    /// view scales up and gains a shadow.
    case lift
}

@available(iOS 13.4, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(OSX, unavailable)
extension SwiftUI.HoverEffect {
    public init(_ hoverEffect: HoverEffect) {
        switch hoverEffect {
            case .automatic:
                self = .automatic
            case .highlight:
                self = .highlight
            case .lift:
                self = .lift
        }
    }
}

@available(iOS 13.4, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(OSX, unavailable)
extension View {
    /// Applies a pointer hover effect to the view.
    ///
    /// - Note: the system may fall-back to a more appropriate effect.
    @_disfavoredOverload
    public func hoverEffect(_ effect: HoverEffect) -> some View {
        hoverEffect(SwiftUI.HoverEffect(effect))
    }
}

#endif
