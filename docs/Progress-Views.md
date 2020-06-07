### `ActivityIndicator`

A view that shows that a task is in progress.

```swift
public struct ActivityIndicator: View {
    public init()

    /// Declares the content and behavior of this view.
    public var body: some View { get }

    public func animated(_ isAnimated: Bool) -> ActivityIndicator
}
```

Example usage:

```swift
ActivityIndicator()
    .animated(true)
```

### `ProgressBar`

A linear view that depicts the progress of a task over time.

```swift
public struct ProgressBar: View {
    public init(_ value: CGFloat)

    /// Declares the content and behavior of this view.
    public var body: some View { get }
}
```

Example usage:

```swift
ProgressBar(0.5)
    .frame(height: 20)
    .foregroundColor(.blue)
```

### `CircularProgressBar`

A circular view that depicts the progress of a task over time.

```swift
public struct CircularProgressBar: View {
    public init(_ value: CGFloat)

    /// Declares the content and behavior of this view.
    public var body: some View { get }
    
    /// Sets the line width of the view.
    public func lineWidth(_ lineWidth: CGFloat) -> CircularProgressBar
}
```

Example usage:

```swift
CircularProgressBar(0.5)
    .lineWidth(2)
    .foregroundColor(.blue)
    .frame(height: 100)
```