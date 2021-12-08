//
// Copyright (c) Vatsal Manot
//

#if swift(>=5.2)

@available(iOS 13, OSX 10.15, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)

private struct _OnHoverViewModifier: ViewModifier {
    public var onHover: (Bool) -> Void
    
    @inlinable
    public init(onHover: @escaping (Bool) -> Void) {
        self.onHover = onHover
    }
    
    @inlinable
    public func body(content: Content) -> some View {
        if #available(iOS 13.4, iOSApplicationExtension 14.0, macCatalystApplicationExtension 14.0, *) {
            return content.onHover(perform: onHover)
        } else {
            fatalError("Use View.onHoverIfAvailable instead.")
        }
    }
    
}

@available(iOS 13, OSX 10.15, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension View {
    public func onHoverIfAvailable(perform action: @escaping (Bool) -> Void) -> some View {
        if #available(iOS 13.4, iOSApplicationExtension 14.0, macCatalystApplicationExtension 14.0, *) {
            return ViewBuilder.buildEither(first: modifier(_OnHoverViewModifier(onHover: action))) as _ConditionalContent<ModifiedContent<Self, _OnHoverViewModifier>, Self>
        } else {
            return ViewBuilder.buildEither(second: self) as _ConditionalContent<ModifiedContent<Self, _OnHoverViewModifier>, Self>
        }
    }
}

#endif
