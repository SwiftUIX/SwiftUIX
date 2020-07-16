//
// Copyright (c) Vatsal Manot
//

#if swift(>=5.2)

@available(iOS 13, OSX 10.15, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension View {
    @inlinable
    @ViewBuilder
    public func onHoverIfAvailable(perform action: @escaping (Bool) -> Void) -> some View {
        #if swift(>=5.3)
        if #available(iOS 13.4, *) {
            self.onHover(perform: action)
        } else {
            self
        }
        #else
        if #available(iOS 13.4, *) {
            self.onHover(perform: action)
        } else {
            self
        }
        #endif
    }
}

#endif
