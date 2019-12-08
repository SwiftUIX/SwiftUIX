//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct ImagePicker: UIViewControllerRepresentable {
    public typealias UIViewControllerType = UIImagePickerController
    
    @Environment(\.presentationMode) var presentationMode
    @Binding private var data: Data?
    
    private let encoding: Image.Encoding
    
    private var allowsEditing = false
    private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    
    public init(data: Binding<Data?>, encoding: Image.Encoding) {
        self._data = data
        self.encoding = encoding
    }
    
    public func makeUIViewController(context: Context) -> UIViewControllerType {
        UIImagePickerController().then {
            $0.allowsEditing = allowsEditing
            $0.sourceType = sourceType
            
            $0.delegate = context.coordinator
        }
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        uiViewController.allowsEditing = allowsEditing
        uiViewController.sourceType = sourceType
    }
    
    public class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let base: ImagePicker
        
        init(base: ImagePicker) {
            self.base = base
        }
        
        public var image: Image? {
            base.data.flatMap(Image.init(data:))
        }
        
        public func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            base.data = (info[UIImagePickerController.InfoKey.editedImage] as! UIImage).data(using: base.encoding)
            
            base.presentationMode.dismiss()
        }
        
        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            base.presentationMode.dismiss()
        }
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(base: self)
    }
}

extension ImagePicker {
    public func allowsEditing(_ allowsEditing: Bool) -> Self {
        then({ $0.allowsEditing = allowsEditing })
    }
}

// MARK: - Helpers -

extension UIImage {
    public func data(using encoding: Image.Encoding) -> Data? {
        switch encoding {
            case .png:
                return pngData()
            case .jpeg(let compressionQuality):
                return jpegData(compressionQuality: compressionQuality)
        }
    }
}

#endif
