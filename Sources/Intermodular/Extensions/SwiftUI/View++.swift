//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

extension View {
    @inlinable
    public func then(_ body: (inout Self) -> Void) -> Self {
        var result = self
        
        body(&result)
        
        return result
    }
    
    /// Returns a type-erased version of `self`.
    @inlinable
    public func eraseToAnyView() -> AnyView {
        return .init(self)
    }
}

// MARK: - View.background

extension View {
    @_disfavoredOverload
    @inlinable
    public func background<Background: View>(
        alignment: Alignment = .center,
        @ViewBuilder _ background: () -> Background
    ) -> some View {
        self.background(background(), alignment: alignment)
    }
    
    @_disfavoredOverload
    @inlinable
    public func background(_ color: Color) -> some View {
        background(PassthroughView(content: { color }))
    }
    
    @inlinable
    @available(*, deprecated, message: "Please use View.backgroundFill(_:) instead.")
    public func backgroundColor(_ color: Color) -> some View {
        background(color.edgesIgnoringSafeArea(.all))
    }
    
    @inlinable
    public func backgroundFill(_ color: Color) -> some View {
        background(color.edgesIgnoringSafeArea(.all))
    }
    
    @inlinable
    public func backgroundFill<BackgroundFill: View>(
        _ fill: BackgroundFill,
        alignment: Alignment = .center
    ) -> some View {
        background(fill.edgesIgnoringSafeArea(.all), alignment: alignment)
    }
    
    @inlinable
    public func backgroundFill<BackgroundFill: View>(
        alignment: Alignment = .center,
        @ViewBuilder _ fill: () -> BackgroundFill
    ) -> some View {
        backgroundFill(fill())
    }
}

// MARK: - View.overlay

extension View {
    @_disfavoredOverload
    @inlinable
    public func overlay<Overlay: View>(
        alignment: Alignment = .center,
        @ViewBuilder _ overlay: () -> Overlay
    ) -> some View {
        self.overlay(overlay(), alignment: alignment)
    }
}

// MARK: - View.hidden

extension View {
    /// Hides this view conditionally.
    @inlinable
    public func hidden(_ isHidden: Bool) -> some View {
        Group {
            if isHidden {
                hidden()
            } else {
                self
            }
        }
    }
}

// MARK: View.offset

extension View {
    @inlinable
    public func inset(_ point: CGPoint) -> some View {
        offset(x: -point.x, y: -point.y)
    }
    
    @inlinable
    public func inset(_ length: CGFloat) -> some View {
        offset(x: -length, y: -length)
    }
    
    @inlinable
    public func offset(_ point: CGPoint) -> some View {
        offset(x: point.x, y: point.y)
    }
    
    @inlinable
    public func offset(_ length: CGFloat) -> some View {
        offset(x: length, y: length)
    }
}

// MARK: - View.padding

extension View {
    /// A view that pads this view inside the specified edge insets with a system-calculated amount of padding and a color.
    @_disfavoredOverload
    @inlinable
    public func padding(_ color: Color) -> some View {
        padding().background(color)
    }
}

// MARK: - View.transition

extension View {
    /// Associates a transition with the view.
    public func transition(_ makeTransition: () -> AnyTransition) -> some View {
        self.transition(makeTransition())
    }
    
    /// Associates an insertion transition and a removal transition with the view.
    public func asymmetricTransition(
        insertion: AnyTransition = .identity,
        removal: AnyTransition = .identity
    ) -> some View {
        transition(.asymmetric(insertion: insertion, removal: removal))
    }
}

// MARK: - Debugging -

extension View {
    public func _printingChanges() -> Self {
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            Self._printChanges()

            return self
        } else {
            return self
        }
    }
}
