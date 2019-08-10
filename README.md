<img align=top src="https://raw.githubusercontent.com/SwiftUIX/SwiftUIX/master/Assets/logo.png" width="36" height="36"> SwiftUIX: An extension to the standard SwiftUI library.
======================================

SwiftUIX attempts to fill the gaps of the still nascent SwiftUI framework, providing an extensive suite of components, extensions and utilities to complement the standard library.

# Installation

The preferred way of installing SwiftUIX is via the [Swift Package Manager](https://swift.org/package-manager/).

>Xcode 11 integrates with libSwiftPM to provide support for iOS, watchOS, and tvOS platforms.

1. In Xcode, open your project and navigate to **File** → **Swift Packages** → **Add Package Dependency...**
2. Paste the repository URL (`https://github.com/SwiftUIX/SwiftUIX`) and click **Next**.
3. For **Rules**, select **Branch** (with branch set to `master`).
4. Click **Finish**.

# Usage

## Controls:

SwiftUIX offers (opinionated) default implementations for commonly used UI controls.

### `Checkbox`

A simple checkbox control. Its API mimics that of `Toggle`.


## Data Representation

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

## Control Flow: 

SwiftUIX offers affordances for emulating certain types of control flow.

### Switch Statements

Below is an example of a [`switch`](https://en.wikipedia.org/wiki/Control_flow#Case_and_switch_statements) control flow being emulated. 

The following, for example, will render a circle:


```Swift
enum ShapeType {
    case capsule
    case circle
    case rectangle
    case squircle
}

struct ContentView: View {
    @State var shapeType: ShapeType = .circle

    var body: some View {
        SwitchOver(shapeType)
            .case(.capsule) {
                Capsule()
                    .frame(width: 50, height: 100)
                Text("Capsule 💊!")
            }
            .case(.circle) {
                Circle()
                    .frame(width: 50, height: 50)
                Text("Circle 🔴!")
            }
            .case(.rectangle) {
                Rectangle()
                    .frame(width: 50, height: 50)
                Text("Rectangle ⬛!")
            }
            .default {
                Text("Whoa!")
            }
    }
}
```

Whereas changing `shapeType` to `.squircle` would render the default case `Text("Whoa!")`.

## Text

### `TextView`

SwiftUIX offers a port for `UITextView`, exposing an interface similar to that of `TextField`:

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

## Extensions:

### `Color`

SwiftUIX ports the following `UIColor` named colors and exposes them as static type properties on `Color`:
- `systemRed`
- `systemGreen`
- `systemBlue`
- `systemOrange`
- `systemYellow`
- `systemPink`
- `systemPurple`
- `systemTeal`
- `systemIndigo`
- `label`
- `secondaryLabel`
- `tertiaryLabel`
- `quaternaryLabel`
- `link`
- `placeholderText`
- `separator`
- `opaqueSeparator`
- `systemBackground`
- `secondarySystemBackground`
- `tertiarySystemBackground`
- `systemGroupedBackground`
- `secondarySystemGroupedBackground`
- `tertiarySystemGroupedBackground`
- `systemFill`
- `secondarySystemFill`
- `tertiarySystemFill`
- `quaternarySystemFill`

# License

SwiftUIX is licensed under the [MIT License](https://vmanot.mit-license.org).
