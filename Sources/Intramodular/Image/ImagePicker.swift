//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct ImagePicker: UIViewControllerRepresentable {
    public typealias UIViewControllerType = UIImagePickerController
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding private var data: Data?
    
    private let encoding: Image.Encoding
    
    public init(data: Binding<Data?>, encoding: Image.Encoding) {
        self._data = data
        self.encoding = encoding
    }
    
    public func makeUIViewController(context: Context) -> UIViewControllerType {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
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
            base.data = (info[UIImagePickerController.InfoKey.originalImage] as! UIImage).data(using: base.encoding)
            
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
