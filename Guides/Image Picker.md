##  What is `ImagePicker`?
The `ImagePicker` in SwiftUIX is a simple, efficient, and native SwiftUI way to display an equivalent of `UIImagePickerController`.

<br />

## Usage Example
To use the Image Picker, define a variable of type `Data` and pass it into `ImagePicker`. The user's picked image can be accessed from the variable.

	struct ContentView: View {
	    @State var image:Data?
	    var body: some View {
	        ImagePicker(data: $image, encoding: .png)
	        Image(data: image!)!
	            .resizable()
	            .aspectRatio(contentMode: .fill)
	            .frame(width:200,height:200)
	            .clipped()
	    }
	}
The above code looks like:
<p align="center">
<Image src="https://i.imgur.com/1rhpwsl.png" height=600> 
	</p>
	
<br />

## Parameters
`ImagePicker(data: , encoding:)`

The `ImagePicker` takes in 2 parameters: `data` and `encoding`. 

The `data` parameter takes in a optional `Data` type binding. In the code example above, the value of variable `image` will be provided by the `ImagePicker`. If you want to display the result of the `ImagePicker`, simply use the `Image(data: )` initializer to convert the `Data` into an `Image`. 

The `encoding` parameter is an `enum` that takes in either JPEG or PNG as the encoding format. PNG or Portable Network Graphics is a loseless format for images. JPEG offers the compression quality parameter that can be 1 (very low quality) or 100 (very high quality)


## Source Code
The `ImagePicker` uses SwiftUI's built in `UIViewRepresentable` framework and wraps UIKit's `UIImagePickerController ` into a SwiftUI View object.

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
	    
	    public init(data: Binding<Data?>, encoding: Image.Encoding) {
	        self._data = data
	        self.encoding = encoding
	    }
	    
	    public init(data: SetBinding<Data?>, encoding: Image.Encoding) {
	        self._data = .init(set: data, defaultValue: nil)
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
	        context.coordinator.base = self
	        
	        uiViewController.allowsEditing = allowsEditing
	        uiViewController.sourceType = sourceType
	    }
	    
	    public class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	        var base: ImagePicker
	        
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
	            let image = (info[UIImagePickerController.InfoKey.editedImage] as? UIImage) ?? (info[UIImagePickerController.InfoKey.originalImage] as? UIImage)
	            base.data = image?.data(using: base.encoding)
	            
	            base.presentationManager.dismiss()
	        }
	        
	        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
	            base.presentationManager.dismiss()
	        }
	    }
	    
	    public func makeCoordinator() -> Coordinator {
	        Coordinator(base: self)
	    }
	}
