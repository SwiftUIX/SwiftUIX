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
    private let destination: (LazyAppearViewProxy) -> AnyView
    private let debounceInterval: DispatchTimeInterval?
    private let explicitAnimation: Animation?
    private let disableAnimations: Bool
    
    @ViewStorage private var updateAppearanceAction: DispatchWorkItem?
    
    @State private var appearance: LazyAppearViewProxy.Appearance = .inactive
    
    public init(
        debounceInterval: DispatchTimeInterval? = nil,
        animation: Animation,
        @ViewBuilder destination: @escaping (LazyAppearViewProxy) -> Content
    ) {
        self.destination = { destination($0).eraseToAnyView() }
        self.debounceInterval = debounceInterval
        self.explicitAnimation = animation
        self.disableAnimations = false
    }
    
    public init(
        debounceInterval: DispatchTimeInterval? = nil,
        animation: Animation,
        @ViewBuilder destination: @escaping () -> Content
    ) {
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
        @ViewBuilder destination: @escaping (LazyAppearViewProxy) -> Content
    ) {
        self.destination = { destination($0).eraseToAnyView() }
        self.debounceInterval = debounceInterval
        self.explicitAnimation = nil
        self.disableAnimations = disableAnimations
    }
    
    public init(
        debounceInterval: DispatchTimeInterval? = nil,
        disableAnimations: Bool = false,
        @ViewBuilder destination: @escaping () -> Content
    ) {
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
            ZeroSizeView()
                .onAppear {
                    setAppearance(.active)
                }
                .onDisappear {
                    setAppearance(.inactive)
                }
                .allowsHitTesting(false)
                .accessibility(hidden: false)
            
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
