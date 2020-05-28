//
// Copyright (c) Vatsal Manot
//

import SwiftUI

#if os(iOS) || targetEnvironment(macCatalyst)

@usableFromInline
struct SwipeGestureOverlay: UIViewRepresentable {
    @usableFromInline
    let onSwipeUp: Action
    
    @usableFromInline
    let onSwipeLeft: Action
    
    @usableFromInline
    let onSwipeDown: Action
    
    @usableFromInline
    let onSwipeRight: Action
    
    @inlinable
    init(
        onSwipeUp: Action,
        onSwipeLeft: Action,
        onSwipeDown: Action,
        onSwipeRight: Action
    ) {
        self.onSwipeUp = onSwipeUp
        self.onSwipeLeft = onSwipeLeft
        self.onSwipeRight = onSwipeRight
        self.onSwipeDown = onSwipeDown
    }
    
    @inlinable
    public func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        view.backgroundColor = .clear
        
        view.addSwipeGestureRecognizer(
            for: .up,
            target: context.coordinator,
            action: #selector(context.coordinator.didSwipeUp)
        )
        
        view.addSwipeGestureRecognizer(
            for: .left,
            target: context.coordinator,
            action: #selector(context.coordinator.didSwipeLeft)
        )
        
        view.addSwipeGestureRecognizer(
            for: .down,
            target: context.coordinator,
            action: #selector(context.coordinator.didSwipeDown)
        )
        
        view.addSwipeGestureRecognizer(
            for: .right,
            target: context.coordinator,
            action: #selector(context.coordinator.didSwipeRight)
        )
        
        return view
    }
    
    @inlinable
    public func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.base = self
    }
    
    @usableFromInline
    class Coordinator: NSObject {
        @usableFromInline
        var base: SwipeGestureOverlay
        
        public init(base: SwipeGestureOverlay) {
            self.base = base
        }
        
        @usableFromInline
        @objc func didSwipeUp() {
            base.onSwipeUp.perform()
        }
        
        @usableFromInline
        @objc func didSwipeLeft() {
            base.onSwipeLeft.perform()
        }
        
        @usableFromInline
        @objc func didSwipeDown() {
            base.onSwipeDown.perform()
        }
        
        @usableFromInline
        @objc func didSwipeRight() {
            base.onSwipeRight.perform()
        }
    }
    
    @usableFromInline
    func makeCoordinator() -> Coordinator {
        .init(base: self)
    }
}

// MARK: - API -

extension View {
    @inlinable
    public func onSwipeGestures(
        onSwipeUp: @escaping () -> Void = {},
        onSwipeLeft: @escaping () -> Void = {},
        onSwipeDown: @escaping () -> Void = {},
        onSwipeRight: @escaping () -> Void = {}
    ) -> some View {
        overlay(
            SwipeGestureOverlay(
                onSwipeUp: .init(onSwipeUp),
                onSwipeLeft: .init(onSwipeLeft),
                onSwipeDown: .init(onSwipeDown),
                onSwipeRight: .init(onSwipeRight)
            )
        )
    }
    
    @inlinable
    public func onSwipeUpGesture(
        perform action: @escaping () -> Void
    ) -> some View {
        onSwipeGestures(onSwipeUp: action)
    }
}

#endif
