//
// Copyright (c) Vatsal Manot
//

#if swift(>=5.2)

@available(iOS 13, OSX 10.15, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public struct _OnHoverViewModifier: ViewModifier {
  
    public var onHover: (Bool) -> Void
    
    @inlinable
    public init(onHover: @escaping (Bool) -> Void) {
        self.onHover = onHover
    }
    
    @inlinable
    public func body(content: Content) -> some View {
        if #available(iOS 13.4, *) {
            return content
              .onHover(perform: onHover)
        } else {
            fatalError("Use View.onHoverIfAvailable instead.")
        }
    }
  
}

@available(iOS 13, OSX 10.15, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension View {
  
    @inlinable
    public func onHoverIfAvailable(perform action: @escaping (Bool) -> Void) -> some View {
        typealias Content = _ConditionalContent<ModifiedContent<Self, _OnHoverViewModifier>, Self>
        
        if #available(iOS 13.4, *) {
            return ViewBuilder.buildEither(first: modifier(_OnHoverViewModifier(onHover: action))) as Content
        } else {
            return ViewBuilder.buildEither(second: self) as Content
        }
    }
  
}

#endif
