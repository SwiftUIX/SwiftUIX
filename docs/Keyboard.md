### `Keyboard`

```swift
/// An object representing the keyboard.
@available(iOSApplicationExtension, unavailable)
public final class Keyboard : ObservableObject {

    public static let main: Keyboard

    public var state: State { get set }

    /// A Boolean value that determines whether the keyboard is showing on-screen.
    public var isShowing: Bool { get }

    public init(notificationCenter: NotificationCenter = .default)

    /// Dismiss the software keyboard presented on-screen.
    public func dismiss()

    /// Dismiss the software keyboard presented on-screen.
    public class func dismiss()
}
```