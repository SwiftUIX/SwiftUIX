//
// Copyright (c) Vatsal Manot
//

import SwiftUI

#if os(iOS) || targetEnvironment(macCatalyst)
/// This is a SwiftUI port of the UIKit `UIImagePickerController`.
///
/// The SwiftUIX `ImagePicker` is a simple, efficient, and native SwiftUI way to display the equivalent of a `UIImagePickerController`.
///
/// ## Usage
///
/// To use the Image Picker, define a variable of type `Data` and pass it into `ImagePicker`. The user's picked image can be accessed from the variable.
///
/// ```swift
/// struct ContentView: View {
///     @State var image: Data?
///
///     var body: some View {
///         VStack {
///             ImagePicker(data: $image, encoding: .png, onCancel: { })
///             if let image = image {
///             Image(data: image)?
///                 .resizable()
///                 .aspectRatio(contentMode: .fill)
///                 .frame(width: 200,height: 200)
///                 .clipped()
///             }
///         }
///     }
/// }
/// ```
///
/// The `ImagePicker` takes in 3 parameters: `data`, `encoding` and `onCancel`. `onCancel` is optional.
///
/// The `data` parameter takes in a optional `Data` type binding. In the code example above, the value of variable `image` will be provided by the `ImagePicker`. If you want to display the result of the `ImagePicker`, simply use `Image(data:)` to convert the `Data` into an `Image`.
///
/// The `encoding` parameter is an `enum` that takes in either JPEG or PNG as the encoding format. PNG or Portable Network Graphics is a loseless format for images. JPEG offers the compression quality parameter that can be 1 (very low quality) or 100 (very high quality)
///
/// `onCancel` specifies a closure to be run when the "Cancel" button is pressed.
public struct ImagePicker: UIViewControllerRepresentable {
    public typealias UIViewControllerType = UIImagePickerController
    
    @Environment(\.presentationManager) var presentationManager
    
    let info: Binding<[UIImagePickerController.InfoKey: Any]?>?
    let image: Binding<AppKitOrUIKitImage?>?
    let data: Binding<Data?>?
    
    let encoding: Image.Encoding?
    var allowsEditing = false
    var cameraDevice: UIImagePickerController.CameraDevice?
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    var mediaTypes: [String]?
    var onCancel: (() -> Void)?
    
    public func makeUIViewController(context: Context) -> UIViewControllerType {
        UIImagePickerController().then {
            $0.delegate = context.coordinator
        }
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        context.coordinator.base = self
        
        uiViewController.allowsEditing = allowsEditing
        uiViewController.sourceType = sourceType
        
        if let mediaTypes = mediaTypes, uiViewController.mediaTypes != mediaTypes  {
            uiViewController.mediaTypes = mediaTypes
        }
        
        if uiViewController.sourceType == .camera {
            uiViewController.cameraDevice = cameraDevice ?? .rear
        }
    }
    
    public class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var base: ImagePicker
        
        init(base: ImagePicker) {
            self.base = base
        }
        
        public func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            let image = (info[UIImagePickerController.InfoKey.editedImage] as? UIImage) ?? (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)
            
            base.info?.wrappedValue = info
            base.image?.wrappedValue = image
            base.data?.wrappedValue = (image?._fixOrientation() ?? image)?.data(using: base.encoding ?? .png)
            
            base.presentationManager.dismiss()
        }
        
        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            if let onCancel = base.onCancel {
                onCancel()
            } else {
                base.presentationManager.dismiss()
            }
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        .init(base: self)
    }
}

// MARK: - API

extension ImagePicker {


    /// Create an image picker with picker controller info.
    ///
    /// - Parameters:
    ///   - info: Image picker controller information.
    ///   - onCancel: An action to trigger when the image picker cancels.
    public init(
        info: Binding<[UIImagePickerController.InfoKey: Any]?>,
        onCancel: (() -> Void)? = nil
    ) {
        self.info = info
        self.image = nil
        self.data = nil
        self.encoding = nil
        self.onCancel = onCancel
    }
    
    /// Create an image picker with an image binding and a certain encoding.
    ///
    /// - Parameters:
    ///   - image: The image binding to use.
    ///   - encoding: The image encoding to use.
    ///   - onCancel: An action to trigger when the image picker cancels.
    public init(
        image: Binding<AppKitOrUIKitImage?>,
        encoding: Image.Encoding? = nil,
        onCancel: (() -> Void)? = nil
    ) {
        self.info = nil
        self.image = image
        self.data = nil
        self.encoding = encoding
        self.onCancel = onCancel
    }

    /// Create an image picker with image data binding and a certain encoding.
    ///
    /// - Parameters:
    ///   - image: The image data binding to use.
    ///   - encoding: The image encoding to use.
    ///   - onCancel: An action to trigger when the image picker cancels.
    public init(
        data: Binding<Data?>,
        encoding: Image.Encoding? = nil,
        onCancel: (() -> Void)? = nil
    ) {
        self.info = nil
        self.image = nil
        self.data = data
        self.encoding = encoding
        self.onCancel = onCancel
    }
}

extension ImagePicker {
    public func allowsEditing(_ allowsEditing: Bool) -> Self {
        then({ $0.allowsEditing = allowsEditing })
    }
    
    public func cameraDevice(_ cameraDevice: UIImagePickerController.CameraDevice?) -> Self {
        then({ $0.cameraDevice = cameraDevice })
    }
    
    public func sourceType(_ sourceType: UIImagePickerController.SourceType) -> Self {
        then({ $0.sourceType = sourceType })
    }
    
    public func mediaTypes(_ mediaTypes: [String]) -> Self {
        then({ $0.mediaTypes = mediaTypes })
    }
}
#endif

// MARK: - Helpers

#if os(iOS) || os(tvOS) || os(visionOS) || os(watchOS)
extension UIImage {
    public func data(
        using encoding: Image.Encoding
    ) -> Data? {
        switch encoding {
            case .png:
                return pngData()
            case .jpeg(let compressionQuality):
                return jpegData(compressionQuality: compressionQuality ?? 1.0)
        }
    }
    
    func _fixOrientation() -> UIImage? {
        guard imageOrientation != .up else {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        defer {
            UIGraphicsEndImageContext()
        }
        
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
#elseif os(macOS)
extension NSImage {
    public func data(
        using encoding: Image.Encoding
    ) -> Data? {
        guard let tiffRepresentation = self.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else {
            return nil
        }
                
        var properties: [NSBitmapImageRep.PropertyKey : Any] = [:]
        
        switch encoding {
            case .png:
                guard let data = bitmapImage.representation(using: .png, properties: properties) else {
                    return nil
                }
                
                return data
            case .jpeg(let compressionQuality):
                if let compressionQuality {
                    properties[.compressionFactor] = compressionQuality
                }
                
                guard let data = bitmapImage.representation(using: .jpeg, properties: properties) else {
                    return nil
                }
                
                return data
        }
    }
}
#endif
