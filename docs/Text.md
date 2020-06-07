### `TextView`

SwiftUIX offers a port for `UITextView` and `NSTextView`, exposing an interface similar to that of `TextField`:

```swift
/// A control that displays an editable text interface.
public struct TextView<Label: View>: View {
    /// Declares the content and behavior of this view.
    public var body: some View { get }
}

extension TextView where Label == Text {
    public init<S: StringProtocol>(
        _ title: S,
        text: Binding<String>,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { }
    )
}
```