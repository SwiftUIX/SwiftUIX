//
// Copyright (c) Vatsal Manot
//

import SwiftUI

#if os(iOS) || targetEnvironment(macCatalyst)

@usableFromInline
struct EdgeSwipeGestureOverlay: UIViewRepresentable {
    @usableFromInline
    let edges: [Edge]
    @usableFromInline
    let action: Action
    
    @inlinable
    init(
        edges: [Edge],
        action: Action
    ) {
        self.edges = edges
        self.action = action
    }
    
    public func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        
        view.backgroundColor = .clear
        
        let recognizer = UIScreenEdgePanGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.didSwipe))
        
        recognizer.cancelsTouchesInView = false
        recognizer.edges = .init(edges)
        
        view.addGestureRecognizer(recognizer)
        
        return view
    }
    
    @inlinable
    public func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.base = self
    }
    
    @usableFromInline
    class Coordinator: NSObject {
        @usableFromInline
        var base: EdgeSwipeGestureOverlay
        
        public init(base: EdgeSwipeGestureOverlay) {
            self.base = base
        }
        
        @usableFromInline
        @objc func didSwipe() {
            base.action.perform()
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
    public func onScreenEdgePan(
        edges: [Edge],
        perform action: @escaping () -> Void = { }
    ) -> some View {
        overlay(EdgeSwipeGestureOverlay(edges: edges, action: .init(action)))
    }
}

#endif
