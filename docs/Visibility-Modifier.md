The way to mark views as hidden in SwiftUI is a bit obtuse, currently.

```swift
struct Foo: View {
    var body: some View {
        Text("Foo")
    }
}

struct ContentView: View {
    @State var isHidden: Bool = false
    
    var body: some View {
        Group {
            if isHidden {
                Foo().hidden()
            } else {
                Foo()
            }
        }
    }
}
```

Additionally, the `if`/`else` branch in the example above can lead to performance issues when re-rendering complex SwiftUI view hierarchies.

### `_VisibilityModifier`

```swift
extension View {
    /// Sets a view's visibility.
    ///
    /// The view still retains its frame.
    public func visible(_ isVisible: Bool = true) -> some View
}
```

**Usage:**

```swift
struct Foo: View {
    var body: some View {
        Text("Foo")
    }
}

struct ContentView: View {
    @State var isHidden: Bool = false
    
    var body: some View {
        Foo().visible(!isHidden)
    }
}
```