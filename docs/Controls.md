SwiftUIX offers (opinionated) default implementations for commonly used UI controls.

### `Checkbox`

A simple checkbox control. Its API mimics that of `Toggle`.

```swift
/// A checkbox control.
public struct Checkbox<Label: View>: View {

    /// A view that describes the effect of toggling `isOn`.
    public let label: Label

    /// Whether or not `self` is currently "on" or "off".
    public let isOn: Binding<Bool>

    public init(isOn: Binding<Bool>, @ViewBuilder label: () -> Label)

    /// Declares the content and behavior of this view.
    public var body: some View { get }
}
```