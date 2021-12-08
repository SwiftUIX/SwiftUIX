//
// Copyright (c) Vatsal Manot
//

@available(iOS 13, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(OSX, unavailable)
public struct _HoverEffectViewModifier: ViewModifier {
    public let hoverEffect: HoverEffect
    
    public init(hoverEffect: HoverEffect) {
        self.hoverEffect = hoverEffect
    }

    public func body(content: Content) -> some View {
        if #available(iOS 13.4, iOSApplicationExtension 14.0, macCatalystApplicationExtension 14.0, *) {
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
    public func hoverEffectIfAvailable(_ effect: HoverEffect = .automatic) -> some View {
        typealias Content = _ConditionalContent<ModifiedContent<Self, _HoverEffectViewModifier>, Self>
        
        if #available(iOS 13.4, iOSApplicationExtension 14.0, macCatalystApplicationExtension 14.0, *) {
            return ViewBuilder.buildEither(first: modifier(_HoverEffectViewModifier(hoverEffect: effect))) as Content
        } else {
            return ViewBuilder.buildEither(second: self) as Content
        }
    }
}
