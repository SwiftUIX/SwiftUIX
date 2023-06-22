//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if (os(iOS) && canImport(CoreTelephony)) || os(tvOS) || targetEnvironment(macCatalyst)

struct TakeSnapshotView<Content: View>: UIViewControllerRepresentable {
    let image: Binding<UIImage?>
    let content: Content
    
    init(image: Binding<UIImage?>, content: Content) {
        self.image = image
        self.content = content
    }
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        .init(mainView: content)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        uiViewController.image = image
        uiViewController.mainView = content
        
        Task { @MainActor in
            uiViewController.takeSnapshot()
        }
    }
}

extension TakeSnapshotView {
    class UIViewControllerType: CocoaHostingController<Content> {
        var image: Binding<UIImage?>? = nil
                
        override open func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            
            DispatchQueue.main.async {
                self.takeSnapshot()
            }
        }
        
        func takeSnapshot() {
            guard
                let image,
                image.wrappedValue == nil,
                view.superview != nil,
                (view.layer.animationKeys() ?? []).count == 0,
                UIView.inheritedAnimationDuration == 0
            else {
                return
            }
                        
            guard view.frame.size.width >= 1 && view.frame.size.height >= 1 else {
                Task { @MainActor in
                    image.wrappedValue = mainView._renderAsImage()
                }
                
                return
            }
            
            UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
            
            defer {
                UIGraphicsEndImageContext()
            }
            
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
            
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            
            if image.wrappedValue?.pngData() != newImage?.pngData() {
                image.wrappedValue = newImage
            }
        }
    }
}

extension View {
    @MainActor
    func _renderAsImage() -> AppKitOrUIKitImage? {
        let hostingController = CocoaHostingController(mainView: self.edgesIgnoringSafeArea(.all))
        
        let view = hostingController.view
        let targetSize = hostingController.view.intrinsicContentSize
        
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        return renderer.image { _ in
            view?.drawHierarchy(in: hostingController.view.bounds, afterScreenUpdates: true)
        }
    }
}

// MARK: - API

extension View {
    /// Takes a screenshot when this view appears and passes it via the `image` binding.
    public func screenshotOnAppear(to image: Binding<UIImage?>) -> some View {
        TakeSnapshotView(image: image, content: self)
    }
    
    @available(iOS, deprecated: 13.0, renamed: "screenshotOnAppear(to:)")
    public func snapshot(to image: Binding<UIImage?>) -> some View {
        screenshotOnAppear(to: image)
    }
}

#endif
