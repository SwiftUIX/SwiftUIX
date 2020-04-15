//
// Copyright (c) Vatsal Manot
//

#if swift(>=5.2)

@available(iOS 13, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(OSX, unavailable)
public struct _HoverEffectViewModifier: ViewModifier {
    public let hoverEffect: HoverEffect
    
    @inlinable
    public init(hoverEffect: HoverEffect) {
        self.hoverEffect = hoverEffect
    }
    
    @inlinable
    public func body(content: Content) -> some View {
        if #available(iOS 13.4, *) {
            return content.hoverEffect(.init(hoverEffect))
        } else {
            fatalError("Use View.hoverEffectIfAvailable instead.")
        }
    }
    
}

@available(iOS 13, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(OSX, unavailable)
extension View {
    @inlinable
    public func hoverEffectIfAvailable(_ effect: HoverEffect = .automatic) -> some View {
        typealias Content = _ConditionalContent<ModifiedContent<Self, _HoverEffectViewModifier>, Self>
        
        if #available(iOS 13.4, *) {
            return ViewBuilder.buildEither(first: modifier(_HoverEffectViewModifier(hoverEffect: effect))) as Content
        } else {
            return ViewBuilder.buildEither(second: self) as Content
        }
    }
}

#endif
