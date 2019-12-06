//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

public struct ImagePicker: UIViewControllerRepresentable {
    public class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        @Binding var presentationMode: PresentationMode
        @Binding var imagePngData: Data?
        
        public var image: Image? {
            imagePngData.flatMap(Image.init(data:))
        }
        
        init(presentationMode: Binding<PresentationMode>, imagePngData: Binding<Data?>) {
            _presentationMode = presentationMode
            _imagePngData = imagePngData
        }
        
        public func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            imagePngData = (info[UIImagePickerController.InfoKey.originalImage] as! UIImage).pngData()
            
            presentationMode.dismiss()
            
        }
        
        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            presentationMode.dismiss()
        }
    }
    
    public typealias UIViewControllerType = UIImagePickerController
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var imagePngData: Data?
    
    public init(imagePngData: Binding<Data?>) {
        _imagePngData = imagePngData
    }
    
    public func makeUIViewController(context: Context) -> UIViewControllerType {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(presentationMode: presentationMode, imagePngData: $imagePngData)
    }
}

#endif
