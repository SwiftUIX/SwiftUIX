# SwiftUI View Extensions

SwiftUIX provides several useful extensions to the SwiftUI View protocol.


## Overview

SwiftUIX provides several useful extensions to the ``SwiftUI/View`` protocol to enhance your SwiftUI development experience. 

Below are some of the key extensions, which should be restructured to be able to link to.

### background

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

### equatable

The `equatable` method prevents the view from updating its child view when its new given value is the same as its old given value.

```swift
import SwiftUIX

struct ContentView: View {
    @State private var value = 0

    var body: some View {
        Text("Value: \(value)")
            .equatable(by: value)
    }
}
```

### eraseToAnyView

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

### hidden

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

### mask

The `mask` method allows you to mask a view using the alpha channel of another view.

```swift
import SwiftUIX

struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .mask {
                Circle()
            }
    }
}
```

### masking

The `masking` method allows you to mask another view using the alpha channel of the current view.

```swift
import SwiftUIX

struct ContentView: View {
    var body: some View {
        Circle()
            .masking {
                Text("Hello, world!")
            }
    }
}
```

### overlay

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

### reverseMask

The `reverseMask` method allows you to reverse mask a view using the alpha channel of another view.

```swift
import SwiftUIX

struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .reverseMask {
                Circle()
            }
    }
}
```

### then

The `then` method allows you to apply a series of modifications to a view.

```swift
import SwiftUIX

struct ContentView: View {
    var body: some View {
        Text("Hello, world!")
            .then {
                $0.font(.largeTitle)
                $0.foregroundColor(.blue)
            }
    }
}
```

### listRowBackground

The `listRowBackground` method allows you to set a background view for a list row.

```swift
import SwiftUIX

struct ContentView: View {
    var body: some View {
        List {
            Text("Row 1")
                .listRowBackground(Color.red)
            Text("Row 2")
                .listRowBackground(Color.green)
        }
    }
}
```

### onAppearOnce

The `onAppearOnce` method allows you to perform an action only once when the view appears.

```swift
import SwiftUIX

struct ContentView: View {
    @State private var hasAppeared = false

    var body: some View {
        Text("Hello, world!")
            .onAppearOnce {
                hasAppeared = true
            }
    }
}
```
