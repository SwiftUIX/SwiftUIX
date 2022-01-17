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
}

/// A view that appears lazily.
public struct LazyAppearView<Content: View>: View {
    private let debounceInterval: DispatchTimeInterval?
    private let destination: (LazyAppearViewProxy) -> Content
    
    @ViewStorage private var updateAppearanceAction: DispatchWorkItem?
    
    @State private var appearance: LazyAppearViewProxy.Appearance = .inactive
    
    public init(
        debounceInterval: DispatchTimeInterval? = nil,
        @ViewBuilder destination: @escaping (LazyAppearViewProxy) -> Content
    ) {
        self.debounceInterval = debounceInterval
        self.destination = destination
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
            
            destination(.init(_appearance: appearance, _appearanceBinding: .init(get: { appearance }, set: { setAppearance($0) })))
        }
    }
    
    private func setAppearance(_ appearance: LazyAppearViewProxy.Appearance) {
        if let debounceInterval = debounceInterval {
            updateAppearanceAction?.cancel()
            
            let updateAppearanceAction = DispatchWorkItem {
                self.appearance = .active
            }
            
            self.updateAppearanceAction = updateAppearanceAction
            
            DispatchQueue.main.asyncAfter(deadline: .now() + debounceInterval, execute: updateAppearanceAction)
        } else {
            self.appearance = appearance
        }
    }
}
