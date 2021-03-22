##  What is `ImagePicker`?

The `ImagePicker` in SwiftUIX is a simple, efficient, and native SwiftUI way to display an equivalent of `UIImagePickerController`.

## Usage

To use the Image Picker, define a variable of type `Data` and pass it into `ImagePicker`. The user's picked image can be accessed from the variable.

```swift
struct ContentView: View {
    @State var image: Data?
    
    var body: some View {
        VStack {
            ImagePicker(data: $image, encoding: .png, onCancel: { })
            
            if let image = image {
                Image(data: image)?
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 200,height: 200)
                    .clipped()
            }
        }
    }
}
```

<p align="center">
<Image src="https://i.imgur.com/1rhpwsl.png" height=600> 
	</p>

## Parameters

`ImagePicker.init(data:encoding:onCancel)`

The `ImagePicker` takes in 3 parameters: `data`, `encoding` and `onCancel`. `onCancel` is optional.

The `data` parameter takes in a optional `Data` type binding. In the code example above, the value of variable `image` will be provided by the `ImagePicker`. If you want to display the result of the `ImagePicker`, simply use the `Image(data: )` initializer to convert the `Data` into an `Image`. 

The `encoding` parameter is an `enum` that takes in either JPEG or PNG as the encoding format. PNG or Portable Network Graphics is a loseless format for images. JPEG offers the compression quality parameter that can be 1 (very low quality) or 100 (very high quality)

`onCancel` specifies a closure to be run when the "Cancel" button is pressed. 