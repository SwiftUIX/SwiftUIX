//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || targetEnvironment(macCatalyst)

/// A SwiftUI port of `UIImagePickerController`.
public struct ImagePicker: UIViewControllerRepresentable {
    public typealias UIViewControllerType = UIImagePickerController
    
    @Environment(\.presentationManager) var presentationManager
    
    @usableFromInline
    @Binding var data: Data?
    @usableFromInline
    let encoding: Image.Encoding
    @usableFromInline
    var allowsEditing = false
    @usableFromInline
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    public func makeUIViewController(context: Context) -> UIViewControllerType {
        UIImagePickerController().then {
            $0.allowsEditing = allowsEditing
            $0.sourceType = sourceType
            
            $0.delegate = context.coordinator
        }
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        context.coordinator.parent = self
        
        uiViewController.allowsEditing = allowsEditing
        uiViewController.sourceType = sourceType
    }
    
    public class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker
        
        init(parent: ImagePicker) {
            self.parent = parent
        }
        
        public func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            let image = (info[UIImagePickerController.InfoKey.editedImage] as? UIImage) ?? (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)
            
            parent.data = image?._fixOrientation().data(using: parent.encoding)
            
            parent.presentationManager.dismiss()
        }
        
        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationManager.dismiss()
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        .init(parent: self)
    }
}

// MARK: - API -

extension ImagePicker {
    public init(data: Binding<Data?>, encoding: Image.Encoding) {
        self._data = data
        self.encoding = encoding
    }
    
    public init(image: Binding<AppKitOrUIKitImage?>, encoding: Image.Encoding) {
        self._data = .init(
            get: { image.wrappedValue.flatMap({ $0.data(using: encoding) }) },
            set: { image.wrappedValue = $0.flatMap(AppKitOrUIKitImage.init(data:)) }
        )
        self.encoding = encoding
    }
    
}

extension ImagePicker {
    @inlinable
    public func allowsEditing(_ allowsEditing: Bool) -> Self {
        then({ $0.allowsEditing = allowsEditing })
    }
    
    @inlinable
    public func sourceType(_ sourceType: UIImagePickerController.SourceType) -> Self {
        then({ $0.sourceType = sourceType })
    }
}

// MARK: - Helpers -

extension UIImage {
    @inlinable
    func data(using encoding: Image.Encoding) -> Data? {
        switch encoding {
            case .png:
                return pngData()
            case .jpeg(let compressionQuality):
                return jpegData(compressionQuality: compressionQuality)
        }
    }
    
    func _fixOrientation() -> UIImage {
        guard imageOrientation != .up else {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        
        defer {
            UIGraphicsEndImageContext()
        }
        
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}

#endif
