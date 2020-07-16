//
// Copyright (c) Vatsal Manot
//

#if swift(>=5.2)

@available(iOS 13, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(OSX, unavailable)
extension View {
    @inlinable
    @ViewBuilder
    public func hoverEffectIfAvailable(_ effect: HoverEffect = .automatic) -> some View {
        #if swift(>=5.3)
        if #available(iOS 13.4, *) {
            self.hoverEffect(.init(effect))
        } else {
            self
        }
        #else
        if #available(iOS 13.4, *) {
            self.hoverEffect(.init(effect))
        } else {
            self
        }
        #endif
    }
}

#endif
