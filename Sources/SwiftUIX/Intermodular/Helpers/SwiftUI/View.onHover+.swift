//
// Copyright (c) Vatsal Manot
//

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

#if os(iOS) || os(macOS)
@available(iOS 14, macOS 11.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
private struct _OnLongHover: ViewModifier {
    let enabled: Bool
    let minimumDuration: TimeInterval
    let action: (Bool) -> Void
    
    @ViewStorage private var isHovering: Bool = false
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if enabled {
                    Rectangle()
                        .fill(Color.clear)
                        .onHover { isHovering in
                            self.isHovering = isHovering
                        }
                        .background {
                            $isHovering.withObservedValue { isHovering in
                                if enabled && isHovering {
                                    emptyRecognizerView
                                }
                            }
                        }
                }
            }
    }
    
    @ViewBuilder
    private var emptyRecognizerView: some View {
        withInlineTimerState(interval: minimumDuration) { tick in
            if tick >= 1 {
                ZeroSizeView()
                    .onAppear {
                        guard isHovering else {
                            return
                        }
                        
                        action(true)
                    }
                    .onDisappear {
                        action(false)
                    }
            }
        }
        .id(isHovering)
    }
}

@available(iOS 14, macOS 11.0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension View {
    public func onLongHover(
        _ enabled: Bool = true,
        minimumDuration: TimeInterval = 1.0,
        perform action: @escaping (Bool) -> Void
    ) -> some View {
        modifier(_OnLongHover(enabled: enabled, minimumDuration: minimumDuration, action: action))
    }
}
#endif
