//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || targetEnvironment(macCatalyst)

import SwiftUI

private struct PopoverViewModifier<PopoverContent>: ViewModifier where PopoverContent: View {
    @Binding var isPresented: Bool
    let arrowEdge: Edge
    let onDismiss: (() -> Void)?
    let content: () -> PopoverContent
    
    func body(content: Content) -> some View {
        content.background(
            _CocoaPopoverInjector(
                isPresented: self.$isPresented,
                arrowEdge: arrowEdge,
                onDismiss: self.onDismiss,
                content: self.content
            )
        )
    }
}

// MARK: - API -

extension View {
    public func cocoaPopover<Content>(
        isPresented: Binding<Bool>,
        arrowEdge: Edge = .top,
        onDismiss: (() -> Void)? = nil,
        content: @escaping () -> Content
    ) -> some View where Content: View {
        modifier(
            PopoverViewModifier(
                isPresented: isPresented,
                arrowEdge: arrowEdge,
                onDismiss: onDismiss,
                content: content
            )
        )
    }
}

private struct _CocoaPopoverInjector<Content: View> : UIViewControllerRepresentable {
    class Coordinator: NSObject, UIPopoverPresentationControllerDelegate {
        let host: UIHostingController<Content>
        
        private let parent: _CocoaPopoverInjector
        
        init(parent: _CocoaPopoverInjector, content: Content) {
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
    
    let arrowEdge: Edge
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
            host.popoverPresentationController?.permittedArrowDirections = .init(PopoverArrowDirection(arrowEdge))
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

#endif
