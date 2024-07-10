//
// Copyright (c) Vatsal Manot
//

import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

public struct PresentWindow<Content: View>: View {
    private let content: () -> Content
    private let windowStyle: _WindowStyle
    private let position: _CoordinateSpaceRelative<CGPoint>?
    
    @MainActor(unsafe)
    @PersistentObject var presentationController: _WindowPresentationController<Content>
    
    @MainActor(unsafe)
    public init(
        style: _WindowStyle,
        position: _CoordinateSpaceRelative<CGPoint>? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
        self.windowStyle = style
        self.position = position
        
        self._presentationController = .init(wrappedValue: _WindowPresentationController(
            style: style,
            content: content
        ))
    }
    
    public var body: some View {
        ZeroSizeView()
            .onAppear {
                present()
            }
            .onDisappear() {
                dismiss()
            }
    }
    
    private func present() {
        self.presentationController.content = content()
        
        presentationController.show()
        
        if let position {
            presentationController.setPosition(position)
        }
        
        DispatchQueue.main.async {
            presentationController.bringToFront()
        }
    }
    
    private func dismiss() {
        presentationController.hide()
    }
}

#endif
