# About

A collection of useful SwiftUI components and tools.

## Components

### Control:

#### `Checkbox`

A simple checkbox control. Its API mimics that of `Toggle`.

### Control Flow: 

This library offers affordances for emulating multiple types of control flow. Below is an example of a [`switch`](https://en.wikipedia.org/wiki/Control_flow#Case_and_switch_statements) control flow. 

The following, for example, will render a circle:


```
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

Whereas changing `shapeType` to `.squircle` would render the default case `Text("Woah!")`.

# Installation

1. In Xcode, open your project and navigate to **File** → **Swift Packages** → **Add Package Dependency...**
2. Paste the repository URL (`https://github.com/swiftuix/SwiftUIX`)

# License

SwiftUIX is licensed under the [MIT License](https://vmanot.mit-license.org).
