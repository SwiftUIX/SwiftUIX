//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

/// A lazily loaded view.
public struct LazyView<Body: View>: View {
    private let destination: () -> Body
    
    @_optimize(none)
    @inline(never)
    public init(destination: @escaping () -> Body) {
        self.destination = destination
    }
    
    @_optimize(none)
    @inline(never)
    public var body: some View {
        destination()
    }
}

public struct LazyAppearViewProxy {
    public enum Appearance: Equatable {
        case active
        case inactive
    }
    
    var _appearance: Appearance
    var _appearanceBinding: Binding<Appearance>
    
    public var appearance: Appearance {
        get {
            _appearanceBinding.wrappedValue
        } nonmutating set {
            _appearanceBinding.wrappedValue = newValue
        }
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs._appearance == rhs._appearance
    }
}

/// A view that appears lazily.
public struct LazyAppearView<Content: View>: View {
    public enum Placeholder {
        case hiddenFrame // frame of content.hidden()
    }

    private let placeholder: Placeholder?
    private let destination: (LazyAppearViewProxy) -> AnyView
    private var debounceInterval: DispatchTimeInterval?
    private var explicitAnimation: Animation? {
        didSet {
            if explicitAnimation != nil {
                disableAnimations = false
            }
        }
    }
    private var disableAnimations: Bool {
        didSet {
            if disableAnimations {
                explicitAnimation = nil
            }
        }
    }
    
    @ViewStorage private var updateAppearanceAction: DispatchWorkItem?
    
    @State private var appearance: LazyAppearViewProxy.Appearance = .inactive
    
    public init(
        debounceInterval: DispatchTimeInterval? = nil,
        animation: Animation,
        placeholder: Placeholder? = nil,
        @ViewBuilder destination: @escaping (LazyAppearViewProxy) -> Content
    ) {
        self.placeholder = placeholder
        self.destination = { destination($0).eraseToAnyView() }
        self.debounceInterval = debounceInterval
        self.explicitAnimation = animation
        self.disableAnimations = false
    }
    
    public init(
        debounceInterval: DispatchTimeInterval? = nil,
        animation: Animation,
        placeholder: Placeholder? = nil,
        @ViewBuilder destination: @escaping () -> Content
    ) {
        self.placeholder = placeholder
        self.destination = { proxy in
            PassthroughView {
                if proxy.appearance == .active {
                    destination()
                }
            }
            .eraseToAnyView()
        }
        self.debounceInterval = debounceInterval
        self.explicitAnimation = animation
        self.disableAnimations = false
    }
    
    public init(
        debounceInterval: DispatchTimeInterval? = nil,
        disableAnimations: Bool = false,
        placeholder: Placeholder? = nil,
        @ViewBuilder destination: @escaping (LazyAppearViewProxy) -> Content
    ) {
        self.placeholder = placeholder
        self.destination = { destination($0).eraseToAnyView() }
        self.debounceInterval = debounceInterval
        self.explicitAnimation = nil
        self.disableAnimations = disableAnimations
    }
    
    public init(
        debounceInterval: DispatchTimeInterval? = nil,
        disableAnimations: Bool = false,
        placeholder: Placeholder? = nil,
        @ViewBuilder destination: @escaping () -> Content
    ) {
        self.placeholder = placeholder
        self.destination = { proxy in
            PassthroughView {
                if proxy.appearance == .active {
                    destination()
                }
            }
            .eraseToAnyView()
        }
        self.debounceInterval = debounceInterval
        self.explicitAnimation = nil
        self.disableAnimations = disableAnimations
    }
    
    public var body: some View {
        ZStack {
            placeholderView
                .onAppear {
                    setAppearance(.active)
                }
                .onDisappear {
                    setAppearance(.inactive)
                }
            
            destination(
                .init(
                    _appearance: appearance,
                    _appearanceBinding: .init(get: { appearance }, set: { setAppearance($0) })
                )
            )
            .modify(if: disableAnimations) {
                $0.animation(nil, value: appearance)
            }
        }
    }
    
    @ViewBuilder
    private var placeholderView: some View {
        ZStack {
            if let placeholder {
                if appearance == .inactive {
                    switch placeholder {
                        case .hiddenFrame:
                            destination(.init(_appearance: .active, _appearanceBinding: .constant(.active)))
                                .hidden()
                    }
                }
            } else {
                ZeroSizeView()
            }
        }
        .allowsHitTesting(false)
        .accessibility(hidden: false)
    }
    
    private func setAppearance(_ appearance: LazyAppearViewProxy.Appearance) {
        let mutateAppearance: () -> Void = {
            if let animation = explicitAnimation {
                withAnimation(animation) {
                    self.appearance = appearance
                }
            } else {
                withoutAnimation(disableAnimations) {
                    self.appearance = appearance
                }
            }
        }
        
        if let debounceInterval = debounceInterval {
            let updateAppearanceAction = DispatchWorkItem(block: mutateAppearance)
            
            self.updateAppearanceAction?.cancel()
            self.updateAppearanceAction = updateAppearanceAction
            
            DispatchQueue.main.asyncAfter(deadline: .now() + debounceInterval, execute: updateAppearanceAction)
        } else {
            mutateAppearance()
        }
    }
}

extension LazyAppearView {
    public func delay(_ delay: DispatchTimeInterval?) -> Self {
        then {
            $0.debounceInterval = delay
        }
    }

    public func animation(_ animation: Animation?) -> Self {
        then {
            $0.explicitAnimation = animation
        }
    }
    
    public func animationDisabled(_ disabled: Bool) -> Self {
        then {
            $0.disableAnimations = disabled
        }
    }
}

private struct _DestroyOnDisappear: ViewModifier {
    @State private var id = UUID()
    
    func body(content: Content) -> some View {
        content
            .id(id)
            .onDisappear {
                id = UUID()
            }
    }
}

extension View {
    /// Resets the view's identity every time it disappears.
    public func _destroyOnDisappear() -> some View {
        modifier(_DestroyOnDisappear())
    }
}
