### `ImagePicker`

A SwiftUI port of `UIImagePickerController`.

```swift
/// A SwiftUI port of `UIImagePickerController`.
public struct ImagePicker : UIViewControllerRepresentable {

    /// The type of `UIViewController` to be presented.
    public typealias UIViewControllerType = UIImagePickerController

    internal var presentationManager: SwiftUIX.PresentationManager { get }

    internal var allowsEditing: Bool

    internal var sourceType: UIImagePickerController.SourceType

    public init(data: Binding<Data?>, encoding: Image.Encoding)

    public init(data: SetBinding<Data?>, encoding: Image.Encoding)

    /// Creates a `UIViewController` instance to be presented.
    public func makeUIViewController(context: Context) -> UIViewControllerType

    /// Updates the presented `UIViewController` (and coordinator) to the latest
    /// configuration.
    public func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context)

    /// A type to coordinate with the `UIViewController`.
    public class Coordinator : NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

        internal var base: ImagePicker

        internal init(base: ImagePicker)

        public var image: Image? { get }

        public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])

        public func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    }

    /// Creates a `Coordinator` instance to coordinate with the
    /// `UIViewController`.
    ///
    /// `Coordinator` can be accessed via `Context`.
    public func makeCoordinator() -> Coordinator
}
```