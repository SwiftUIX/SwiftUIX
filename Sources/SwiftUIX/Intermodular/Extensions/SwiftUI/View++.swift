//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

// MARK: - View.then

extension View {
    @inlinable
    public func then(_ body: (inout Self) -> Void) -> Self {
        var result = self
        
        body(&result)
        
        return result
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

// MARK: - View.listRowBackground

extension View {
    public func listRowBackground<Content: View>(
        @ViewBuilder _ background: () -> Content
    ) -> some View {
        listRowBackground(background())
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
    @_disfavoredOverload
    @inlinable
    public func hidden(_ isHidden: Bool) -> some View {
        PassthroughView {
            if isHidden {
                hidden()
            } else {
                self
            }
        }
    }
}

// MARK: View.id

extension View {
    @_spi(Internal)
    public func _opaque_id(_ hashable: AnyHashable) -> some View {
        func _makeView<ID: Hashable>(_ id: ID) -> AnyView {
            self.id(id).eraseToAnyView()
        }
        
        return _openExistential(hashable.base as! (any Hashable), do: _makeView)
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

// MARK: - View.onAppear

@MainActor
extension View {
    public func onAppearOnce(perform action: @escaping () -> Void) -> some View {
        withInlineState(initialValue: false) { $didAppear in
            self.onAppear {
                guard !didAppear else {
                    return
                }
                
                action()
                
                didAppear = true
            }
        }
    }
}

// MARK: - View.transition

extension View {
    /// Associates a transition with the view.
    public func transition(_ makeTransition: () -> AnyTransition) -> some View {
        self.transition(makeTransition())
    }
    
    public func asymmetricTransition(
        insertion: AnyTransition
    ) -> some View {
        transition(.asymmetric(insertion: insertion, removal: .identity))
    }
    
    public func asymmetricTransition(
        removal: AnyTransition
    ) -> some View {
        transition(.asymmetric(insertion: .identity, removal: removal))
    }
    
    /// Associates an insertion transition and a removal transition with the view.
    public func asymmetricTransition(
        insertion: AnyTransition,
        removal: AnyTransition
    ) -> some View {
        transition(.asymmetric(insertion: insertion, removal: removal))
    }
}

// MARK: - Debugging

extension View {
    public func _printChanges_printingChanges() -> Self {
        if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            Self._printChanges()
            
            return self
        } else {
            return self
        }
    }
}

#if swift(>=5.9)
#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS)
extension View {
    @ViewBuilder
    public func _SwiftUIX_defaultScrollAnchor(
        _ unitPoint: UnitPoint?
    ) -> some View {
        if #available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *) {
            defaultScrollAnchor(.bottom)
        } else {
            self
        }
    }
}
#endif
#endif
