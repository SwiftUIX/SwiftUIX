# View Extensions

SwiftUIX provides several useful extensions to the `View` protocol to enhance your SwiftUI development experience. Below are some of the key extensions:

### `eraseToAnyView`

The `eraseToAnyView` method is a simple utility that returns a type-erased version of the view. This can be useful when you need to store views of different types in a collection or pass them around in a type-safe manner.

```swift
import SwiftUIX

struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .eraseToAnyView()
    }
}
```

### `background`

The `background` method allows you to add a background view to your existing view. This overload is particularly useful for older versions of SwiftUI that do not support the newer background method.

```swift
import SwiftUIX

struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .background(Color.blue)
    }
}
```

### `overlay`

The `overlay` method allows you to add an overlay view to your existing view. This overload is particularly useful for older versions of SwiftUI that do not support the newer overlay method.

```swift
import SwiftUIX

struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .overlay(
                Text("Overlay")
                    .foregroundColor(.white)
            )
    }
}
```

### `hidden`

The `hidden` method allows you to conditionally hide a view. This is an improvement over SwiftUI's existing `View.hidden()` method as it provides more flexibility.

```swift
import SwiftUIX

struct ContentView: View {
    @State private var isHidden = false

    var body: some View {
        VStack {
            Text("Hello, world!")
                .hidden(isHidden)

            Button("Toggle Hidden") {
                isHidden.toggle()
            }
        }
    }
}
```
