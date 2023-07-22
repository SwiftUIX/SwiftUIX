//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || targetEnvironment(macCatalyst)

import SwiftUI

private struct PopoverViewModifier<PopoverContent>: ViewModifier where PopoverContent: View {
    @Binding var isPresented: Bool
    let arrowEdges: Edge.Set
    let onDismiss: (() -> Void)?
    let content: () -> PopoverContent
    
    func body(content: Content) -> some View {
        content.background(
            _AttachCocoaPopoverPresenter(
                isPresented: self.$isPresented,
                arrowEdges: arrowEdges,
                onDismiss: self.onDismiss,
                content: self.content
            )
        )
    }
}

// MARK: - API

extension View {
    public func cocoaPopover<Content: View>(
        isPresented: Binding<Bool>,
        arrowEdges: Edge.Set,
        onDismiss: (() -> Void)? = nil,
        content: @escaping () -> Content
    ) -> some View {
        modifier(
            PopoverViewModifier(
                isPresented: isPresented,
                arrowEdges: arrowEdges,
                onDismiss: onDismiss,
                content: content
            )
        )
    }
    
    public func cocoaPopover<Content: View>(
        isPresented: Binding<Bool>,
        arrowEdge: Edge,
        onDismiss: (() -> Void)? = nil,
        content: @escaping () -> Content
    ) -> some View  {
        self.cocoaPopover(
            isPresented: isPresented,
            arrowEdges: .init(edge: arrowEdge),
            onDismiss: onDismiss,
            content: content
        )
    }
}

// MARK: - Implementation

private struct _AttachCocoaPopoverPresenter<Content: View> : UIViewControllerRepresentable {
    class Coordinator: NSObject, UIPopoverPresentationControllerDelegate {
        let host: UIHostingController<Content>
        
        private let parent: _AttachCocoaPopoverPresenter
        
        init(parent: _AttachCocoaPopoverPresenter, content: Content) {
            self.parent = parent
            self.host = UIHostingController(rootView: content)
        }
        
        func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
            self.parent.isPresented = false
            if let onDismiss = self.parent.onDismiss {
                onDismiss()
            }
        }
        
        func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
            .none
        }
    }
    
    @Binding var isPresented: Bool
    
    let arrowEdges: Edge.Set
    let onDismiss: (() -> Void)?
    
    @ViewBuilder let content: () -> Content
    
    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        let host = context.coordinator.host
        host.rootView = content()
        
        if host.viewIfLoaded?.window == nil && self.isPresented {
            host.preferredContentSize = host.sizeThatFits(in: UIView.layoutFittingExpandedSize)
            
            host.modalPresentationStyle = UIModalPresentationStyle.popover
            
            host.popoverPresentationController?.delegate = context.coordinator
            host.popoverPresentationController?.permittedArrowDirections = arrowEdges.permittedArrowDirection
            host.popoverPresentationController?.sourceView = uiViewController.view
            host.popoverPresentationController?.sourceRect = uiViewController.view.bounds
            
            uiViewController.present(host, animated: true, completion: nil)
            
        } else if self.isPresented == false {
            host.dismiss(animated: true, completion: nil)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self, content: self.content())
    }
}

// MARK: - Auxiliary

private extension Edge.Set {
    var permittedArrowDirection: UIPopoverArrowDirection {
        var directions: UIPopoverArrowDirection = .unknown
        
        if contains(.top) {
            directions.insert(.up)
        }
        
        if contains(.bottom) {
            directions.insert(.down)
        }
        
        if contains(.leading) {
            directions.insert(.left)
        }
        
        if contains(.trailing) {
            directions.insert(.right)
        }
        
        guard directions != .unknown else {
            return .any
        }
        
        return directions
    }
}

#endif
