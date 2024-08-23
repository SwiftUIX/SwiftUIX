//
// Copyright (c) Vatsal Manot
//

import SwiftUI

#if os(iOS) || os(macOS) || os(tvOS) || os(visionOS) || targetEnvironment(macCatalyst)

@MainActor
@_documentation(visibility: internal)
public struct PresentWindow<Content: View>: View {
    private let content: () -> Content
    private let windowStyle: _WindowStyle
    private let position: _CoordinateSpaceRelative<CGPoint>?
    
    @PersistentObject var presentationController: _WindowPresentationController<Content>
    
    public init(
        style: _WindowStyle,
        position: _CoordinateSpaceRelative<CGPoint>? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.content = content
        self.windowStyle = style
        self.position = position
        
        self._presentationController = .init(wrappedValue: {
            let controller = _WindowPresentationController(
                style: style,
                visible: false,
                content: content
            )
            
            controller.setPosition(position)
            
            return controller
        }())
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
        
        presentationController.setPosition(position)
        presentationController.show()
        
        DispatchQueue.main.async {
            presentationController.bringToFront()
        }
    }
    
    private func dismiss() {
        presentationController.hide()
    }
}

#endif
