
//  Created by Basel Baragabah on 10/10/2021.

import SwiftUI

struct PopoverViewModifier<PopoverContent>: ViewModifier where PopoverContent: View {
    @Binding var isPresented: Bool
    let onDismiss: (() -> Void)?
    let content: () -> PopoverContent

    func body(content: Content) -> some View {
        content
            .background(
                Popover(
                    isPresented: self.$isPresented,
                    onDismiss: self.onDismiss,
                    content: self.content
                )
            )
    }
}

extension View {
    func cocoaPopover<Content>(
        isPresented: Binding<Bool>,
        onDismiss: (() -> Void)? = nil,
        content: @escaping () -> Content
    ) -> some View where Content: View {
        ModifiedContent(
            content: self,
            modifier: PopoverViewModifier(
                isPresented: isPresented,
                onDismiss: onDismiss,
                content: content
            )
        )
    }
}

struct Popover<Content: View> : UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let onDismiss: (() -> Void)?
    @ViewBuilder let content: () -> Content

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self, content: self.content())
    }

    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        let host = context.coordinator.host
        host.rootView = content()
        
        if host.viewIfLoaded?.window == nil && self.isPresented {
            host.preferredContentSize = host.sizeThatFits(in: CGSize(width: Int.max , height: Int.max))
            host.modalPresentationStyle = UIModalPresentationStyle.popover
            host.popoverPresentationController?.delegate = context.coordinator
            host.popoverPresentationController?.sourceView = uiViewController.view
            host.popoverPresentationController?.sourceRect = uiViewController.view.bounds
            uiViewController.present(host, animated: true, completion: nil)
            
        } else if self.isPresented == false {
            host.dismiss(animated: true, completion: nil)
        }
    }


    class Coordinator: NSObject, UIPopoverPresentationControllerDelegate {
        let host: UIHostingController<Content>
        private let parent: Popover

        init(parent: Popover, content: Content) {
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
            return .none
        }
    }
}
