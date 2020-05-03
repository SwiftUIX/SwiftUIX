//
// Copyright (c) Vatsal Manot
//

import SwiftUI

#if os(iOS) || targetEnvironment(macCatalyst)

struct SwipeGestureOverlay: UIViewRepresentable {
    private let onSwipeUp: Action
    private let onSwipeLeft: Action
    private let onSwipeDown: Action
    private let onSwipeRight: Action
    
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
    
    public func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.base = self
    }
    
    class Coordinator: NSObject {
        fileprivate var base: SwipeGestureOverlay
        
        public init(base: SwipeGestureOverlay) {
            self.base = base
        }
        
        @objc fileprivate func didSwipeUp() {
            base.onSwipeUp.perform()
        }
        
        @objc fileprivate func didSwipeLeft() {
            base.onSwipeLeft.perform()
        }
        
        @objc fileprivate func didSwipeDown() {
            base.onSwipeDown.perform()
        }
        
        @objc fileprivate func didSwipeRight() {
            base.onSwipeRight.perform()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        .init(base: self)
    }
}

// MARK: - API -

extension View {
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
    
    public func onSwipeUpGesture(
        perform action: @escaping () -> Void
    ) -> some View {
        onSwipeGestures(onSwipeUp: action)
    }
}

#endif
